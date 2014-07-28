class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :hide_others, 'Hide Others', preset: :hide_others
    menuItem :show_all, 'Show All', preset: :show_all
    menuItem :quit, 'Quit'

    menuItem :services_item, 'Services', preset: :services

    menuItem :status_free, 'Free memory now'
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
    mainMenu(:app, 'MemoryTamer') {
      hide_others
      show_all
      ___
      services_item
      ___
      quit
    }

    statusbarMenu(:statusbar, '', status_item_icon: NSImage.imageNamed('Status'), status_item_length: NSVariableStatusItemLength) {
      status_free
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
end
