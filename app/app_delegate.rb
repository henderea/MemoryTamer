class AppDelegate
  attr_accessor :free_display_title

  def applicationDidFinishLaunching(notification)
    # buildMenu
    # buildWindow
    @freeing = false
    MainMenu.build!
    MainMenu[:statusbar].subscribe(:status_free) { |_, _|
      Thread.start { free_mem_default(get_free_mem) }
    }.canExecuteBlock { |_| !@freeing }
    MainMenu[:statusbar].subscribe(:status_quit) { |_, _|
      NSApp.terminate
    }
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)
    @statusItem = MainMenu[:statusbar].statusItem
    pth         = File.expand_path('~/prefs.mtprefs')
    @mem        = 1024
    @pressure   = 'warn'
    unless File.exist?(pth)
      File.open(pth, mode_string='w+') { |io| io.puts('1024|warn') }
    end
    begin
      if File.exist?(pth)
        fc        = IO.read(pth).chomp
        pts       = fc.split(/\|/)
        @pressure = pts[1] if %w(normal warn critical).include?(pts[1].chomp)
        @mem      = pts[0].chomp.to_i
      end
    rescue
      # ignored
    end
    @dfm = @mem * 1024**2
    puts("Starting up with memory = #{@dfm}; pressure = #{@pressure}")
    Thread.start {
      @last_free = NSDate.date - 120
      loop do
        cfm = get_free_mem
        @statusItem.setTitle(format_bytes(cfm))
        # @statusItem.didChangeValueForKey('title')
        # @free_display.containedObject.setTitle("#{'%.1f' % (cfm / 1024**2)} MB free")
        # @free_display.containedObject.didChangeValueForKey('title')
        if cfm <= @dfm && (NSDate.date - @last_free) >= 60 && !@freeing
          Thread.start { free_mem_default(cfm) }
        end
        sleep(2)
      end
    }
  end

  def free_mem_default(cfm)
    @freeing = true
    notify 'Beginning memory freeing'
    free_mem(@pressure)
    nfm = get_free_mem
    notify "Finished freeing #{format_bytes(nfm - cfm)}"
    @freeing = false
    @last_free = NSDate.date
  end

  def format_bytes(bytes, show_raw = false)
    lg   = (Math.log(bytes)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB)[lg]
    "#{'%.2f' % (bytes.to_f / 1024.0**lg)} #{unit}#{show_raw ? " (#{bytes} B)" : ''}"
  end

  def get_free_mem
    vm_stat = `vm_stat`

    vm_stat = vm_stat.split("\n")

    page_size = vm_stat[0].match(/(\d+) bytes/)[1].to_i

    pages_free = vm_stat[1].match(/(\d+)/)[1].to_i
    #pages_inactive = vm_stat[3].match(/(\d+)/)[1].to_i

    page_size*pages_free #+ page_size*pages_inactive
  end

  def get_memory_pressure
    `/usr/sbin/sysctl kern.memorystatus_vm_pressure_level`.chomp.to_i
  end

  def free_mem(pressure)
    cmp = get_memory_pressure
    if cmp >= 4
      notify 'Memory Pressure too high! Running not a good idea.'
      return
    end
    dmp      = pressure == 'normal' ? 1 : (pressure == 'warn' ? 2 : 4)
    pressure = cmp == 1 ? 'warn' : 'critical' if cmp >= dmp
    IO.popen("memory_pressure -l #{pressure}") { |pipe|
      pipe.sync = true
      pipe.each { |l|
        puts l
        # if l.include?('CMD: Allocating pages')
        if l.include?('Stabilizing at')
          Process.kill 'SIGINT', pipe.pid
          break
        end
      }
    }
  end

  def notify(msg)
    notification                 = NSUserNotification.alloc.init
    notification.title           = 'MemoryTamer'
    notification.informativeText = msg
    notification.soundName       = NSUserNotificationDefaultSoundName
    NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
  end

  # def buildWindow
  #   @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
  #     styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
  #     backing: NSBackingStoreBuffered,
  #     defer: false)
  #   @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
  #   @mainWindow.orderFrontRegardless
  # end
end
