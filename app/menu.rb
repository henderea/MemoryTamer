class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :status_free, 'Free memory now'
    menuItem :status_trim, 'Trim memory now'
    menuItem :status_update, 'Check for Updates'
    menuItem :status_version, 'Current Version: 0.0'
    menuItem :status_quit, 'Quit', preset: :quit

    menuItem :status_preferences, 'Preferences', submenu: :prefs
    menuItem :notification_display, 'Currently using: Growl'
    menuItem :notification_change, 'Use Notification Center'
    menuItem :memory_display, 'Memory threshold: 1024 MB'
    menuItem :memory_change, 'Change memory threshold'
    menuItem :trim_display, 'Memory trim threshold: 2048 MB'
    menuItem :trim_change, 'Change memory trim threshold'
    menuItem :auto_display, 'Auto-threshold: off'
    menuItem :auto_change, 'Change auto-threshold'
    menuItem :pressure_display, 'Freeing pressure: warn'
    menuItem :pressure_change, 'Change freeing pressure'
    menuItem :method_display, 'Freeing method: memory pressure'
    menuItem :method_change, 'Use plain allocation method'
    menuItem :escalate_display, 'Auto-escalate', state: NSOffState
    menuItem :show_display, 'Show free memory', state: NSOnState
    menuItem :update_display, 'Update while freeing', state: NSOnState
    menuItem :sticky_display, 'Sticky Growl notifications', state: NSOffState

    menuItem :status_license, 'Registration', submenu: :license
    menuItem :license_display, 'Not Registered'
    menuItem :license_change, 'Buy / Register'

    menuItem :status_support, 'Support', submenu: :support
    menuItem :support_ticket, 'Submit bug or feature request'
    menuItem :support_usage, 'Using MemoryTamer'
  end

  def self.def_menus
    statusbarMenu(:statusbar, '', status_item_icon: NSImage.imageNamed('Status'), status_item_length: NSVariableStatusItemLength) {
      status_free
      status_trim
      ___
      status_preferences
      ___
      status_license
      ___
      status_support
      ___
      status_update
      status_version
      ___
      status_quit
    }

    menu(:prefs, 'Preferences') {
      notification_display
      notification_change
      ___
      memory_display
      memory_change
      ___
      trim_display
      trim_change
      ___
      auto_display
      auto_change
      ___
      pressure_display
      pressure_change
      ___
      method_display
      method_change
      ___
      escalate_display
      ___
      show_display
      ___
      update_display
      ___
      sticky_display
    }

    menu(:license, 'Registration') {
      license_display
      license_change
    }

    menu(:support, 'Support') {
      support_ticket
      support_usage
    }
  end

  def_menus
  def_items

  class << self
    def status_item
      MainMenu[:statusbar].statusItem
    end

    def set_all_displays
      set_growl_display
      set_mem_display
      set_trim_mem_display
      set_auto_threshold_display
      set_pressure_display
      set_method_pressure_display
      set_auto_escalate_display
      set_show_mem_display
      set_update_while_display
      set_sticky_display
      set_license_display
    end

    def set_growl_display
      MainMenu[:prefs].items[:notification_display][:title] = "Currently Using #{Persist.growl? ? 'Growl' : 'Notification Center'}"
      MainMenu[:prefs].items[:notification_change][:title]  = "Use #{!Persist.growl? ? 'Growl' : 'Notification Center'}"
    end

    def set_mem_display
      MainMenu[:prefs].items[:memory_display][:title] = "Memory threshold: #{Persist.mem} MB"
    end

    def set_trim_mem_display
      MainMenu[:prefs].items[:trim_display][:title] = "Memory trim threshold: #{Persist.trim_mem} MB"
    end

    def set_auto_threshold_display
      MainMenu[:prefs].items[:auto_display][:title] = "Auto-threshold: #{Persist.auto_threshold}"
    end

    def set_pressure_display
      MainMenu[:prefs].items[:pressure_display][:title] = "Freeing pressure: #{Persist.pressure}"
      MainMenu[:prefs].items[:pressure_change][:title]  = Info.mavericks? ? 'Change freeing pressure' : 'Requires Mavericks 10.9 or higher'
    end

    def set_method_pressure_display
      MainMenu[:prefs].items[:method_display][:title] = "Freeing method: #{Persist.method_pressure? ? 'memory pressure' : 'plain allocation'}"
      MainMenu[:prefs].items[:method_change][:title]  = Info.mavericks? ? "Use #{!Persist.method_pressure? ? 'memory pressure' : 'plain allocation'} method" : 'Requires Mavericks 10.9 or higher to change'
    end

    def set_auto_escalate_display
      MainMenu[:prefs].items[:escalate_display][:state] = Persist.auto_escalate? ? NSOnState : NSOffState
    end

    def set_show_mem_display
      MainMenu[:prefs].items[:show_display][:state] = Persist.show_mem? ? NSOnState : NSOffState
      status_item.setTitle(Persist.show_mem? ? Info.format_bytes(Info.get_free_mem) : '')
    end

    def set_update_while_display
      MainMenu[:prefs].items[:update_display][:state] = Persist.update_while? ? NSOnState : NSOffState
    end

    def set_sticky_display
      MainMenu[:prefs].items[:sticky_display][:state] = Persist.sticky? ? NSOnState : NSOffState
    end

    def set_license_display
      Thread.start {
        paddle                                             = Paddle.sharedInstance
        MainMenu[:license].items[:license_display][:title] = paddle.productActivated ? paddle.activatedEmail : 'Not Registered'
        MainMenu[:license].items[:license_change][:title]  = paddle.productActivated ? 'View Registration' : 'Buy / Register'
      }
    end
  end
end
