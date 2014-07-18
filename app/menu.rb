class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :hide_others, 'Hide Others', preset: :hide_others
    menuItem :show_all, 'Show All', preset: :show_all
    menuItem :quit, 'Quit'

    menuItem :services_item, 'Services', preset: :services

    menuItem :status_free, 'Free memory now'
    menuItem :status_preferences, 'Preferences', submenu: :prefs
    menuItem :preferences_refresh, 'Reload preferences'
    menuItem :notification_display, 'Currently using: Growl'
    menuItem :notification_change, 'Use Notification Center'
    menuItem :memory_display, 'Memory threshold: 1024 MB'
    menuItem :memory_change, 'Change memory threshold'
    menuItem :pressure_display, 'Freeing pressure: warn'
    menuItem :pressure_change, 'Change freeing pressure'
    menuItem :method_display, 'Freeing method: memory pressure'
    menuItem :method_change, 'Use plain allocation method'
    menuItem :status_quit, 'Quit', preset: :quit
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
      status_quit
    }

    menu(:prefs, 'Preferences') {
      preferences_refresh
      ___
      notification_display
      notification_change
      ___
      memory_display
      memory_change
      ___
      pressure_display
      pressure_change
      ___
      method_display
      method_change
    }
  end

  def_menus
  def_items
end
