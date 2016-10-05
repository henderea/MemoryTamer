module LoggerClassMethods
  FLAGS = {
      :error   => (1<<0), # 0...00001
      :warn    => (1<<1), # 0...00010
      :info    => (1<<2), # 0...00100
      :debug   => (1<<3), # 0...01000
      :verbose => (1<<4) # 0...10000
  }

  LEVELS = {
      :off     => 0,
      :error   => FLAGS[:error],
      :warn    => FLAGS[:error] | FLAGS[:warn],
      :info    => FLAGS[:error] | FLAGS[:warn] | FLAGS[:info],
      :debug   => FLAGS[:error] | FLAGS[:warn] | FLAGS[:info] | FLAGS[:debug],
      :verbose => FLAGS[:error] | FLAGS[:warn] | FLAGS[:info] | FLAGS[:debug] | FLAGS[:verbose]
  }

  def level=(level)
    @level = level
  end

  def level
    @level
  end

  def async=(async)
    @async = async
  end

  def async
    @async
  end

  def error(message)
    __log(:error, message)
  end

  def warn(message)
    __log(:warn, message)
  end

  def info(message)
    __log(:info, message)
  end

  def debug(message)
    __log(:verbose, message)
  end

  alias_method :verbose, :debug

  def logging?(flag)
    (LEVELS[level] & FLAGS[flag]) > 0
  end

  protected
  def __log(flag, message)
    return unless logging?(flag)
    raise ArgumentError, "flag must be one of #{FLAGS.keys}" unless FLAGS.keys.include?(flag)
    async_enabled = self.async || (self.level == :error)
    message       = message.gsub('%', '%%')

    log(async_enabled,
        level:    LEVELS[level],
        flag:     FLAGS[flag],
        context:  0,
        file:     __FILE__,
        function: __method__,
        line:     __LINE__,
        tag:      0,
        format:   message)
  end
end

module Motion
  class Log < ::DDLog
    class << self
      alias_method :flush, :flushLog
    end

    extend LoggerClassMethods

    @async = true
    @level = :info
  end
end

class NSObject
  def to_weak
    WeakRef.new(self)
  end
end

class NSApplication
  def relaunchAfterDelay(seconds)
    task = NSTask.alloc.init
    args = []
    args << '-c'
    args << ('sleep %f; open "%s"' % [seconds, NSBundle.mainBundle.bundlePath])
    task.launchPath = '/bin/sh'
    task.arguments  = args
    task.launch

    self.terminate(nil)
  end
end

