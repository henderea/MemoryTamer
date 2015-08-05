class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :hide_others, 'Hide Others', preset: :hide_others
    menuItem :show_all, 'Show All', preset: :show_all
    menuItem :close, 'Close', preset: :close
    menuItem :quit, 'Quit', preset: :quit

    menuItem :services_item, 'Services', preset: :services

    menuItem :status_free, 'Free memory now'
    menuItem :status_trim, 'Trim memory now'
    menuItem :status_mt_mem, 'memory usage: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "memory usage: #{Info.format_bytes(MemInfo.getMTMemory)}" }
    menuItem :status_mt_time, 'running since: 0d 0h 0m 0s', image: NSImage.imageNamed('Status'), dynamic_title: -> {
      diff = (NSDate.date - Info.start_time).to_f
      "running since #{(diff / (86400.0)).floor}d #{((diff % (86400.0))/(3600.0)).floor}h #{((diff % (3600.0))/60.0).floor}m #{(diff % 60).floor}s"
    }
    menuItem :status_relaunch, 'Relaunch MemoryTamer'
    menuItem :status_login, 'Launch on login', state: NSOffState
    menuItem :status_update, 'Check for Updates'
    menuItem :status_version, 'Current Version: 0.0'
    menuItem :status_review, 'Write a review'
    menuItem :status_vote, 'Vote on next feature'
    menuItem :status_quit, 'Quit', preset: :quit

    menuItem :status_preferences, 'Preferences'

    menuItem :status_license, 'Registration', submenu: :license
    menuItem :license_display, 'Not Registered'
    menuItem :license_change, 'Buy / Register'
    menuItem :license_deactivate, 'Deactivate License'

    menuItem :status_support, 'Support', submenu: :support
    menuItem :support_feedback, 'Provide Feedback'
    menuItem :support_twitter, 'Twitter'
  end

  def self.def_menus
    mainMenu(:app, 'MemoryTamer') {
      hide_others
      show_all
      ___
      services_item
      ___
      close
      ___
      quit
    }

    statusbarMenu(:statusbar, '', status_item_icon: NSImage.imageNamed('Status'), status_item_length: NSVariableStatusItemLength) {
      status_free
      status_trim
      ___
      status_mt_mem
      status_mt_time
      status_relaunch
      ___
      status_preferences
      status_login
      ___
      status_license
      ___
      status_support
      ___
      status_update
      status_version
      ___
      status_vote
      status_review
      ___
      status_quit
    }

    menu(:license, 'Registration') {
      license_display
      license_change
      license_deactivate
    }

    menu(:support, 'Support') {
      support_feedback
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
        activated                                          = MotionPaddle.activated?
        MainMenu[:license].items[:license_display][:title] = activated ? MotionPaddle.activated_email : 'Not Registered'
        MainMenu[:license].items[:license_change][:title]  = activated ? 'View Registration' : 'Buy / Register'
        Util.log_license
      }
    end
  end
end
