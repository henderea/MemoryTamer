class NSObject
  def to_weak
    WeakRef.new(self)
  end
end

class AppDelegate
  attr_accessor :free_display_title

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    paddle = Paddle.sharedInstance
    paddle.setProductId('993')
    paddle.setVendorId('1657')
    paddle.setApiKey('ff308e08f807298d8a76a7a3db1ee12b')
    paddle.startLicensing({ KPADCurrentPrice  => '2.49',
                            KPADDevName       => 'Eric Henderson',
                            KPADCurrency      => 'USD',
                            KPADImage         => 'https://raw.githubusercontent.com/henderea/MemoryTamer/master/resources/Icon.png',
                            KPADProductName   => 'MemoryTamer',
                            KPADTrialDuration => '7',
                            KPADTrialText     => 'Thanks for downloading a trial of MemoryTamer! We hope you enjoy it.',
                            KPADProductImage  => 'Icon.png' }, timeTrial: true, withWindow: nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :set_license_display, name: KPADActivated, object: nil)
    SUUpdater.sharedUpdater
    @freeing = false
    system('which memory_pressure')
    @mavericks = $?.success?
    @has_nc    = (NSClassFromString('NSUserNotificationCenter')!=nil)
    load_prefs
    MainMenu.build!
    @statusItem = MainMenu[:statusbar].statusItem
    MainMenu[:statusbar].subscribe(:status_free) { |_, _|
      Thread.start { free_mem_default(get_free_mem) }
    }.canExecuteBlock { |_| !@freeing }
    MainMenu[:statusbar].subscribe(:status_trim) { |_, _|
      Thread.start { trim_mem(get_free_mem) }
    }.canExecuteBlock { |_| !@freeing }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _|
      NSApp.terminate
    }
    MainMenu[:statusbar].subscribe(:status_update) { |_, sender|
      SUUpdater.sharedUpdater.checkForUpdates(sender)
    }
    MainMenu[:license].subscribe(:license_change) { |_, _|
      Paddle.sharedInstance.showLicencing
    }
    MainMenu[:prefs].subscribe(:notification_change) { |_, _|
      Persist.store.growl = !Persist.store.growl?
      set_notification_display
    }.canExecuteBlock { |_| @has_nc }
    MainMenu[:prefs].subscribe(:memory_change) { |_, _|
      nm                = get_input('Please enter the memory threshold in MB', "#{Persist.store.mem}".to_weak, :int, min: 0, max: (get_total_memory / 1024**2))
      Persist.store.mem = nm if nm
      set_mem_display
    }
    MainMenu[:prefs].subscribe(:trim_change) { |_, _|
      nm                     = get_input('Please enter the memory trim threshold in MB', "#{Persist.store.trim_mem}".to_weak, :int, min: 0, max: (get_total_memory / 1024**2))
      Persist.store.trim_mem = nm if nm
      set_trim_display
    }
    MainMenu[:prefs].subscribe(:auto_change) { |_, _|
      np = get_input('Please select the auto-threshold target level', Persist.store.auto_threshold, :select, values: %w(off low high))
      if np
        if %w(off low high).include?(np)
          Persist.store.auto_threshold = np
          set_auto_display
        else
          alert("Invalid option '#{np}'!")
        end
      end
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:pressure_change) { |_, _|
      np = get_input('Please select the freeing pressure', Persist.store.pressure, :select, values: %w(normal warn critical))
      if np
        if %w(normal warn critical).include?(np)
          Persist.store.pressure = np
          set_pressure_display
        else
          alert("Invalid option '#{np}'!")
        end
      end
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:method_change) { |_, _|
      Persist.store.method_pressure = !Persist.store.method_pressure?
      set_method_display
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:escalate_display) { |command, sender|
      Persist.store.auto_escalate = command.parent[:state] == NSOffState
      set_escalate_display
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:show_display) { |command, sender|
      Persist.store.show_mem = command.parent[:state] == NSOffState
      set_show_display
    }
    MainMenu[:prefs].subscribe(:update_display) { |command, sender|
      Persist.store.update_while = command.parent[:state] == NSOffState
      set_update_display
    }
    MainMenu[:prefs].subscribe(:sticky_display) { |command, sender|
      Persist.store.sticky = command.parent[:state] == NSOffState
      set_sticky_display
    }
    MainMenu[:support].subscribe(:support_ticket) { |_, _|
      open_link('https://github.com/henderea/MemoryTamer/issues/new')
    }
    MainMenu[:support].subscribe(:support_usage) { |_, _|
      open_link('https://github.com/henderea/MemoryTamer/blob/master/USING.md')
    }
    set_all_displays
    MainMenu[:statusbar].items[:status_version][:title] = "Current Version: #{NSBundle.mainBundle.infoDictionary['CFBundleVersion']}"
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self) if @has_nc
    GrowlApplicationBridge.setGrowlDelegate(self)
    NSLog "Starting up with memory = #{dfm}; pressure = #{Persist.store.pressure}"
    Thread.start {
      @last_free = NSDate.date - 30
      @last_trim = NSDate.date
      loop do
        cfm = get_free_mem
        @statusItem.setTitle(Persist.store.show_mem? ? format_bytes(cfm.to_weak).to_weak : '') if Persist.store.update_while? || !@freeing
        diff   = (NSDate.date - @last_free)
        diff_t = (NSDate.date - @last_trim)
        set_mem_display
        if cfm <= dfm && diff >= 60 && diff_t >= 30 && !@freeing
          NSLog "seconds since last full freeing: #{diff}".to_weak
          NSLog "seconds since last trim: #{diff_t}".to_weak
          Thread.start { free_mem_default(cfm) }
        elsif cfm <= dtm && diff >= 30 && diff_t >= 30 && !@freeing
          NSLog "seconds since last full freeing: #{diff}".to_weak
          NSLog "seconds since last trim: #{diff_t}".to_weak
          Thread.start { trim_mem(cfm) }
        end
        sleep(2)
      end
    }
  end

  def set_all_displays
    set_notification_display
    set_mem_display
    set_trim_display
    set_auto_display
    set_pressure_display
    set_method_display
    set_escalate_display
    set_show_display
    set_update_display
    set_sticky_display
    set_license_display
  end

  def set_notification_display
    MainMenu[:prefs].items[:notification_display][:title] = "Currently Using #{Persist.store.growl? ? 'Growl' : 'Notification Center'}".to_weak
    MainMenu[:prefs].items[:notification_change][:title]  = "Use #{!Persist.store.growl? ? 'Growl' : 'Notification Center'}".to_weak
  end

  def set_mem_display
    MainMenu[:prefs].items[:memory_display][:title] = "Memory threshold: #{Persist.store.mem} MB".to_weak
  end

  def set_trim_display
    MainMenu[:prefs].items[:trim_display][:title] = "Memory trim threshold: #{Persist.store.trim_mem} MB".to_weak
  end

  def set_auto_display
    MainMenu[:prefs].items[:auto_display][:title] = "Auto-threshold: #{Persist.store.auto_threshold}".to_weak
  end

  def set_pressure_display
    MainMenu[:prefs].items[:pressure_display][:title] = "Freeing pressure: #{Persist.store.pressure}".to_weak
    MainMenu[:prefs].items[:pressure_change][:title]  = @mavericks ? 'Change freeing pressure' : 'Requires Mavericks 10.9 or higher'
  end

  def set_method_display
    MainMenu[:prefs].items[:method_display][:title] = "Freeing method: #{Persist.store.method_pressure? ? 'memory pressure' : 'plain allocation'}".to_weak
    MainMenu[:prefs].items[:method_change][:title]  = @mavericks ? "Use #{!Persist.store.method_pressure? ? 'memory pressure' : 'plain allocation'} method".to_weak : 'Requires Mavericks 10.9 or higher to change'
  end

  def set_escalate_display
    MainMenu[:prefs].items[:escalate_display][:state] = Persist.store.auto_escalate_state?
  end

  def set_show_display
    MainMenu[:prefs].items[:show_display][:state] = Persist.store.show_mem_state?
    @statusItem.setTitle(Persist.store.show_mem? ? format_bytes(get_free_mem) : '')
  end

  def set_update_display
    MainMenu[:prefs].items[:update_display][:state] = Persist.store.update_while_state?
  end

  def set_sticky_display
    MainMenu[:prefs].items[:sticky_display][:state] = Persist.store.sticky_state?
  end

  def set_license_display(note = nil)
    Thread.start {
      paddle                                             = Paddle.sharedInstance
      MainMenu[:license].items[:license_display][:title] = paddle.productActivated ? paddle.activatedEmail : 'Not Registered'
      MainMenu[:license].items[:license_change][:title]  = paddle.productActivated ? 'View Registration' : 'Buy / Register'
    }
  end

  def load_prefs
    Persist.store.mem             = 1024 if Persist.store.mem.nil?
    Persist.store.trim_mem        = 0 if Persist.store.trim_mem.nil?
    Persist.store.auto_threshold  = 'off' if Persist.store.auto_threshold.nil?
    Persist.store.pressure        = 'warn' if Persist.store.pressure.nil?
    Persist.store.growl           = false if Persist.store.growl.nil?
    Persist.store.method_pressure = true if Persist.store.method_pressure.nil?
    Persist.store.auto_escalate   = false if Persist.store.auto_escalate.nil?
    Persist.store.show_mem        = true if Persist.store.show_mem.nil?
    Persist.store.update_while    = true if Persist.store.update_while.nil?
    Persist.store.sticky          = false if Persist.store.sticky.nil?

    Persist.store.growl           = Persist.store.growl? || !@has_nc
    Persist.store.method_pressure = Persist.store.method_pressure? && @mavericks
  end

  def dfm
    Persist.store.mem * 1024**2
  end

  def dtm
    Persist.store.trim_mem * 1024**2
  end

  def free_mem_default(cfm)
    @freeing = true
    notify 'Beginning memory freeing', 'Start Freeing'
    free_mem(Persist.store.pressure)
    nfm = get_free_mem
    notify "Finished freeing #{format_bytes(nfm - cfm)}", 'Finish Freeing'
    NSLog "Freed #{format_bytes(nfm - cfm, true)}"
    @freeing   = false
    @last_free = NSDate.date
    if Persist.store.auto_threshold == 'low'
      Persist.store.mem      = ((nfm.to_f * 0.3) / 1024**2).ceil
      Persist.store.trim_mem = ((nfm.to_f * 0.6) / 1024**2).ceil if Persist.store.trim_mem > 0
      set_mem_display
      set_trim_display
    elsif Persist.store.auto_threshold == 'high'
      Persist.store.mem      = ((nfm.to_f * 0.5) / 1024**2).ceil
      Persist.store.trim_mem = ((nfm.to_f * 0.8) / 1024**2).ceil if Persist.store.trim_mem > 0
      set_mem_display
      set_trim_display
    end
  end

  def trim_mem(cfm)
    @freeing = true
    notify 'Beginning memory trimming', 'Start Freeing'
    free_mem_old(true)
    nfm = get_free_mem
    notify "Finished trimming #{format_bytes(nfm - cfm)}", 'Finish Freeing'
    NSLog "Freed #{format_bytes(nfm - cfm, true)}".to_weak
    @freeing   = false
    @last_trim = NSDate.date
  end

  def format_bytes(bytes, show_raw = false)
    return "#{bytes} B".to_weak if bytes <= 1
    lg   = (Math.log(bytes)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB).to_weak[lg].to_weak
    "#{('%.2f' % (bytes.to_f / 1024.0**lg)).to_weak} #{unit}#{show_raw ? " (#{bytes} B)".to_weak : ''}"
  end

  def sizeof(type)
    size_ptr  = Pointer.new('Q')
    align_ptr = Pointer.new('Q')
    NSGetSizeAndAlignment(type, size_ptr, align_ptr)
    size_ptr[0]
  end

  def get_free_mem(inactive_multiplier = 0)
    page_size      = MemInfo.getPageSize
    pages_free     = MemInfo.getPagesFree
    pages_inactive = MemInfo.getPagesInactive

    page_size*pages_free + page_size*pages_inactive*inactive_multiplier
  end

  def get_memory_pressure
    MemInfo.getMemoryPressure
  end

  def get_total_memory
    MemInfo.getTotalMemory
  end

  def free_mem(pressure)
    if Persist.store.method_pressure?
      cmp = get_memory_pressure
      if cmp >= 4
        notify 'Memory Pressure too high! Running not a good idea.', 'Error'
        return
      end
      dmp = pressure == 'normal' ? 1 : (pressure == 'warn' ? 2 : 4)
      if cmp >= dmp && Persist.store.auto_escalate?
        np = cmp == 1 ? 'warn' : 'critical'
        NSLog "escalating freeing pressure from #{pressure} to #{np}".to_weak
        pressure = np
      end
      IO.popen("memory_pressure -l #{pressure}") { |pipe|
        pipe      = pipe.to_weak
        pipe.sync = true
        pipe.each { |l|
          NSLog l
          # if l.include?('CMD: Allocating pages')
          if l.include?('Stabilizing at')
            Process.kill 'SIGINT', pipe.pid
            break
          end
        }
      }
    else
      free_mem_old
    end
  end

  def free_mem_old(trim = false)
    mtf = trim ? [get_free_mem(1) * 0.75, get_free_mem(0.5)].min : get_free_mem(1)
    NSLog "#{mtf}".to_weak
    ep = NSBundle.mainBundle.pathForResource('inactive', ofType: '')
    op = `'#{ep}' '#{mtf}'`.to_weak
    NSLog op
  end

  def make_range(min, max)
    if min && max
      " (#{min}-#{max})".to_weak
    elsif min
      " (min #{min})".to_weak
    elsif max
      " (max #{max})".to_weak
    else
      ''
    end
  end

  def get_input(message, default_value, type = :text, options = {})
    alert = NSAlert.alertWithMessageText(type == :int ? "#{message}#{make_range(options[:min], options[:max]).to_weak}".to_weak : message, defaultButton: 'OK', alternateButton: 'Cancel', otherButton: nil, informativeTextWithFormat: '').to_weak
    case type
      when :select
        input = NSPopUpButton.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.addItemsWithTitles(options[:values])
        input.selectItemWithTitle(default_value)
      when :int
        input                  = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.stringValue      = "#{default_value}".to_weak
        formatter              = NSNumberFormatter.alloc.init
        formatter.allowsFloats = false
        formatter.minimum      = options[:min]
        formatter.maximum      = options[:max]
        input.formatter        = formatter
      else
        input             = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.stringValue = default_value
    end
    alert.setAccessoryView(input)
    button = alert.runModal
    if button == NSAlertDefaultReturn
      input.validateEditing
      case type
        when :select
          v = input.titleOfSelectedItem
          if options[:values].include?(v)
            v
          else
            alert("Invalid option #{v}!".to_weak)
            nil
          end
        when :int
          v = input.stringValue
          begin
            vi = v.to_i
            if options[:min] && vi < options[:min]
              alert("Value must be >= #{options[:min]}".to_weak)
              nil
            elsif vi > options[:max]
              alert("Value must be < #{options[:max]}".to_weak)
              nil
            else
              vi
            end
          rescue
            alert('Value must be an integer!')
            nil
          end
        else
          input.stringValue
      end
    elsif button == NSAlertAlternateReturn
      nil
    else
      NSLog("Invalid input dialog button #{button}".to_weak)
      nil
    end
  end

  def alert(message)
    alert = NSAlert.alertWithMessageText(message, defaultButton: 'OK', alternateButton: nil, otherButton: nil, informativeTextWithFormat: '').to_weak
    alert.runModal
  end

  def notify(msg, nn)
    NSLog "Notification (#{nn}): #{msg}".to_weak
    if Persist.store.growl?
      if GrowlApplicationBridge.isGrowlRunning
        ep = NSBundle.mainBundle.pathForResource('growlnotify', ofType: '')
        system("'#{ep}' -n MemoryTamer -a MemoryTamer#{(Persist.store.sticky? ? ' -s' : '')} -m '#{msg}' -t 'MemoryTamer'")
      else
        GrowlApplicationBridge.notifyWithTitle(
            'MemoryTamer',
            description:      msg,
            notificationName: nn,
            iconData:         nil,
            priority:         0,
            isSticky:         Persist.store.sticky?,
            clickContext:     nil)
      end
    else
      notification                 = NSUserNotification.alloc.init
      notification.title           = 'MemoryTamer'
      notification.informativeText = msg
      notification.soundName       = nil #NSUserNotificationDefaultSoundName
      NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
    end
  end

  def open_link(link)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(link));
  end
end
