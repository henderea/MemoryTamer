module MenuActions
  module_function

  def setup
    setup_statusbar
    setup_license
    setup_support
  end

  def setup_statusbar
    MainMenu[:statusbar].subscribe(:status_pause) { |_, _|
      Info.paused = MainMenu[:statusbar].items[:status_pause][:state] == NSOffState
      MainMenu[:statusbar].items[:status_pause][:state] = Info.paused? ? NSOnState : NSOffState
    }
    MainMenu[:statusbar].subscribe(:status_free) { |_, _| Util.free_mem_default }.canExecuteBlock { |_| !Info.freeing? && (Util.licensed? || Util.check_trial > 0) }
    MainMenu[:statusbar].subscribe(:status_trim) { |_, _| Util.trim_mem }.canExecuteBlock { |_| !Info.freeing? && (Util.licensed? || Util.check_trial > 0) }
    MainMenu[:statusbar].subscribe(:status_relaunch) { |_, _| Util.relaunch_app }
    MainMenu[:statusbar].subscribe(:status_login) { |_, _|
      Util.login_item_set_enabled(MainMenu[:statusbar].items[:status_login][:state] == NSOffState)
      MainMenu[:statusbar].items[:status_login][:state] = Util.login_item_enabled? ? NSOnState : NSOffState
    }
    MainMenu[:statusbar].subscribe(:status_preferences) { |_, _| Prefs.shared_instance.show_window }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _| NSApp.terminate }
    MainMenu[:statusbar].subscribe(:status_update) { |_, sender| SUUpdater.sharedUpdater.checkForUpdates(sender) }
    # MainMenu[:statusbar].subscribe(:status_vote) { |_, _| Util.open_link('http://tiny.cc/MTNextFeature') }
    MainMenu[:statusbar].subscribe(:status_review) { |_, _| Util.open_link('http://www.macupdate.com/app/mac/51681/memorytamer') }
  end

  def setup_license
    MainMenu.set_license_display
    MainMenu[:license_paddle].subscribe(:license_paddle_change) { |_, _| MotionPaddle.show_licensing }
    MainMenu[:license_paddle].subscribe(:license_paddle_deactivate) { |_, _| MotionPaddle.deactivate_license }.canExecuteBlock { |_| MotionPaddle.activated? }
    # MainMenu[:license_fastspring].subscribe(:license_fastspring_change) { |_, _| Util.show_licensing_window(nil) }
    MainMenu[:license_fastspring].subscribe(:license_fastspring_webstore) { |_, _| Util.open_link('http://sites.fastspring.com/memorytamer/product/memorytamer') }
  end

  def setup_support
    MainMenu[:support].subscribe(:support_feedback) { |_, _| BITHockeyManager.sharedHockeyManager.feedbackManager.showFeedbackWindow }
    MainMenu[:support].subscribe(:support_twitter) { |_, _| Util.open_link('https://twitter.com/MemoryTamer') }
  end
end