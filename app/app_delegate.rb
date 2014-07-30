class AppDelegate
  attr_accessor :free_display_title

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    paddle = Paddle.sharedInstance
    paddle.setProductId('993')
    paddle.setVendorId('1657')
    paddle.setApiKey('ff308e08f807298d8a76a7a3db1ee12b')
    paddle.startLicensing({
                              KPADCurrentPrice => '2.49',
                              KPADDevName => 'Eric Henderson',
                              KPADCurrency => 'USD',
                              KPADImage => 'https://raw.githubusercontent.com/henderea/MemoryTamer/master/resources/Icon.png',
                              KPADProductName => 'MemoryTamer',
                              KPADTrialDuration => '7',
                              KPADTrialText => 'Thanks for downloading a trial of MemoryTamer! We hope you enjoy it.',
                              KPADProductImage => 'Icon.png'}, timeTrial: true, withWindow: nil)
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
      Persist['growl'] = !Persist['growl']
      set_notification_display
    }.canExecuteBlock { |_| @has_nc }
    MainMenu[:prefs].subscribe(:memory_change) { |_, _|
      nm                      = get_input('Please enter the memory threshold in MB', "#{Persist['mem']}", :int, min: 0, max: (get_total_memory / 1024**2))
      Persist['mem'] = nm if nm
      set_mem_display
    }
    MainMenu[:prefs].subscribe(:trim_change) { |_, _|
      nm                      = get_input('Please enter the memory trim threshold in MB', "#{Persist['trim_mem']}", :int, min: 0, max: (get_total_memory / 1024**2))
      Persist['trim_mem'] = nm if nm
      set_trim_display
    }
    MainMenu[:prefs].subscribe(:auto_change) { |_, _|
      np = get_input('Please select the auto-threshold target level', Persist['auto_threshold'], :select, values: %w(off low high))
      if np
        if %w(off low high).include?(np)
          Persist['auto_threshold'] = np
          set_auto_display
        else
          alert("Invalid option '#{np}'!")
        end
      end
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:pressure_change) { |_, _|
      np = get_input('Please select the freeing pressure', Persist['pressure'], :select, values: %w(normal warn critical))
      if np
        if %w(normal warn critical).include?(np)
          Persist['pressure'] = np
          set_pressure_display
        else
          alert("Invalid option '#{np}'!")
        end
      end
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:method_change) { |_, _|
      Persist['method_pressure'] = !Persist['method_pressure']
      set_method_display
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:escalate_display) { |command, sender|
      Persist['auto_escalate'] = command.parent[:state] == NSOffState
      set_escalate_display
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:show_display) { |command, sender|
      Persist['show_mem'] = command.parent[:state] == NSOffState
      set_show_display
    }
    MainMenu[:prefs].subscribe(:update_display) { |command, sender|
      Persist['update_while'] = command.parent[:state] == NSOffState
      set_update_display
    }
    MainMenu[:prefs].subscribe(:sticky_display) { |command, sender|
      Persist['sticky'] = command.parent[:state] == NSOffState
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
    NSLog "Starting up with memory = #{dfm}; pressure = #{Persist['pressure']}"
    Thread.start {
      @last_free = NSDate.date - 30
      @last_trim = NSDate.date
      loop do
        cfm = get_free_mem
        @statusItem.setTitle(Persist['show_mem'] ? format_bytes(cfm) : '') if Persist['update_while'] || !@freeing
        diff = (NSDate.date - @last_free)
        diff_t = (NSDate.date - @last_trim)
        if cfm <= dfm && diff >= 60 && diff_t >= 30 && !@freeing
          NSLog "seconds since last full freeing: #{diff}"
          NSLog "seconds since last trim: #{diff_t}"
          Thread.start { free_mem_default(cfm) }
        elsif cfm <= dtm && diff >= 30 && diff_t >= 30 && !@freeing
          NSLog "seconds since last full freeing: #{diff}"
          NSLog "seconds since last trim: #{diff_t}"
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
    MainMenu[:prefs].items[:notification_display][:title] = "Currently Using #{Persist['growl'] ? 'Growl' : 'Notification Center'}"
    MainMenu[:prefs].items[:notification_change][:title]  = "Use #{!Persist['growl'] ? 'Growl' : 'Notification Center'}"
  end

  def set_mem_display
    MainMenu[:prefs].items[:memory_display][:title] = "Memory threshold: #{Persist['mem']} MB"
    end

  def set_trim_display
    MainMenu[:prefs].items[:trim_display][:title] = "Memory trim threshold: #{Persist['trim_mem']} MB"
  end

  def set_auto_display
    MainMenu[:prefs].items[:auto_display][:title] = "Auto-threshold: #{Persist['auto_threshold']}"
  end

  def set_pressure_display
    MainMenu[:prefs].items[:pressure_display][:title] = "Freeing pressure: #{Persist['pressure']}"
    MainMenu[:prefs].items[:pressure_change][:title]  = @mavericks ? 'Change freeing pressure' : 'Requires Mavericks 10.9 or higher'
  end

  def set_method_display
    MainMenu[:prefs].items[:method_display][:title] = "Freeing method: #{Persist['method_pressure'] ? 'memory pressure' : 'plain allocation'}"
    MainMenu[:prefs].items[:method_change][:title]  = @mavericks ? "Use #{!Persist['method_pressure'] ? 'memory pressure' : 'plain allocation'} method" : 'Requires Mavericks 10.9 or higher to change'
  end

  def set_escalate_display
    MainMenu[:prefs].items[:escalate_display][:state] = Persist['auto_escalate'] ? NSOnState : NSOffState
  end

  def set_show_display
    MainMenu[:prefs].items[:show_display][:state] = Persist['show_mem'] ? NSOnState : NSOffState
    @statusItem.setTitle(Persist['show_mem'] ? format_bytes(get_free_mem) : '')
  end

  def set_update_display
    MainMenu[:prefs].items[:update_display][:state] = Persist['update_while'] ? NSOnState : NSOffState
  end

  def set_sticky_display
    MainMenu[:prefs].items[:sticky_display][:state] = Persist['sticky'] ? NSOnState : NSOffState
  end

  def set_license_display(note = nil)
    Thread.start {
      paddle = Paddle.sharedInstance
      MainMenu[:license].items[:license_display][:title] = paddle.productActivated ? paddle.activatedEmail : 'Not Registered'
      MainMenu[:license].items[:license_change][:title]  = paddle.productActivated ? 'View Registration' : 'Buy / Register'
    }
  end

  def load_prefs
    Persist['mem']             = 1024 if Persist['mem'].nil?
    Persist['trim_mem']        = 0 if Persist['trim_mem'].nil?
    Persist['auto_threshold']  = 'off' if Persist['auto_threshold'].nil?
    Persist['pressure']        = 'warn' if Persist['pressure'].nil?
    Persist['growl']           = false if Persist['growl'].nil?
    Persist['method_pressure'] = true if Persist['method_pressure'].nil?
    Persist['show_mem']        = true if Persist['show_mem'].nil?
    Persist['update_while']    = true if Persist['update_while'].nil?
    Persist['sticky']          = false if Persist['sticky'].nil?

    Persist['growl']           = Persist['growl'] || !@has_nc
    Persist['method_pressure'] = Persist['method_pressure'] && @mavericks
  end

  def dfm
    Persist['mem'] * 1024**2
    end

  def dtm
    Persist['trim_mem'] * 1024**2
  end

  def free_mem_default(cfm)
    @freeing = true
    notify 'Beginning memory freeing', 'Start Freeing'
    free_mem(Persist['pressure'])
    nfm = get_free_mem
    notify "Finished freeing #{format_bytes(nfm - cfm)}", 'Finish Freeing'
    NSLog "Freed #{format_bytes(nfm - cfm, true)}"
    @freeing   = false
    @last_free = NSDate.date
    if Persist['auto_threshold'] == 'low'
      Persist['mem']      = ((nfm.to_f * 0.3) / 1024**2).ceil
      Persist['trim_mem'] = ((nfm.to_f * 0.6) / 1024**2).ceil if Persist['trim_mem'] > 0
      set_mem_display
      set_trim_display
    elsif Persist['auto_threshold'] == 'high'
      Persist['mem']      = ((nfm.to_f * 0.5) / 1024**2).ceil
      Persist['trim_mem'] = ((nfm.to_f * 0.8) / 1024**2).ceil if Persist['trim_mem'] > 0
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
    NSLog "Freed #{format_bytes(nfm - cfm, true)}"
    @freeing   = false
    @last_trim = NSDate.date
  end

  def format_bytes(bytes, show_raw = false)
    return "#{bytes} B" if bytes <= 1
    lg   = (Math.log(bytes)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB)[lg]
    "#{'%.2f' % (bytes.to_f / 1024.0**lg)} #{unit}#{show_raw ? " (#{bytes} B)" : ''}"
  end

  def get_free_mem(inactive_multiplier = 0)
    page_size      = WeakRef.new(`vm_stat | grep 'page size' | awk '{ print $8 }'`).chomp!.to_i
    pages_free     = WeakRef.new(`vm_stat | grep 'Pages free' | awk '{ print $3 }'`).chomp![0...-1].to_i
    pages_inactive = WeakRef.new(`vm_stat | grep 'Pages inactive' | awk '{ print $3 }'`).chomp![0...-1].to_i

    page_size*pages_free + page_size*pages_inactive*inactive_multiplier
  end

  def sysctl_get(name)
    `/usr/sbin/sysctl '#{name}' | awk '{ print $2 }'`.chomp!
  end

  def get_memory_pressure
    sysctl_get('kern.memorystatus_vm_pressure_level').to_i
  end

  def get_total_memory
    sysctl_get('hw.memsize').to_i
  end

  def free_mem(pressure)
    if Persist['method_pressure']
      cmp = get_memory_pressure
      if cmp >= 4
        notify 'Memory Pressure too high! Running not a good idea.', 'Error'
        return
      end
      dmp = pressure == 'normal' ? 1 : (pressure == 'warn' ? 2 : 4)
      if cmp >= dmp && Persist['auto_escalate']
        np = cmp == 1 ? 'warn' : 'critical'
        NSLog "escalating freeing pressure from #{pressure} to #{np}"
        pressure = np
      end
      IO.popen("memory_pressure -l #{pressure}") { |pipe|
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
    NSLog "#{mtf}"
    ep = NSBundle.mainBundle.pathForResource('inactive', ofType: '')
    op = `'#{ep}' '#{mtf}'`
    NSLog op
  end

  def make_range(min, max)
    if min && max
      " (#{min}-#{max})"
    elsif min
      " (min #{min})"
    elsif max
      " (max #{max})"
    else
      ''
    end
  end

  def get_input(message, default_value, type = :text, options = {})
    alert = NSAlert.alertWithMessageText(type == :int ? "#{message}#{make_range(options[:min], options[:max])}" : message, defaultButton: 'OK', alternateButton: 'Cancel', otherButton: nil, informativeTextWithFormat: '')
    case type
      when :select
        input = NSPopUpButton.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.addItemsWithTitles(options[:values])
        input.selectItemWithTitle(default_value)
      when :int
        input                  = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.stringValue      = "#{default_value}"
        formatter              = NSNumberFormatter.alloc.init
        formatter.allowsFloats = false
        formatter.minimum      = options[:min]
        formatter.maximum      = options[:max]
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
            alert("Invalid option #{v}!")
            nil
          end
        when :int
          v = input.stringValue
          begin
            vi = v.to_i
            if options[:min] && vi < options[:min]
              alert("Value must be >= #{options[:min]}")
              nil
            elsif vi > options[:max]
              alert("Value must be < #{options[:max]}")
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
      NSLog("Invalid input dialog button #{button}")
      nil
    end
  end

  def alert(message)
    alert = NSAlert.alertWithMessageText(message, defaultButton: 'OK', alternateButton: nil, otherButton: nil, informativeTextWithFormat: '')
    alert.runModal
  end

  def notify(msg, nn)
    NSLog "Notification (#{nn}): #{msg}"
    if Persist['growl']
      GrowlApplicationBridge.notifyWithTitle(
          'MemoryTamer',
          description:      msg,
          notificationName: nn,
          iconData:         nil,
          priority:         0,
          isSticky:         Persist['sticky'],
          clickContext:     nil)
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
