module MenuActions
  module_function

  def setup
    setup_statusbar
    setup_license
    # setup_prefs
    setup_support
  end

  def setup_statusbar
    MainMenu[:statusbar].subscribe(:status_free) { |_, _|
      Util.free_mem_default
    }.canExecuteBlock { |_| !Info.freeing? }
    MainMenu[:statusbar].subscribe(:status_trim) { |_, _|
      Util.trim_mem
    }.canExecuteBlock { |_| !Info.freeing? }
    MainMenu[:statusbar].subscribe(:status_preferences) { |_, sender|
      # Prefs.sharedInstance.show_window
      Prefs.shared_instance.showWindow(sender)
    }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _|
      NSApp.terminate
    }
    MainMenu[:statusbar].subscribe(:status_update) { |_, sender|
      SUUpdater.sharedUpdater.checkForUpdates(sender)
    }
  end

  def setup_license
    MainMenu[:license].subscribe(:license_change) { |_, _|
      Paddle.sharedInstance.showLicencing
    }
  end

  # def setup_prefs
  #   MainMenu[:prefs].subscribe(:notification_change) { |_, _|
  #     Persist.growl = !Persist.growl?
  #   }.canExecuteBlock { |_| Info.has_nc? }
  #   MainMenu[:prefs].subscribe(:memory_change) { |_, _|
  #     nm          = Util.get_input('Please enter the memory threshold in MB', "#{Persist.mem}", :int, min: 0, max: (Info.get_total_memory / 1024**2))
  #     Persist.mem = nm if nm
  #   }
  #   MainMenu[:prefs].subscribe(:trim_change) { |_, _|
  #     nm               = Util.get_input('Please enter the memory trim threshold in MB', "#{Persist.trim_mem}", :int, min: 0, max: (Info.get_total_memory / 1024**2))
  #     Persist.trim_mem = nm if nm
  #   }
  #   MainMenu[:prefs].subscribe(:auto_change) { |_, _|
  #     np = get_input('Please select the auto-threshold target level', Persist.auto_threshold, :select, values: %w(off low high))
  #     if np
  #       if %w(off low high).include?(np)
  #         Persist.auto_threshold = np
  #       else
  #         Util.alert("Invalid option '#{np}'!")
  #       end
  #     end
  #   }.canExecuteBlock { |_| Info.mavericks? }
  #   MainMenu[:prefs].subscribe(:pressure_change) { |_, _|
  #     np = Util.get_input('Please select the freeing pressure', Persist.pressure, :select, values: %w(normal warn critical))
  #     if np
  #       if %w(normal warn critical).include?(np)
  #         Persist.pressure = np
  #       else
  #         Util.alert("Invalid option '#{np}'!")
  #       end
  #     end
  #   }.canExecuteBlock { |_| Info.mavericks? }
  #   MainMenu[:prefs].subscribe(:method_change) { |_, _|
  #     Persist.method_pressure = !Persist.method_pressure?
  #   }.canExecuteBlock { |_| Info.mavericks? }
  #   MainMenu[:prefs].subscribe(:escalate_display) { |command, _|
  #     Persist.auto_escalate = command.parent[:state] == NSOffState
  #   }.canExecuteBlock { |_| Info.mavericks? }
  #   MainMenu[:prefs].subscribe(:show_display) { |command, _|
  #     Persist.show_mem = command.parent[:state] == NSOffState
  #   }
  #   MainMenu[:prefs].subscribe(:update_display) { |command, _|
  #     Persist.update_while = command.parent[:state] == NSOffState
  #   }
  #   MainMenu[:prefs].subscribe(:sticky_display) { |command, _|
  #     Persist.sticky = command.parent[:state] == NSOffState
  #   }
  # end

  def setup_support
    MainMenu[:support].subscribe(:support_ticket) { |_, _|
      Util.open_link('https://github.com/henderea/MemoryTamer/issues/new')
    }
    MainMenu[:support].subscribe(:support_usage) { |_, _|
      Util.open_link('https://github.com/henderea/MemoryTamer/blob/master/USING.md')
    }
  end
end