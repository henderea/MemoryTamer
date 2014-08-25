class AppDelegate
  attr_accessor :free_display_title

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    Util.setup_paddle
    SUUpdater.sharedUpdater if Info.paddle?
    Info.freeing = false
    Persist.store.load_prefs
    MainMenu.build!
    MenuActions.setup
    MainMenu[:statusbar].items[:status_version][:title] = "Current Version: #{Info.version}"
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self) if Info.has_nc?
    GrowlApplicationBridge.setGrowlDelegate(self)
    Util.freeing_loop
  end
end
