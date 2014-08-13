class NSObject
  def to_weak
    WeakRef.new(self)
  end
end

class NSApplication
  # -(void) relaunchAfterDelay : (float) seconds
  # {
  #     NSTask *task = [[[NSTask alloc] init] autorelease];
  # NSMutableArray *args = [NSMutableArray array];
  # [args addObject: @ "-c"];
  # [args addObject: [NSString stringWithFormat: @ "sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
  # [task setLaunchPath: @ "/bin/sh"];
  # [task setArguments: args];
  # [task launch];
  #
  # [self terminate : nil];
  # }
  def relaunchAfterDelay(seconds)
    task = NSTask.alloc.init
    args = []
    args << '-c'
    args << ('sleep %f; open "%s"' % [seconds, NSBundle.mainBundle.bundlePath])
    task.launchPath = '/bin/sh'
    task.arguments = args
    task.launch

    self.terminate(nil)
  end
end

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
    # MainMenu.set_all_displays
    MainMenu[:statusbar].items[:status_version][:title] = "Current Version: #{Info.version}"
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self) if Info.has_nc?
    GrowlApplicationBridge.setGrowlDelegate(self)
    NSLog "Starting up with memory = #{Info.dfm}; pressure = #{Persist.pressure}"
    Util.freeing_loop
  end
end
