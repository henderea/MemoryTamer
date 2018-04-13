module Info
  module_function

  def paused?
    @paused
  end

  def paused=(paused)
    @paused = paused
  end

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
    r    = `/usr/sbin/sysctl 'vm.swapusage' | awk '{print $7;}'`.chomp
    unit = r[-1]
    rf   = r[0...-1].to_f
    ind  = %w(B K M G T).find_index(unit.upcase).to_f
    rf * (1024.0 ** ind)
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
    return "#{bytes} B".to_weak if bytes.abs <= 1
    lg   = (Math.log(bytes.abs)/Math.log(1024)).floor.to_f
    unit = %w(B KB MB GB TB PB EB ZB YB)[lg].to_weak
    "#{"%.#{show_raw ? '3'.to_weak : Persist.store.mem_places.to_s.to_weak}f".to_weak % (bytes.to_f / 1024.0**lg)} #{unit}#{show_raw ? " (#{bytes} B)".to_weak : ''.to_weak}".to_weak
  end

  def freeing=(freeing)
    @freeing = freeing
  end

  def freeing?
    @freeing
  end

  def os_version
    @os_version ||= Version.new(MemInfo.getOSVersion)
  end
end