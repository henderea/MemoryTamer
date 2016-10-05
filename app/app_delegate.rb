# noinspection RubyUnusedLocalVariable
class AppDelegate
  def applicationDidFinishLaunching(notification)
    Util.setup_logging
    BITHockeyManager.sharedHockeyManager.configureWithIdentifier('128ebd3240db358d4b1ea5f228269de6', delegate: self)
    BITHockeyManager.sharedHockeyManager.crashManager.setAutoSubmitCrashReport(true)
    BITHockeyManager.sharedHockeyManager.startManager
    Util.setup_licensing
    SUUpdater.sharedUpdater.setDelegate(self)
    Info.freeing = false
    Persist.store.load_prefs
    MainMenu.build!
    MenuActions.setup
    MainMenu[:statusbar].items[:status_version][:title]      = "Current Version: #{Info.version}"
    MainMenu[:statusbar].items[:status_mem_physical][:title] = "Physical Memory: #{Info.format_bytes(Info.get_total_memory)}"
    MainMenu[:statusbar].items[:status_login][:state]        = Util.login_item_enabled? ? NSOnState : NSOffState
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)
    GrowlApplicationBridge.setGrowlDelegate(self)
    # MainMenu.status_item.setImage(Persist.store.show_icon? ? NSImage.imageNamed('Status') : nil)
    Util.set_icon
    Util.time_loop
    Util.freeing_loop
  end

  def feedParametersForUpdater(updater, sendingSystemProfile: sendingProfile)
    BITSystemProfile.sharedSystemProfile.systemUsageData
  end

  def getLatestLogFileContent
    description        = ''
    sortedLogFileInfos = Util.file_logger.logFileManager.sortedLogFileInfos
    sortedLogFileInfos.reverse_each { |logFileInfo|
      logData = NSFileManager.defaultManager.contentsAtPath logFileInfo.filePath
      if logData.length > 0
        description = NSString.alloc.initWithBytes(logData.bytes, length: logData.length, encoding: NSUTF8StringEncoding)
        break
      end
    }
    description
  end

  def applicationLogForCrashManager(crashManager)
    description = self.getLatestLogFileContent
    if description.nil? || description.length <= 0
      nil
    else
      description
    end
  end
end
