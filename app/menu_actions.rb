module MenuActions
  module_function

  def setup
    setup_statusbar
    setup_license
    setup_support
  end

  def setup_statusbar
    MainMenu[:statusbar].subscribe(:status_free) { |_, _|
      Util.free_mem_default
    }.canExecuteBlock { |_| !Info.freeing? }
    MainMenu[:statusbar].subscribe(:status_trim) { |_, _|
      Util.trim_mem
    }.canExecuteBlock { |_| !Info.freeing? }
    MainMenu[:statusbar].subscribe(:status_preferences) { |_, _|
      Prefs.shared_instance.show_window
    }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _|
      NSApp.terminate
    }
    MainMenu[:statusbar].subscribe(:status_update) { |_, sender|
      SUUpdater.sharedUpdater.checkForUpdates(sender)
    }.canExecuteBlock { |_| Info.paddle? }
  end

  def setup_license
    MainMenu.set_license_display
    MainMenu[:license].subscribe(:license_change) { |_, _|
      Paddle.sharedInstance.showLicencing
    }.canExecuteBlock { |_| Info.paddle? }
  end

  def setup_support
    MainMenu[:support].subscribe(:support_ticket) { |_, _| Util.open_link('https://github.com/henderea/MemoryTamer/issues/new') }
    # MainMenu[:support].subscribe(:support_usage) { |_, _| Util.open_link('https://github.com/henderea/MemoryTamer/blob/master/USING.md') }
    MainMenu[:support].subscribe(:support_twitter) { |_, _| Util.open_link('https://twitter.com/MemoryTamer') }
  end
end