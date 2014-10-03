class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :status_free, 'Free memory now'
    menuItem :status_trim, 'Trim memory now'
    menuItem :status_mt_mem, 'memory usage: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "memory usage: #{Info.format_bytes(MemInfo.getMTMemory)}" }
    menuItem :status_relaunch, 'Relaunch MemoryTamer'
    menuItem :status_update, 'Check for Updates'
    menuItem :status_version, 'Current Version: 0.0'
    menuItem :status_review, 'Write a review'
    menuItem :status_quit, 'Quit', preset: :quit

    menuItem :status_preferences, 'Preferences'

    menuItem :status_license, 'Registration', submenu: :license
    menuItem :license_display, 'Not Registered'
    menuItem :license_change, 'Buy / Register'

    menuItem :status_support, 'Support', submenu: :support
    # menuItem :support_ticket, 'Submit bug or feature request'
    menuItem :support_feedback, 'Provide Feedback'
    # menuItem :support_usage, 'Using MemoryTamer'
    menuItem :support_twitter, 'Twitter'
  end

  def self.def_menus
    statusbarMenu(:statusbar, '', status_item_icon: NSImage.imageNamed('Status'), status_item_length: NSVariableStatusItemLength) {
      status_free
      status_trim
      ___
      status_mt_mem
      status_relaunch
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
      status_review
      ___
      status_quit
    }

    menu(:license, 'Registration') {
      license_display
      license_change
    }

    menu(:support, 'Support') {
      # support_ticket
      support_feedback
      # support_usage
      support_twitter
    }
  end

  def_menus
  def_items

  class << self
    def status_item
      MainMenu[:statusbar].statusItem
    end

    def set_license_display
      Thread.start {
        paddle                                             = Paddle.sharedInstance
        activated                                          = paddle.productActivated
        MainMenu[:license].items[:license_display][:title] = activated ? paddle.activatedEmail : 'Not Registered'
        MainMenu[:license].items[:license_change][:title]  = activated ? 'View Registration' : 'Buy / Register'
      }
    end
  end
end
