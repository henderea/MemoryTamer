module Info
  module_function

  def last_free
    @last_free
  end

  def last_free=(last_free)
    @last_free = last_free
  end

  def last_trim
    @last_trim
  end

  def last_trim=(last_trim)
    @last_trim = last_trim
  end

  def dfm
    Persist.mem * 1024**2
  end

  def dtm
    Persist.trim_mem * 1024**2
  end

  def get_free_mem(inactive_multiplier = 0)
    page_size      = WeakRef.new(`vm_stat | grep 'page size' | awk '{ print $8 }'`).chomp!.to_i
    pages_free     = WeakRef.new(`vm_stat | grep 'Pages free' | awk '{ print $3 }'`).chomp![0...-1].to_i
    pages_inactive = WeakRef.new(`vm_stat | grep 'Pages inactive' | awk '{ print $3 }'`).chomp![0...-1].to_i

    page_size*pages_free + page_size*pages_inactive*inactive_multiplier
  end

  def format_bytes(bytes, show_raw = false)
    return "#{bytes} B" if bytes <= 1
    lg   = (Math.log(bytes)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB)[lg]
    "#{'%.2f' % (bytes.to_f / 1024.0**lg)} #{unit}#{show_raw ? " (#{bytes} B)" : ''}"
  end

  def sysctl_get(name)
    `/usr/sbin/sysctl '#{name}' | awk '{ print $2 }'`.chomp!
  end

  def get_memory_pressure
    sysctl_get('kern.memorystatus_vm_pressure_level').to_i
  end

  def get_total_memory
    sysctl_get('hw.memsize').to_i
  end

  def freeing=(freeing)
    @freeing = freeing
  end

  def freeing?
    @freeing
  end

  class Version
    def initialize(version)
      @version = version || '0.0'
    end

    def <=>(other)
      other = Version.new(other && other.to_s)
      p     = parts
      op    = other.parts
      p <=> op
    end

    def <(other)
      (self <=> other) < 0
    end

    def <=(other)
      (self <=> other) <= 0
    end

    def ==(other)
      (self <=> other) == 0
    end

    def >(other)
      (self <=> other) > 0
    end

    def >=(other)
      (self <=> other) >= 0
    end

    def parts
      @version.split(/\./).map(&:to_i)
    end

    def to_s
      @version
    end
  end

  def version
    @version ||= Version.new(NSBundle.mainBundle.infoDictionary['CFBundleVersion'])
  end

  def last_version
    @last_version ||= Version.new(nil)
  end

  def last_version=(last_version)
    @last_version = Version.new(last_version)
  end

  class Supports
    attr_reader :nc, :mavericks

    def initialize
      @nc = (NSClassFromString('NSUserNotificationCenter')!=nil)
      system('which memory_pressure')
      @mavericks = $?.success?
    end
  end

  def supports
    @supports ||= Supports.new
  end

  def has_nc?
    supports.nc
  end

  def mavericks?
    supports.mavericks
  end

end