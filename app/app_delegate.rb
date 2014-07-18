class AppDelegate
  attr_accessor :free_display_title

  def applicationDidFinishLaunching(notification)
    @freeing   = false
    @mavericks = `which memory_pressure`.include?('memory_pressure')
    @has_nc    = true
    load_prefs
    MainMenu.build!
    MainMenu[:statusbar].subscribe(:status_free) { |_, _|
      Thread.start { free_mem_default(get_free_mem) }
    }.canExecuteBlock { |_| !@freeing }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _|
      NSApp.terminate
    }
    MainMenu[:prefs].subscribe(:preferences_refresh) { |_, _|
      NSLog 'Reloading preferences'
      load_prefs
    }
    MainMenu[:prefs].subscribe(:notification_change) { |_, _|
      @settings[:growl] = !@settings[:growl]
      save_prefs
      set_notification_display
    }.canExecuteBlock { |_| @has_nc }
    MainMenu[:prefs].subscribe(:memory_change) { |_, _|
      nm = get_input('Please enter the memory threshold in MB (non-negative integer only)', "#{@settings[:mem]}")
      begin
        nmi = nm.to_i
        if nmi < 0
          alert('The memory threshold must be non-negative!')
        else
          @settings[:mem] = nmi
          save_prefs
          set_mem_display
        end
      rescue
        alert('The memory threshold must be an integer!')
      end
    }
    MainMenu[:prefs].subscribe(:pressure_change) { |_, _|
      np = get_input('Please select the freeing pressure', @settings[:pressure], :select, %w(normal warn critical))
      if %w(normal warn critical).include?(np)
        @settings[:pressure] = np
        save_prefs
        set_pressure_display
      end
    }.canExecuteBlock { |_| @mavericks }
    set_notification_display
    set_mem_display
    set_pressure_display
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)
    @statusItem = MainMenu[:statusbar].statusItem
    NSLog "Starting up with memory = #{dfm}; pressure = #{@options[:pressure]}"
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
    MainMenu[:prefs].items[:notification_display][:title] = "Currently Using #{@settings[:growl] ? 'Growl' : 'Notification Center'}"
    MainMenu[:prefs].items[:notification_change][:title]  = "Use #{!@settings[:growl] ? 'Growl' : 'Notification Center'}"
  end

  def set_mem_display
    MainMenu[:prefs].items[:memory_display][:title] = "Memory threshold: #{@settings[:mem]} MB"
  end

  def set_pressure_display
    MainMenu[:prefs].items[:pressure_display][:title] = "Freeing pressure: #{@settings[:pressure]}"
    MainMenu[:prefs].items[:pressure_change][:title] = @mavericks ? 'Change freeing pressure' : 'Requires Mavericks 10.9'
  end

  def load_prefs
    pth       = File.expand_path('~/mtprefs.yaml')
    @settings = { mem: 1024, pressure: 'warn', growl: false, method_pressure: true }
    begin
      if File.exist?(pth)
        fc                          = IO.read(pth).chomp
        tmp                         = YAML::load(fc)
        @settings[:mem]             = tmp[:mem] if tmp[:mem] && tmp[:mem].is_a?(Numeric)
        @settings[:pressure]        = tmp[:pressure] if tmp[:pressure] && %w(normal warn critical).include?(tmp[:pressure])
        @settings[:growl]           = tmp[:growl]
        @settings[:method_pressure] = tmp[:method_pressure]
      end
    rescue
      # ignored
    end
    @settings[:growl]           = @settings[:growl] || !@has_nc
    @settings[:method_pressure] = @settings[:method_pressure] && @mavericks
  end

  def save_prefs
    pth = File.expand_path('~/mtprefs.yaml')
    File.open(pth, mode_string='w+') { |io| io.puts(@settings.to_yaml) }
  end

  def dfm
    @settings[:mem] * 1024**2
  end

  def free_mem_default(cfm)
    @freeing = true
    notify 'Beginning memory freeing'
    free_mem(@options[:pressure])
    nfm = get_free_mem
    notify "Finished freeing #{format_bytes(nfm - cfm)}"
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

  def get_memory_pressure
    `/usr/sbin/sysctl kern.memorystatus_vm_pressure_level`.chomp.to_i
  end

  def free_mem(pressure)
    if @mavericks
      cmp = get_memory_pressure
      if cmp >= 4
        notify 'Memory Pressure too high! Running not a good idea.'
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

  def notify(msg)
    NSLog "Notification: #{msg}"
    notification                 = NSUserNotification.alloc.init
    notification.title           = 'MemoryTamer'
    notification.informativeText = msg
    notification.soundName       = NSUserNotificationDefaultSoundName
    NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
  end
end
