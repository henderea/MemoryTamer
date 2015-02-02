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
    mem_free       = get_total_memory - get_used_mem
    mem_file_cache = get_file_cache_mem
    mem_free + mem_file_cache * inactive_multiplier
  end

  def get_used_mem
    page_size  = MemInfo.getPageSize
    pages_used = MemInfo.getPagesUsed
    page_size * pages_used
  end

  def get_file_cache_mem
    page_size        = MemInfo.getPageSize
    pages_file_cache = MemInfo.getPagesFileCache
    page_size * pages_file_cache
  end

  def get_app_mem
    page_size = MemInfo.getPageSize
    pages_app = MemInfo.getPagesAppMemory
    page_size * pages_app
  end

  def get_wired_mem
    page_size   = MemInfo.getPageSize
    pages_wired = MemInfo.getPagesWired
    page_size * pages_wired
  end

  def get_compressed_mem
    page_size        = MemInfo.getPageSize
    pages_compressed = MemInfo.getPagesCompressed
    page_size * pages_compressed
  end

  def get_compressor_mem
    page_size           = MemInfo.getPageSize
    pages_in_compressor = MemInfo.getPagesInCompressor
    page_size * pages_in_compressor
  end

  def get_swap_mem
    page_size     = MemInfo.getPageSize
    pages_in_swap = MemInfo.getPagesInSwap
    page_size * pages_in_swap
  end

  def get_memory_pressure
    MemInfo.getMemoryPressure
  end

  def get_memory_pressure_percent
    MemInfo.getMemoryPressurePercent
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

  def license_log_status
    @license_log_status ||= :not_logged
  end

  def license_log_status=(status)
    @license_log_status = status
  end

end