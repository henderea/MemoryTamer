class AppDelegate
  attr_accessor :free_display_title

  # noinspection RubyUnusedLocalVariable
  def applicationDidFinishLaunching(notification)
    Util.setup_paddle
    SUUpdater.sharedUpdater
    Info.freeing = false
    Persist.load_prefs
    MainMenu.build!
    MenuActions.setup
    MainMenu.set_all_displays
    MainMenu[:statusbar].items[:status_version][:title] = "Current Version: #{NSBundle.mainBundle.infoDictionary['CFBundleVersion']}"
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self) if Info.has_nc?
    GrowlApplicationBridge.setGrowlDelegate(self)
    NSLog "Starting up with memory = #{Info.dfm}; pressure = #{Persist.pressure}"
    Util.freeing_loop
  end
end
