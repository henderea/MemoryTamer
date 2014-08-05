class NSUserDefaults

  # Retrieves the object for the passed key
  def [](key)
    self.objectForKey(key.to_s)
  end

  # Sets the value for a given key and save it right away.
  def []=(key, val)
    self.setObject(val, forKey: key.to_s)
    self.synchronize
  end
end

module Persist
  module_function

  def identifier
    NSBundle.mainBundle.bundleIdentifier
  end

  def app_key
    @app_key ||= identifier
  end

  def []=(key, value)
    storage.setObject(value, forKey: storage_key(key))
    storage.synchronize
  end

  def [](key)
    value = storage.objectForKey storage_key(key)

    # RubyMotion currently has a bug where the strings returned from
    # standardUserDefaults are missing some methods (e.g. to_data).
    # And because the returned object is slightly different than a normal
    # String, we can't just use `value.is_a?(String)`
    value.class.to_s == 'String' ? value.dup : value
  end

  def merge(values)
    values.each do |key, value|
      storage.setObject(value, forKey: storage_key(key))
    end
    storage.synchronize
  end

  def delete(key)
    value = storage.objectForKey storage_key(key)
    storage.removeObjectForKey(storage_key(key))
    storage.synchronize
    value
  end

  def storage
    NSUserDefaults.standardUserDefaults
  end

  def storage_key(key)
    "#{app_key}_#{key}"
  end

  def all
    hash     = storage.dictionaryRepresentation.select { |k, _| k.start_with?(app_key) }
    new_hash = {}
    hash.each do |k, v|
      new_hash[k.sub("#{app_key}_", '')] = v
    end
    new_hash
  end

  def no_refresh
    @no_refresh = true
    yield
    @no_refresh = false
  end

  def load_prefs
    Persist.no_refresh {
      Info.last_version       = Persist.last_version
      Persist.last_version    = Info.version.to_s
      Persist.mem             = 1024 if Persist.mem.nil?
      Persist.trim_mem        = 0 if Persist.trim_mem.nil?
      Persist.auto_threshold  = 'low' if Persist.auto_threshold.nil? || Persist.auto_threshold == 'off'
      Persist.pressure        = 'warn' if Persist.pressure.nil? || Persist.pressure == 'normal'
      Persist.growl           = false if Persist.growl.nil?
      Persist.method_pressure = true if Persist.method_pressure.nil?
      Persist.show_mem        = true if Persist.show_mem.nil?
      Persist.update_while    = false if Persist.update_while.nil? || Info.last_version < '1.0'
      Persist.sticky          = false if Persist.sticky.nil?
      Persist.free_start      = true if Persist.free_start.nil?
      Persist.free_end        = true if Persist.free_end.nil?
      Persist.trim_start      = true if Persist.trim_start.nil?
      Persist.trim_end        = true if Persist.trim_end.nil?

      Persist.growl           = Persist.growl? || !Info.has_nc?
      Persist.method_pressure = Persist.method_pressure? && Info.mavericks?
      Persist.notifications   = Persist.growl? ? 'Growl' : 'Notification Center' if Persist.notifications.nil?
      Persist.notifications   = 'Growl' if Persist.notifications == 'Notification Center' && !Info.has_nc?
    }
  end

  def listen(*keys, &block)
    @listeners ||= {}
    Array(*keys).each { |key|
      @listeners[key] ||= []
      @listeners[key] << block
    }
  end

  def change_value(key, new_value)
    old_value = Persist[key.to_s]
    Persist[key.to_s] = new_value
    if @listeners.has_key?(key.to_sym)
      @listeners[key.to_sym].each { |l|
        l.call(key.to_sym, old_value, new_value)
      }
    end
  end

  def method_missing(meth, *args)
    if /^([a-z_]+)_state[?]$/ =~ meth
      Persist[$1] ? NSOnState : NSOffState
    elsif /^([a-z_]+)[?]?$/ =~ meth
      Persist[$1]
    elsif /^([a-z_]+)=/ =~ meth
      # old_value = Persist[$1]
      # new_value = Array(*args)[0]
      # key_str = $1
      # key = $1.to_sym
      # Persist[key_str] = new_value
      change_value($1.to_sym, Array(*args)[0])
      # MainMenu.send("set_#{$1}_display") unless @no_refresh
    else
      super
    end
  end
end