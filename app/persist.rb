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

class Persist
  def self.store
    @store ||= Persist.new
  end

  def self.property(*names)
    names.each { |name|
      define_method("#{name.to_s}".to_weak) { self[name.to_s] }
      define_method("#{name.to_s}?".to_weak) { self[name.to_s] }
      define_method("#{name.to_s}_state?".to_weak) { self[name.to_s] ? NSOnState : NSOffState }
      define_method("#{name.to_s}=".to_weak) { |v| change_value(name.to_sym, v) }
    }
  end

  property :mem, :trim_mem, :auto_threshold, :pressure, :growl, :method_pressure, :show_mem, :update_while, :sticky, :auto_escalate, :notifications

  def identifier
    NSBundle.mainBundle.bundleIdentifier
  end

  def app_key
    @app_key ||= identifier
  end

  def []=(key, value)
    storage.setObject(value, forKey: storage_key(key).to_s)
    storage.synchronize
  end

  def [](key)
    value = storage.objectForKey storage_key(key).to_s

    # RubyMotion currently has a bug where the strings returned from
    # standardUserDefaults are missing some methods (e.g. to_data).
    # And because the returned object is slightly different than a normal
    # String, we can't just use `value.is_a?(String)`
    value.class.to_s == 'String' ? value.dup.to_weak : value
  end

  def merge(values)
    values.each do |key, value|
      storage.setObject(value, forKey: storage_key(key).to_s)
    end
    storage.synchronize
  end

  def delete(key)
    value = storage.objectForKey storage_key(key).to_s
    storage.removeObjectForKey(storage_key(key).to_s)
    storage.synchronize
    value
  end

  def storage
    NSUserDefaults.standardUserDefaults
  end

  def storage_key(key)
    "#{app_key.to_weak}_#{key.to_weak}".to_weak
  end

  def all
    hash     = storage.dictionaryRepresentation.select { |k, _| k.start_with?(app_key) }
    new_hash = {}
    hash.each do |k, v|
      new_hash[k.sub("#{app_key}_".to_weak, '')] = v
    end
    new_hash
  end

  def no_refresh
    @no_refresh = true
    yield
    @no_refresh = false
  end

  def load_prefs
    self.no_refresh {
      Info.last_version    = self.last_version
      self.last_version    = Info.version.to_s
      self.mem             = 1024 if self.mem.nil?
      self.trim_mem        = 0 if self.trim_mem.nil?
      self.auto_threshold  = 'low' if self.auto_threshold.nil? || self.auto_threshold == 'off'
      self.pressure        = 'warn' if self.pressure.nil? || self.pressure == 'normal'
      self.growl           = false if self.growl.nil?
      self.method_pressure = true if self.method_pressure.nil?
      self.show_mem        = true if self.show_mem.nil?
      self.update_while    = false if self.update_while.nil? || Info.last_version < '1.0'
      self.sticky          = false if self.sticky.nil?
      self.free_start      = true if self.free_start.nil?
      self.free_end        = true if self.free_end.nil?
      self.trim_start      = true if self.trim_start.nil?
      self.trim_end        = true if self.trim_end.nil?

      self.growl           = self.growl? || !Info.has_nc?
      self.method_pressure = self.method_pressure? && Info.mavericks?
      self.notifications   = self.growl? ? 'Growl' : 'Notification Center' if self.notifications.nil?
      self.notifications   = 'Growl' if self.notifications == 'Notification Center' && !Info.has_nc?
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
    old_value         = Persist[key.to_s]
    Persist[key.to_s] = new_value
    @listeners[key.to_sym].each { |l| l.call(key.to_sym, old_value, new_value) } if @listeners.has_key?(key.to_sym)
  end

  # def method_missing(meth, *args)
  #   if /^([a-z_]+)_state[?]$/ =~ meth
  #     Persist[$1] ? NSOnState : NSOffState
  #   elsif /^([a-z_]+)[?]?$/ =~ meth
  #     Persist[$1]
  #   elsif /^([a-z_]+)=/ =~ meth
  #     # old_value = Persist[$1]
  #     # new_value = Array(*args)[0]
  #     # key_str = $1
  #     # key = $1.to_sym
  #     # Persist[key_str] = new_value
  #     change_value($1.to_sym, Array(*args)[0])
  #     # MainMenu.send("set_#{$1}_display") unless @no_refresh
  #   else
  #     super
  #   end
  # end
end