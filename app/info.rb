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

  def start_time
    @start_time
  end

  def start_time=(start_time)
    @start_time = start_time
  end

  def dfm
    Persist.store.mem * 1024**2
  end

  def dtm
    Persist.store.trim_mem * 1024**2
  end

  def get_free_mem(inactive_multiplier = 0)
    page_size      = MemInfo.getPageSize
    pages_free     = MemInfo.getPagesFree
    pages_inactive = MemInfo.getPagesInactive
    page_size * pages_free + page_size * pages_inactive * inactive_multiplier
  end

  def get_memory_pressure
    MemInfo.getMemoryPressure
  end

  def get_total_memory
    MemInfo.getTotalMemory
  end

  def format_bytes(bytes, show_raw = false)
    return "#{bytes} B" if bytes.abs <= 1
    lg   = (Math.log(bytes.abs)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB PB EB ZB YB)[lg]
    "#{"%.#{show_raw ? '3' : Persist.store.mem_places.to_s}f" % (bytes.to_f / 1024.0**lg)} #{unit}#{show_raw ? " (#{bytes} B)" : ''}"
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
      @version.gsub(/^(\d+)([^.]*)$/, '\1.0.0\3').gsub(/^(\d+)\.(\d+)([^.]*)$/, '\1.\2.0\3').gsub(/\.(\d+)b(\d+)$/, '.-1.\1.\2').split(/\./).map(&:to_i)
    end

    def to_s
      @version
    end
  end

  def version
    @version ||= Version.new(NSBundle.mainBundle.infoDictionary['CFBundleShortVersionString'])
  end

  def last_version
    @last_version ||= Version.new(self.version.to_s)
  end

  def last_version=(last_version)
    @last_version = Version.new(last_version || self.version.to_s)
  end

  def os_version
    @os_version ||= Version.new(MemInfo.getOSVersion)
  end

  class Supports
    attr_reader :nc, :mavericks

    def initialize
      @nc        = (NSClassFromString('NSUserNotificationCenter')!=nil)
      @mavericks = Info.os_version >= '13'
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