module Util
  module_function

  def run_task(path, *args)
    Util.log.debug "task: #{path}; args: #{args.inspect}"
    task            = NSTask.alloc.init
    task.launchPath = path
    task.arguments  = args.map { |v| v.to_s }
    task.launch
    Util.log.debug 'task launched'
    task.waitUntilExit
    Util.log.debug 'task finished'
  end

  def run_task_no_wait(path, *args)
    Util.log.debug "task: #{path}; args: #{args.inspect}"
    task            = NSTask.alloc.init
    task.launchPath = path
    task.arguments  = args
    task.launch
    Util.log.debug 'task launched'
  end

  def login_item_enabled?
    !SMJobCopyDictionary(KSMDomainUserLaunchd, 'us.myepg.MemoryTamer.MTLaunchHelper').nil?
  end

  def login_item_set_enabled(enabled)
    url = NSBundle.mainBundle.bundleURL.URLByAppendingPathComponent('Contents/Library/LoginItems/MTLaunchHelper.app', isDirectory: true)

    status = LSRegisterURL(url, true)
    unless status
      Util.log.error NSString.stringWithFormat("Failed to LSRegisterURL '%@': %jd", url, status)
      return false
    end

    success = SMLoginItemSetEnabled('us.myepg.MemoryTamer.MTLaunchHelper', enabled)
    unless success
      Util.log.error 'Failed to start MemoryTamer launch helper.'
      return false
    end
    true
  end

  def setup_licensing
    if self.verify_license
      # Util.log.info('Application is registered.')
      # self.shared_licensing_window_controller.isLicensed = true
      @licensed_cocoafob = true
    else
      # Util.log.info('Application not registered.')
      # self.shared_licensing_window_controller.isLicensed = false
      @licensed_cocoafob = false
    end
    MotionPaddle.will_show_licensing_window = !@licensed_cocoafob
    MotionPaddle.will_continue_at_trial_end = true
    MotionPaddle.setup { |_, _| MainMenu.set_license_display }
    MotionPaddle.listen(:deactivated) { |_, deactivated, deactivateMessage|
      if deactivated
        Util.log.info 'deactivated license'
        MainMenu.set_license_display
        MotionPaddle.show_licensing
      else
        Util.log.info "failed to deactivate license: #{deactivateMessage}"
      end
    }
    @licensing_listener = LicensingListener.new { |notification|
      # licenseWindowController = Util.shared_licensing_window_controller
      # Util.show_licensing_window(nil)

      isValidLicense = Util.verify_license

      @licensed_cocoafob = isValidLicense

      if isValidLicense
        alert = NSAlert.alertWithMessageText('Thank you for registering.', defaultButton: 'OK', alternateButton: nil, otherButton: nil, informativeTextWithFormat: '')
        alert.runModal
      else
        alert = NSAlert.alertWithMessageText('License not valid.', defaultButton: 'OK', alternateButton: nil, otherButton: nil, informativeTextWithFormat: '')
        alert.runModal
      end

      # licenseWindowController.showLicensedStatus(isValidLicense)
    }
    NSNotificationCenter.defaultCenter.addObserver(@licensing_listener, selector: 'registrationChanged:', name: 'XMDidChangeRegistrationNotification', object: nil)
  end

  def check_trial
    if self.licensed?
      nil
    else
      MotionPaddle.trial_days_left
    end
  end

  def licensed?
    self.licensed_paddle? || self.licensed_cocoafob?
  end

  def licensed_paddle?
    MotionPaddle.activated?
  end

  def licensed_cocoafob?
    @licensed_cocoafob
  end

  class LicensingListener
    def initialize(&block)
      @block = block
    end

    def registrationChanged(notification)
      @block.call(notification)
    end
  end

  # def show_licensing_window(sender)
  #   self.shared_licensing_window_controller.window.makeKeyAndOrderFront(nil)
  #   self.shared_licensing_window_controller.window.orderFrontRegardless
  # end

  def verify_license
    regCode = Persist.store.product_key
    name    = Persist.store.product_name

    # Here we match CocoaFob 's licensekey.rb "productname,username" format
    regName = "MemoryTamer,#{name}"

    publicKey = ''
    publicKey << 'MIHxMIGpBgcqhkjOOAQBM'
    publicKey << 'IGdAkEAoLPCAaL6VEQ'
    publicKey << 'lYpsX7vf9'
    publicKey << 'jpQY40Uj5b'
    publicKey << "UhmvNZ\njjcq2lTSlCnqBq"
    publicKey << 'v4nxhwROI'
    publicKey << 'UUj7wl3t'
    publicKey << 'AjKghnwDMv4VTIOXI+'
    publicKey << "QIVAPMOL+3NJ/iv\nVbwt"
    publicKey << 'HVNOiUvfUMWNAkEAkDashtS4IDsN+OsIwIElIxSVM1V'
    publicKey << "2rXgR+DqEfWNP4Kvy\n4hiQyTHMXl3JfSGhK+h5Y"
    publicKey << 'qE4w'
    publicKey << "P4SiqzyPoaRiPoL0gNDAAJASXVReQ4G3CCMVNTW\njY"
    publicKey << '052YGRF4qchbLtQk7ws7LnSh+cmqZAKc3fEW'
    publicKey << 'QZINC3d'
    publicKey << 'uCOsiM4'
    publicKey << "UuvwO6ZCDE9s\ndQ6W0Q==\n"

    publicKey = CFobLicVerifier.completePublicKeyPEM(publicKey)

    verifier = CFobLicVerifier.alloc.init
    verifier.setPublicKey(publicKey, error: nil)

    # verifier.regName = regName
    # verifier.regCode = regCode
    # Util.log.debug("publicKey #{publicKey}\nregCode: #{verifier.regCode}\nregName: #{verifier.regName}")

    verifier.verifyRegCode(regCode, forName: regName, error: nil)
  end

  # def shared_licensing_window_controller
  #   XMLicensingWindowController.sharedLicensingWindowController
  # end

  def log
    Motion::Log
  end

  def file_logger
    @file_logger
  end

  def setup_logging
    @file_logger                                        = DDFileLogger.new
    @file_logger.rollingFrequency                       = 60 * 60 * 24
    @file_logger.logFileManager.maximumNumberOfLogFiles = 7
    Util.log.addLogger @file_logger, withLogLevel: LoggerClassMethods::LEVELS[:verbose]

    tty_logger = DDTTYLogger.sharedInstance
    Util.log.addLogger tty_logger, withLogLevel: LoggerClassMethods::LEVELS[:verbose]

    asl_logger = DDASLLogger.sharedInstance
    Util.log.addLogger asl_logger, withLogLevel: LoggerClassMethods::LEVELS[:debug]

    Util.log.level = :verbose
  end

  def time_loop
    Thread.start {
      Info.start_time ||= NSDate.date
      loop do
        MainMenu[:license].items[:license_trial].updateDynamicTitle
        MainMenu[:statusbar].items[:status_mt_time].updateDynamicTitle
        sleep(0.5)
      end
    }
  end

  def relaunch_app
    NSApp.performSelectorOnMainThread('relaunchAfterDelay:', withObject: 1, waitUntilDone: true)
  end

  def freeing_loop
    Info.start_time ||= NSDate.date
    Thread.start {
      Info.last_free = NSDate.date - 30
      Info.last_trim = NSDate.date
      loop do
        mtm = MemInfo.getMTMemory
        mtcm = MemInfo.getMTCompressedMemory
        if mtm > (200 * (1024 ** 2)) && (NSDate.date - Info.start_time) > 300
          Util.log.warn "MemoryTamer is using #{Info.format_bytes(mtm, true).to_weak}; restarting".to_weak
          relaunch_app
        end
        if mtcm > (100 * (1024 ** 2)) && (NSDate.date - Info.start_time) > 300
          Util.log.warn "MemoryTamer is using #{Info.format_bytes(mtcm, true).to_weak} compressed; restarting".to_weak
          relaunch_app
        end
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
        cfm = Info.get_free_mem
        MainMenu.status_item.setTitle(Persist.store.show_mem? ? Info.format_bytes(cfm).to_weak : ''.to_weak) if Persist.store.update_while? || !Info.freeing?
        if Util.licensed? || Util.check_trial > 0
          diff   = (NSDate.date - Info.last_free)
          diff_t = (NSDate.date - Info.last_trim)
          if cfm <= Info.dfm && diff >= 60 && diff_t >= 30 && !Info.freeing? && !Info.paused?
            Util.log.info "seconds since last full freeing: #{diff}".to_weak
            Util.log.info "seconds since last trim: #{diff_t}".to_weak
            Util.free_mem_default
          elsif cfm <= Info.dtm && diff >= 30 && diff_t >= 30 && !Info.freeing? && !Info.paused?
            Util.log.info "seconds since last full freeing: #{diff}".to_weak
            Util.log.info "seconds since last trim: #{diff_t}".to_weak
            Util.trim_mem
          end
        end
        sleep(Persist.store.refresh_rate)
      end
    }
  end

  def nn_str(nn)
    {
        free_start: 'Start Freeing',
        trim_start: 'Start Freeing',
        free_end:   'Finish Freeing',
        trim_end:   'Finish Freeing',
        error:      'Error'
    }[nn]
  end

  def notify(msg, nn)
    enabled = nn == :error || Persist.store["#{nn}?"]
    Util.log.info "Notification (#{nn}=#{enabled.inspect}): #{msg}".to_weak
    if enabled
      if Persist.store.notifications == 'Growl'
        if GrowlApplicationBridge.isGrowlRunning
          ep = NSBundle.mainBundle.pathForResource('growlnotify', ofType: '')
          Util.log.debug ep
          args = []
          args << '-n'
          args << 'MemoryTamer'
          args << '-s' if Persist.store.growl_sticky?
          args << '-m'
          args << msg.to_s
          args << '-t'
          args << 'MemoryTamer'
          run_task_no_wait(ep, *args)
        else
          GrowlApplicationBridge.notifyWithTitle(
              'MemoryTamer',
              description:      msg.to_s,
              notificationName: nn_str(nn),
              iconData:         nil,
              priority:         0,
              isSticky:         Persist.store.growl_sticky?,
              clickContext:     nil)
        end
      elsif Persist.store.notifications == 'Notification Center'
        notification                 = NSUserNotification.alloc.init
        notification.title           = 'MemoryTamer'
        notification.informativeText = msg.to_s
        notification.soundName       = nil
        NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
      end
    end
  end

  def free_mem_default
    if Util.licensed? || Util.check_trial > 0
      Thread.start {
        cfm          = Info.get_free_mem
        Info.freeing = true
        notify 'Beginning memory freeing', :free_start
        free_mem(Persist.store.pressure)
        nfm = Info.get_free_mem
        Util.log.info "Freed #{Info.format_bytes(nfm - cfm, true)}".to_weak
        notify "Finished freeing #{Info.format_bytes(nfm - cfm)}".to_weak, :free_end
        Info.freeing   = false
        Info.last_free = NSDate.date
      }
    end
  end

  def trim_mem
    if Util.licensed? || Util.check_trial > 0
      Thread.start {
        cfm          = Info.get_free_mem
        Info.freeing = true
        notify 'Beginning memory trimming', :trim_start
        free_mem_old(true)
        nfm = Info.get_free_mem
        Util.log.info "Freed #{Info.format_bytes(nfm - cfm, true)}".to_weak
        notify "Finished trimming #{Info.format_bytes(nfm - cfm)}".to_weak, :trim_end
        Info.freeing   = false
        Info.last_trim = NSDate.date
      }
    end
  end

  def free_mem(pressure)
    if Util.licensed? || Util.check_trial > 0
      if Persist.store.freeing_method == 'memory pressure'
        cmp = Info.get_memory_pressure
        if cmp >= 4
          notify 'Memory Pressure too high! Running not a good idea.'.to_weak, :error
          return
        end
        dmp = pressure == 'normal' ? 1 : (pressure == 'warn' ? 2 : 4)
        if cmp >= dmp && Persist.store.auto_escalate?
          np = cmp == 1 ? 'warn' : 'critical'
          Util.log.warn "escalating freeing pressure from #{pressure} to #{np}".to_weak
          pressure = np
        end
        IO.popen("'memory_pressure' -l #{pressure}") { |pipe|
          pipe.sync = true
          pipe.each { |l|
            Util.log.verbose l
            if l.include?('Stabilizing at')
              Util.log.verbose 'Found stabilizing line; breaking'
              break
            end
          }
          Util.log.verbose 'Preparing to kill memory_pressure process'
          Process.kill 'SIGINT', pipe.pid
          Util.log.debug 'memory_pressure process ended'
        }
      else
        free_mem_old
      end
    end
  end

  def free_mem_old(trim = false)
    if Util.licensed? || Util.check_trial > 0
      mtf = trim ? [Info.get_free_mem(1) * 0.75, Info.get_free_mem(0.5)].min : Info.get_free_mem(0.9)
      ep  = NSBundle.mainBundle.pathForResource('inactive', ofType: '')
      Util.log.debug "'#{ep}' '#{mtf.to_s}'"
      run_task(ep, mtf.to_s)
    end
  end

  def set_icon
    image = nil
    if Persist.store.show_icon?
      if Persist.store.grayscale_icon?
        image = NSImage.imageNamed('StatusMono')
        image.setTemplate true
      else
        image = NSImage.imageNamed('Status')
      end
    end
    MainMenu.status_item.setImage(image)
  end

  def open_link(link)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(link));
  end

  def constrain_value_range(range, value, default)
    value ? (value < range.min && range.min) || (value > range.max && range.max) : default
  end

  def constrain_value_list(list, old_value, new_value, default)
    (list.include?(new_value)) ? new_value : (list.include?(old_value) ? old_value : default)
  end

  def constrain_value_list_enable_map(map, old_value, new_value, new_default, default)
    map[new_value || new_default] ? (new_value || new_default) : ((map[old_value] && old_value) || default)
  end

  def constrain_value_boolean(value, default, enable = true, enable_is_true = true)
    ((value.nil? ? default : value_to_bool(value)) ? (enable || !enable_is_true) : (!enable && !enable_is_true)) ? NSOnState : NSOffState
  end

  def value_to_bool(value)
    value && value != 0 && value != NSOffState
  end
end