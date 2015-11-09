class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :hide_others, 'Hide Others', preset: :hide_others
    menuItem :show_all, 'Show All', preset: :show_all
    menuItem :close, 'Close', preset: :close
    menuItem :quit, 'Quit', preset: :quit

    menuItem :services_item, 'Services', preset: :services

    menuItem :status_mem_pressure_percent, 'Memory pressure: 0%', dynamic_title: -> { "Memory pressure: #{Info.get_memory_pressure_percent}%".to_weak }
    menuItem :status_mem_physical, 'Physical Memory: 0B'
    menuItem :status_mem_used, 'Memory Used: 0B', dynamic_title: -> { "Memory Used: #{Info.format_bytes(Info.get_used_mem).to_weak}".to_weak }
    menuItem :status_mem_virtual, 'Virtual Memory: 0B', dynamic_title: -> { "Virtual Memory: #{Info.format_bytes(Info.get_total_memory+Info.get_compressor_mem).to_weak}".to_weak }
    menuItem :status_mem_swap, 'Swap Used: 0B', dynamic_title: -> { "Swap Used: #{Info.format_bytes(Info.get_swap_mem).to_weak}".to_weak }
    menuItem :status_mem_app_mem, 'App Memory: 0B', dynamic_title: -> { "App Memory: #{Info.format_bytes(Info.get_app_mem).to_weak}".to_weak }
    menuItem :status_mem_file_cache, 'File Cache: 0B', dynamic_title: -> { "File Cache: #{Info.format_bytes(Info.get_file_cache_mem).to_weak}".to_weak }
    menuItem :status_mem_wired, 'Wired Memory: 0B', dynamic_title: -> { "Wired Memory: #{Info.format_bytes(Info.get_wired_mem).to_weak}".to_weak }
    menuItem :status_mem_compressed, 'Compressed: 0B', dynamic_title: -> { "Compressed: #{Info.format_bytes(Info.get_compressed_mem).to_weak}".to_weak }
    menuItem :status_pause, 'Pause automatic freeing/trimming', state: NSOffState
    menuItem :status_free, 'Free memory now'
    menuItem :status_trim, 'Trim memory now'
    menuItem :status_mt_mem, 'memory usage: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "memory usage: #{Info.format_bytes(MemInfo.getMTMemory).to_weak}".to_weak }
    menuItem :status_mtc_mem, 'compressed memory: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "compressed memory: #{Info.format_bytes(MemInfo.getMTCompressedMemory).to_weak}".to_weak }
    menuItem :status_mtd_mem, 'device memory: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "device memory: #{Info.format_bytes(MemInfo.getMTDeviceMemory).to_weak}".to_weak }, opt: true
    menuItem :status_mti_mem, 'internal memory: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "internal memory: #{Info.format_bytes(MemInfo.getMTInternalMemory).to_weak}".to_weak }, opt: true
    menuItem :status_mte_mem, 'external memory: 0B', image: NSImage.imageNamed('Status'), dynamic_title: -> { "external memory: #{Info.format_bytes(MemInfo.getMTExternalMemory).to_weak}".to_weak }, opt: true
    menuItem :status_mt_time, 'running since: 0d 0h 0m 0s', image: NSImage.imageNamed('Status'), dynamic_title: -> {
                              diff = (NSDate.date - Info.start_time).to_f
                              "running since #{MainMenu.get_time_display(diff).to_weak}".to_weak
                            }
    menuItem :status_relaunch, 'Relaunch MemoryTamer'
    menuItem :status_login, 'Launch on login', state: NSOffState
    menuItem :status_update, 'Check for Updates'
    menuItem :status_version, 'Current Version: 0.0'
    menuItem :status_review, 'Write a review'
    # menuItem :status_vote, 'Vote on next feature'
    menuItem :status_quit, 'Quit', preset: :quit

    menuItem :status_preferences, 'Preferences'

    menuItem :status_license, 'Registration', submenu: :license
    menuItem :license_trial, 'Trial Days Left: 7', dynamic_title: -> {
                             tdr = Util.check_trial
                             tdr.nil? ? 'Licensed' : (tdr < 0 ? 'Trial expired' : "Trial Days Left: #{tdr}".to_weak)
                           }
    menuItem :license_paddle, 'Paddle', submenu: :license_paddle
    menuItem :license_paddle_display, 'Not Registered'
    menuItem :license_paddle_change, 'Buy / Register'
    menuItem :license_paddle_deactivate, 'Deactivate License'
    menuItem :license_fastspring, 'FastSpring', submenu: :license_fastspring
    menuItem :license_fastspring_display, 'Not Registered'
    menuItem :license_fastspring_change, 'Register'
    menuItem :license_fastspring_webstore, 'Web Store'

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
      status_mem_physical
      status_mem_used
      status_mem_virtual
      status_mem_swap
      ___
      status_mem_pressure_percent
      ___
      status_mem_app_mem
      status_mem_file_cache
      status_mem_wired
      status_mem_compressed
      ___
      status_pause
      status_free
      status_trim
      ___
      status_mt_mem
      status_mtc_mem
      status_mtd_mem
      status_mti_mem
      status_mte_mem
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
      # status_vote
      status_review
      ___
      status_quit
    }

    menu(:license, 'Registration') {
      license_trial
      ___
      license_paddle
      ___
      license_fastspring
    }

    menu(:license_paddle, 'Paddle') {
      license_paddle_display
      license_paddle_change
      license_paddle_deactivate
    }

    menu(:license_fastspring, 'FastSpring') {
      license_fastspring_display
      license_fastspring_change
      license_fastspring_webstore
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
        activated_paddle                                                         = Util.licensed_paddle?
        MainMenu[:license_paddle].items[:license_paddle_display][:title]         = activated_paddle ? MotionPaddle.activated_email.to_weak : 'Not Registered'.to_weak
        MainMenu[:license_paddle].items[:license_paddle_change][:title]          = activated_paddle ? 'View Registration'.to_weak : 'Buy / Register'.to_weak
        activated_fastspring                                                     = Util.licensed_cocoafob?
        MainMenu[:license_fastspring].items[:license_fastspring_display][:title] = activated_fastspring ? Persist.store.product_name.to_weak : 'Not Registered'.to_weak
        MainMenu[:license_fastspring].items[:license_fastspring_change][:title]  = activated_fastspring ? 'View Registration'.to_weak : 'Buy / Register'.to_weak
        MainMenu[:license].items[:license_trial].updateDynamicTitle
      }
    end

    def get_time_display(diff)
      "#{(diff / (86400.0)).floor}d #{((diff % (86400.0))/(3600.0)).floor}h #{((diff % (3600.0))/60.0).floor}m #{(diff % 60).floor}s".to_weak
    end
  end
end
