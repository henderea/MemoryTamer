class NSObject
  def to_weak
    WeakRef.new(self)
  end
end

class NSApplication
  def relaunchAfterDelay(seconds)
    task = NSTask.alloc.init
    args = []
    args << '-c'
    args << ('sleep %f; open "%s"' % [seconds, NSBundle.mainBundle.bundlePath])
    task.launchPath = '/bin/sh'
    task.arguments  = args
    task.launch

    self.terminate(nil)
  end
end

module Util
  module_function

  def setup_paddle
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
  end

  # noinspection RubyUnusedLocalVariable
  def set_license_display(note)
    MainMenu.set_license_display
  end

  def freeing_loop
    Thread.start {
      Info.last_free = NSDate.date - 30
      Info.last_trim = NSDate.date
      loop do
        if MemInfo.getMTMemory > (200 * (1024 ** 2)) && (NSDate.date - @start_time) > 300
          NSLog "MemoryTamer is using #{format_bytes(MemInfo.getMTMemory, true)}; restarting"
          NSApp.relaunchAfterDelay(1)
        end
        cfm = Info.get_free_mem
        MainMenu.status_item.setTitle(Persist.store.show_mem? ? Info.format_bytes(cfm) : '') if Persist.store.update_while? || !Info.freeing?
        diff   = (NSDate.date - Info.last_free)
        diff_t = (NSDate.date - Info.last_trim)
        if cfm <= Info.dfm && diff >= 60 && diff_t >= 30 && !Info.freeing?
          NSLog "seconds since last full freeing: #{diff}"
          NSLog "seconds since last trim: #{diff_t}"
          Util.free_mem_default
        elsif cfm <= Info.dtm && diff >= 30 && diff_t >= 30 && !Info.freeing?
          NSLog "seconds since last full freeing: #{diff}"
          NSLog "seconds since last trim: #{diff_t}"
          Util.trim_mem
        end
        sleep(2)
      end
    }
  end

  def notify(msg, nn)
    NSLog "Notification (#{nn}): #{msg}"
    if Persist.store.notifications == 'Growl'
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
    elsif Persist.store.notifications == 'Notification Center'
      notification                 = NSUserNotification.alloc.init
      notification.title           = 'MemoryTamer'
      notification.informativeText = msg
      notification.soundName       = nil #NSUserNotificationDefaultSoundName
      NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
    end
  end

  def free_mem_default
    Thread.start {
      cfm          = Info.get_free_mem
      Info.freeing = true
      notify 'Beginning memory freeing', 'Start Freeing'
      free_mem(Persist.store.pressure)
      nfm = Info.get_free_mem
      notify "Finished freeing #{Info.format_bytes(nfm - cfm)}", 'Finish Freeing'
      NSLog "Freed #{Info.format_bytes(nfm - cfm, true)}"
      Info.freeing   = false
      Info.last_free = NSDate.date
      # if Persist.store.auto_threshold == 'low'
      #   Persist.store.mem      = ((nfm.to_f * 0.3) / 1024**2).ceil
      #   Persist.store.trim_mem = ((nfm.to_f * 0.6) / 1024**2).ceil if Persist.store.trim_mem > 0
      # elsif Persist.store.auto_threshold == 'high'
      #   Persist.store.mem      = ((nfm.to_f * 0.5) / 1024**2).ceil
      #   Persist.store.trim_mem = ((nfm.to_f * 0.8) / 1024**2).ceil if Persist.store.trim_mem > 0
      # end
    }
  end

  def trim_mem
    Thread.start {
      cfm          = Info.get_free_mem
      Info.freeing = true
      notify 'Beginning memory trimming', 'Start Freeing'
      free_mem_old(true)
      nfm = Info.get_free_mem
      notify "Finished trimming #{Info.format_bytes(nfm - cfm)}", 'Finish Freeing'
      NSLog "Freed #{Info.format_bytes(nfm - cfm, true)}"
      Info.freeing   = false
      Info.last_trim = NSDate.date
    }
  end

  def free_mem(pressure)
    if Persist.store.method_pressure?
      cmp = Info.get_memory_pressure
      if cmp >= 4
        notify 'Memory Pressure too high! Running not a good idea.', 'Error'
        return
      end
      dmp = pressure == 'normal' ? 1 : (pressure == 'warn' ? 2 : 4)
      if cmp >= dmp && Persist.store.auto_escalate?
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
    mtf = trim ? [Info.get_free_mem(1) * 0.75, Info.get_free_mem(0.5)].min : Info.get_free_mem(1)
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

  def open_link(link)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(link));
  end

  def constrain_value_range(range, value, default)
    value ? (value < range.min && range.min) || (value > range.max && range.max) : default
  end

  def constrain_value_list(list, old_value, new_value, default)
    new_value ? !list.include?(new_value) && ((list.include?(old_value) && old_value) || default) : default
    end

  def constrain_value_list_enable_map(map, old_value, new_value, new_default, default)
    new_value ? !map[new_value] && ((map[old_value] && old_value) || default) : new_default
  end

  def constrain_value_boolean(value, default, enable = true, enable_is_true = true)
    (value.nil? ? default : value) ? (enable || !enable_is_true) : (!enable && !enable_is_true)
  end
end