class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :hide_others, 'Hide Others', preset: :hide_others
    menuItem :show_all, 'Show All', preset: :show_all
    menuItem :quit, 'Quit'

    menuItem :services_item, 'Services', preset: :services

    menuItem :status_free, 'Free memory now'
    menuItem :status_preferences, 'Preferences'
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
  end

  def_menus
  def_items
end
