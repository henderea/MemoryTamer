module MenuActions
  module_function

  def setup
    setup_statusbar
    setup_license
    setup_support
  end

  def setup_statusbar
    MainMenu[:statusbar].subscribe(:status_free) { |_, _| Util.free_mem_default }.canExecuteBlock { |_| !Info.freeing? }
    MainMenu[:statusbar].subscribe(:status_trim) { |_, _| Util.trim_mem }.canExecuteBlock { |_| !Info.freeing? }
    MainMenu[:statusbar].subscribe(:status_purge) { |_, _| Util.purge }.canExecuteBlock { |_| !Info.freeing? }
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
    MainMenu[:license].subscribe(:license_change) { |_, _| MotionPaddle.show_licensing }
    MainMenu[:license].subscribe(:license_deactivate) { |_, _| MotionPaddle.deactivate_license }.canExecuteBlock { |_| MotionPaddle.activated? }
  end

  def setup_support
    MainMenu[:support].subscribe(:support_feedback) { |_, _| BITHockeyManager.sharedHockeyManager.feedbackManager.showFeedbackWindow }
    MainMenu[:support].subscribe(:support_twitter) { |_, _| Util.open_link('https://twitter.com/MemoryTamer') }
  end
end