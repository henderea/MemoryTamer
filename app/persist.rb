class NSObject
  def to_weak
    WeakRef.new(self)
  end
end

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
      # define_method("#{name.to_s}_bi?".to_weak) { self[name.to_s] ? 1 : 0 }
      define_method("#{name.to_s}=".to_weak) { |v| self[name.to_s] = v }
      # define_method("#{name.to_s}_bi=".to_weak) { |v| self[name.to_s] = v == 0 }
    }
  end

  property :mem, :trim_mem, :auto_threshold, :pressure, :growl, :method_pressure, :show_mem, :update_while, :sticky, :auto_escalate

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
end