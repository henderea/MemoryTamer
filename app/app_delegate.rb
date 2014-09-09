class AppDelegate
  attr_accessor :prefs

  BITCrashManagerStatusDisabled = 0
  BITCrashManagerStatusAlwaysAsk = 1
  BITCrashManagerStatusAutoSend = 2

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    BITHockeyManager.sharedHockeyManager.configureWithIdentifier('128ebd3240db358d4b1ea5f228269de6')
    # BITHockeyManager.sharedHockeyManager.crashManager.crashManagerStatus = BITCrashManagerStatusAutoSend
    BITHockeyManager.sharedHockeyManager.startManager
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
