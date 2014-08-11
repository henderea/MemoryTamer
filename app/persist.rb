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
    @cache      ||= {}
    @cache[key] = value
    storage.setObject(value, forKey: storage_key(key).to_s)
    storage.synchronize
  end

  def [](key)
    @cache ||= {}
    if @cache[key].nil?
      value       = storage.objectForKey storage_key(key).to_s

      # RubyMotion currently has a bug where the strings returned from
      # standardUserDefaults are missing some methods (e.g. to_data).
      # And because the returned object is slightly different than a normal
      # String, we can't just use `value.is_a?(String)`
      @cache[key] = value.class.to_s == 'String' ? value.dup.to_weak : value
    end
    @cache[key]
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
    "#{app_key}_#{key}".to_weak
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

  def method_missing(meth, *args)
    if /^([a-z_]+)_state[?]$/ =~ meth
      Persist[$1] ? NSOnState : NSOffState
    elsif /^([a-z_]+)_bi[?]$/ =~ meth
      Persist[$1] ? 1 : 0
    elsif /^([a-z_]+)[?]?$/ =~ meth
      Persist[$1]
    elsif /^([a-z_]+)_bi=/ =~ meth
      Persist[$1] = Array(*args)[0] == 0
    elsif /^([a-z_]+)=/ =~ meth
      Persist[$1] = Array(*args)[0]
      # MainMenu.send("set_#{$1}_display") unless @no_refresh
    else
      super
    end
  end
end