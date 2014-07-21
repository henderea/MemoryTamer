class AppDelegate
  attr_accessor :free_display_title

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    SUUpdater.sharedUpdater
    @freeing = false
    system('which memory_pressure')
    @mavericks = $?.success?
    @has_nc    = (NSClassFromString('NSUserNotificationCenter')!=nil)
    load_prefs
    MainMenu.build!
    MainMenu[:statusbar].subscribe(:status_free) { |_, _|
      Thread.start { free_mem_default(get_free_mem) }
    }.canExecuteBlock { |_| !@freeing }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _|
      NSApp.terminate
    }
    MainMenu[:statusbar].subscribe(:status_update) { |_, _|
      alert('No new version found') unless check_for_updates
    }
    MainMenu[:prefs].subscribe(:preferences_refresh) { |_, _|
      NSLog 'Reloading preferences'
      load_prefs
      set_notification_display
      set_mem_display
      set_pressure_display
      set_method_display
    }
    MainMenu[:prefs].subscribe(:notification_change) { |_, _|
      App::Persistence['growl'] = !App::Persistence['growl']
      set_notification_display
    }.canExecuteBlock { |_| @has_nc }
    MainMenu[:prefs].subscribe(:memory_change) { |_, _|
      nm = get_input("Please enter the memory threshold in MB (0 - #{get_total_memory / 1024**2})", "#{App::Persistence['mem']}") { |str| (str =~ /^\d*$/) }
      if nm
        begin
          nmi = nm.to_i
          if nmi < 0
            alert('The memory threshold must be non-negative!')
          elsif nmi > get_total_memory / 1024**2
            alert('You can\'t specify a value above your total ram')
          else
            App::Persistence['mem'] = nmi
            set_mem_display
          end
        rescue
          alert('The memory threshold must be an integer!')
        end
      end
    }
    MainMenu[:prefs].subscribe(:pressure_change) { |_, _|
      np = get_input('Please select the freeing pressure', App::Persistence['pressure'], :select, %w(normal warn critical))
      if np
        if %w(normal warn critical).include?(np)
          App::Persistence['pressure'] = np
          set_pressure_display
        else
          alert("Invalid option '#{np}'!")
        end
      end
    }.canExecuteBlock { |_| @mavericks }
    MainMenu[:prefs].subscribe(:method_change) { |_, _|
      App::Persistence['method_pressure'] = !App::Persistence['method_pressure']
      set_method_display
    }.canExecuteBlock { |_| @mavericks }
    set_notification_display
    set_mem_display
    set_pressure_display
    set_method_display
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self) if @has_nc
    GrowlApplicationBridge.setGrowlDelegate(self)
    @statusItem = MainMenu[:statusbar].statusItem
    NSLog "Starting up with memory = #{dfm}; pressure = #{App::Persistence['pressure']}"
    Thread.start {
      @last_free = NSDate.date - 120
      loop do
        cfm = get_free_mem
        @statusItem.setTitle(format_bytes(cfm))
        if cfm <= dfm && (NSDate.date - @last_free) >= 60 && !@freeing
          Thread.start { free_mem_default(cfm) }
        end
        sleep(2)
      end
    }
  end

  def set_notification_display
    MainMenu[:prefs].items[:notification_display][:title] = "Currently Using #{App::Persistence['growl'] ? 'Growl' : 'Notification Center'}"
    MainMenu[:prefs].items[:notification_change][:title]  = "Use #{!App::Persistence['growl'] ? 'Growl' : 'Notification Center'}"
  end

  def set_mem_display
    MainMenu[:prefs].items[:memory_display][:title] = "Memory threshold: #{App::Persistence['mem']} MB"
  end

  def set_pressure_display
    MainMenu[:prefs].items[:pressure_display][:title] = "Freeing pressure: #{App::Persistence['pressure']}"
    MainMenu[:prefs].items[:pressure_change][:title]  = @mavericks ? 'Change freeing pressure' : 'Requires Mavericks 10.9 or higher'
  end

  def set_method_display
    MainMenu[:prefs].items[:method_display][:title] = "Freeing method: #{App::Persistence['method_pressure'] ? 'memory pressure' : 'plain allocation'}"
    MainMenu[:prefs].items[:method_change][:title]  = @mavericks ? "Use #{!App::Persistence['method_pressure'] ? 'memory pressure' : 'plain allocation'} method" : 'Requires Mavericks 10.9 or higher to change'
  end

  def load_prefs
    pth       = File.expand_path('~/mtprefs.yaml')
    if App::Persistence['pressure'].nil?
      App::Persistence['mem'] = 1024
      App::Persistence['pressure'] = 'warn'
      App::Persistence['growl'] = false
      App::Persistence['method_pressure'] = true
      begin
        if File.exist?(pth)
          fc                          = IO.read(pth).chomp
          tmp                         = YAML::load(fc)
          App::Persistence['mem']             = tmp[:mem] if tmp[:mem] && tmp[:mem].is_a?(Numeric)
          App::Persistence['pressure']        = tmp[:pressure] if tmp[:pressure] && %w(normal warn critical).include?(tmp[:pressure])
          App::Persistence['growl']           = tmp[:growl] && tmp[:growl] != 0
          App::Persistence['method_pressure'] = tmp[:method_pressure] && tmp[:method_pressure] != 0
        end
      rescue
        # ignored
      end
    end
    App::Persistence['growl']           = App::Persistence['growl'] || !@has_nc
    App::Persistence['method_pressure'] = App::Persistence['method_pressure'] && @mavericks
  end

  def dfm
    App::Persistence['mem'] * 1024**2
  end

  def free_mem_default(cfm)
    @freeing = true
    notify 'Beginning memory freeing', 'Start Freeing'
    free_mem(App::Persistence['pressure'])
    nfm = get_free_mem
    notify "Finished freeing #{format_bytes(nfm - cfm)}", 'Finish Freeing'
    NSLog "Freed #{format_bytes(nfm - cfm, true)}"
    @freeing   = false
    @last_free = NSDate.date
  end

  def format_bytes(bytes, show_raw = false)
    lg   = (Math.log(bytes)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB)[lg]
    "#{'%.2f' % (bytes.to_f / 1024.0**lg)} #{unit}#{show_raw ? " (#{bytes} B)" : ''}"
  end

  def get_free_mem(include_inactive = false)
    vm_stat = `vm_stat`

    vm_stat = vm_stat.split("\n")

    page_size = vm_stat[0].match(/(\d+) bytes/)[1].to_i

    pages_free     = vm_stat[1].match(/(\d+)/)[1].to_i
    pages_inactive = vm_stat[3].match(/(\d+)/)[1].to_i

    page_size*pages_free + (include_inactive ? page_size*pages_inactive : 0)
  end

  def sysctl_get(name)
    v = `/usr/sbin/sysctl '#{name}'`.chomp
    v = v[(name.length + 2)..-1] if v.start_with?("#{name}: ")
    v
  end

  def get_memory_pressure
    sysctl_get('kern.memorystatus_vm_pressure_level').to_i
  end

  def get_total_memory
    sysctl_get('hw.memsize').to_i
  end

  def free_mem(pressure)
    if App::Persistence['method_pressure']
      cmp = get_memory_pressure
      if cmp >= 4
        notify 'Memory Pressure too high! Running not a good idea.', 'Error'
        return
      end
      dmp      = pressure == 'normal' ? 1 : (pressure == 'warn' ? 2 : 4)
      pressure = cmp == 1 ? 'warn' : 'critical' if cmp >= dmp
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

  def free_mem_old
    mtf = get_free_mem(true)
    NSLog mtf
    ep = NSBundle.mainBundle.pathForResource('inactive', ofType: '')
    op = `'#{ep}' '#{mtf}'`
    NSLog op
  end

  def get_input(message, default_value, type = :text, options = [])
    alert = NSAlert.alertWithMessageText(message, defaultButton: 'OK', alternateButton: 'Cancel', otherButton: nil, informativeTextWithFormat: '')
    case type
      when :select
        input = NSComboBox.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.addItemsWithObjectValues(options)
        input.selectItemWithObjectValue(default_value)
      when :number
        input                  = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
        input.stringValue      = "#{default_value}"
        formatter              = NSNumberFormatter.alloc.init
        formatter.allowsFloats = false
        formatter.minimum      = 0
        formatter.maximum      = get_total_memory / 1024**2
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
          input.objectValueOfSelectedItem
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
    if App::Persistence['growl']
      GrowlApplicationBridge.notifyWithTitle(
          'MemoryTamer',
          description:      msg,
          notificationName: nn,
          iconData:         nil,
          priority:         0,
          isSticky:         true,
          clickContext:     nil)
    else
      notification                 = NSUserNotification.alloc.init
      notification.title           = 'MemoryTamer'
      notification.informativeText = msg
      notification.soundName       = nil #NSUserNotificationDefaultSoundName
      NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
    end
  end

  def check_for_updates
    # version = NSBundle.mainBundle.infoDictionary['CFBundleVersion']
    # BW::HTTP.get('https://api.github.com/repos/henderea/memorytamer/tags') do |response|
    #   if response.ok?
    #     json = BW::JSON.parse(response.body.to_str)
    #     nv = json[0]['name']
    #     if nv > version
    #       alert("New version available: #{nv}; current version: #{version}")
    #       NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString('https://github.com/henderea/MemoryTamer/blob/master/README.md'))
    #     end
    #     nv > version
    #   elsif response.status_code.to_s =~ /40\d/
    #     alert('Login failed')
    #     true
    #   else
    #     alert(response.error_message)
    #     true
    #   end
    # end
    SUUpdater.sharedUpdater.checkForUpdates
  end
end
