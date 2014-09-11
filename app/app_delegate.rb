class AppDelegate
  attr_accessor :prefs

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    BITHockeyManager.sharedHockeyManager.configureWithIdentifier('128ebd3240db358d4b1ea5f228269de6')
    BITHockeyManager.sharedHockeyManager.crashManager.setAutoSubmitCrashReport(true)
    BITHockeyManager.sharedHockeyManager.startManager
    Util.setup_paddle
    if Info.paddle?
      SUUpdater.sharedUpdater.delegate = self
      dnc = NSNotificationCenter.defaultCenter
      bsp = BITSystemProfile.sharedSystemProfile
      # dnc.addObserver(bsp, selector: 'startUsage', name: NSApplicationDidBecomeActiveNotification, object: nil)
      dnc.addObserver(bsp, selector: 'stopUsage', name: NSApplicationWillTerminateNotification, object: nil)
      dnc.addObserver(bsp, selector: 'stopUsage', name: NSApplicationWillResignActiveNotification, object: nil)
      bsp.startUsage
    end
    Info.freeing = false
    Persist.store.load_prefs
    MainMenu.build!
    MenuActions.setup
    MainMenu[:statusbar].items[:status_version][:title] = "Current Version: #{Info.version}"
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self) if Info.has_nc?
    GrowlApplicationBridge.setGrowlDelegate(self)
    Util.freeing_loop
  end

  # noinspection RubyUnusedLocalVariable
  def feedParametersForUpdater(updater, sendingSystemProfile: sendingProfile)
      BITSystemProfile.sharedSystemProfile.systemUsageData
  end
end
