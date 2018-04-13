# noinspection RubyUnusedLocalVariable
class AppDelegate
  def applicationDidFinishLaunching(notification)
    Util.setup_logging
    BITHockeyManager.sharedHockeyManager.configureWithIdentifier('128ebd3240db358d4b1ea5f228269de6', delegate: self)
    BITHockeyManager.sharedHockeyManager.crashManager.setAutoSubmitCrashReport(true)
    BITHockeyManager.sharedHockeyManager.startManager
    Util.setup_licensing { |_, _| MainMenu.set_license_display }
    SUUpdater.sharedUpdater.setDelegate(self)
    Info.freeing = false
    Persist.store.load_prefs
    Persist.store.no_refresh {
      Persist.store.listen(:display_what, :mem_places) { |_, _, _| MainMenu.status_item.setTitle(Persist.store.show_mem? ? Info.format_bytes(Info.get_free_mem) : '') }
      Persist.store.listen(:display_what, :grayscale_icon) { |_, _, _| MainMenu.set_icon }
    }
    MainMenu.build!
    MenuActions.setup
    MainMenu[:statusbar].items[:status_version][:title]      = "Current Version: #{Version.current}"
    MainMenu[:statusbar].items[:status_mem_physical][:title] = "Physical Memory: #{Info.format_bytes(Info.get_total_memory)}"
    MainMenu[:statusbar].items[:status_login][:state]        = Util.login_item_enabled? ? NSOnState : NSOffState
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)
    GrowlApplicationBridge.setGrowlDelegate(self)
    # MainMenu.status_item.setImage(Persist.store.show_icon? ? NSImage.imageNamed('Status') : nil)
    MainMenu.set_icon
    Util.time_loop {
      MainMenu[:license].items[:license_trial].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mt_time].updateDynamicTitle
    }
    Util.freeing_loop { |cfm|
      MainMenu[:statusbar].items[:status_mt_mem].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mtc_mem].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mtd_mem].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mti_mem].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mte_mem].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_used].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_virtual].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_swap].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_pressure_percent].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_app_mem].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_file_cache].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_wired].updateDynamicTitle
      MainMenu[:statusbar].items[:status_mem_compressed].updateDynamicTitle
      MainMenu.status_item.setTitle(Persist.store.show_mem? ? Info.format_bytes(cfm).to_weak : ''.to_weak) if Persist.store.update_while? || !Info.freeing?
    }
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
