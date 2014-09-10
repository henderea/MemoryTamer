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
  class << self
    attr_reader :aliases

    def store
      @store ||= Persist.new
    end

    def property(*names)
      names.each { |name|
        define_method("#{name.to_s}".to_weak) { self[name.to_s] }
        define_method("#{name.to_s}?".to_weak) { self["#{name.to_s}?"] }
        define_method("#{name.to_s}_state?".to_weak) { self[name.to_s] ? NSOnState : NSOffState }
        define_method("#{name.to_s}=".to_weak) { |v| change_value(name.to_sym, v) }
      }
    end

    def alias_property(map = {})
      @aliases ||= {}
      map.each { |orig, name|
        @aliases[name.to_s] = orig.to_s
        property name
      }
    end

    def calculated_property(*names, &getter)
      names.each { |name|
        define_method("#{name.to_s}".to_weak) { getter.call(self) }
        define_method("#{name.to_s}?".to_weak) { Util.value_to_bool(getter.call(self)) }
        define_method("#{name.to_s}_state?".to_weak) { getter.call(self) ? NSOnState : NSOffState }
      }
    end

    def validate_map(*keys, &block)
      @validators ||= {}
      Array(*keys).each { |key| @validators[key.to_sym] = block }
    end

    def validate?(key, old_value, new_value)
      @validators ||= {}
      (@validators.has_key?(key) && @validators[key].call(key, old_value, new_value)) || new_value
    end

    def depend(deps = {})
      @deps ||= {}
      deps.each { |k, v|
        @deps[k.to_sym] ||= []
        @deps[k.to_sym] << v.to_sym
      }
    end

    def depend?(dep)
      @deps ||= {}
      @deps[dep] || []
    end
  end

  property :mem, :trim_mem,
           :auto_threshold,
           :pressure, :method_pressure, :freeing_method, :auto_escalate,
           :update_while, :display_what,
           :growl, :sticky, :notifications,
           :free_start, :free_end, :trim_start, :trim_end,
           :last_version

  alias_property pressure: :freeing_pressure,
                 sticky:    :growl_sticky

  depend freeing_method: :method_pressure,
         notifications:  :growl

  calculated_property(:show_mem) { |s| ['Show Icon + Free Memory', 'Show Free Memory'].include?(s.display_what) }
  calculated_property(:show_icon) { |s| ['Show Icon + Free Memory', 'Show Icon'].include?(s.display_what) }

  validate_map(:mem) { |_, _, nv| Util.constrain_value_range((0..MemInfo.getTotalMemory), nv, 1024) }
  validate_map(:trim_mem) { |_, _, nv| Util.constrain_value_range((0..MemInfo.getTotalMemory), nv, 0) }
  validate_map(:auto_threshold) { |_, ov, nv| Util.constrain_value_list(%w(low high), ov, nv, 'low') }
  validate_map(:pressure) { |_, ov, nv| Util.constrain_value_list(%w(warn critical), ov, nv, 'warn') }
  validate_map(:growl) { |_, _, nv| Util.constrain_value_boolean(nv, false, Info.has_nc?, false) }
  validate_map(:method_pressure) { |_, _, nv| Util.constrain_value_boolean(nv, true, Info.mavericks?) }
  validate_map(:freeing_method) { |_, ov, nv| Util.constrain_value_list_enable_map({ 'memory pressure' => Info.mavericks?, 'plain allocation' => true }, ov, nv, Persist.store.method_pressure? ? 'memory pressure' : 'plain allocation', 'plain allocation') }
  validate_map(:update_while) { |_, _, nv| Util.constrain_value_boolean(nv, false, Info.last_version >= '1.0b6') }
  validate_map(:display_what) { |_, ov, nv| Util.constrain_value_list(['Show Icon + Free Memory', 'Show Icon', 'Show Free Memory'], ov, nv, (Persist.store['show_mem'].nil? || Persist.store['show_mem?']) ? 'Show Icon + Free Memory' : 'Show Icon') }
  validate_map(:sticky) { |_, _, nv| Util.constrain_value_boolean(nv, false) }
  validate_map(:auto_escalate) { |_, _, nv| Util.constrain_value_boolean(nv, false) }
  validate_map(:notifications) { |_, ov, nv| Util.constrain_value_list_enable_map({ 'Off' => true, 'Growl' => true, 'Notification Center' => Info.has_nc? }, ov, nv, Persist.store.growl ? 'Growl' : 'Notification Center', 'Growl') }
  validate_map(:free_start) { |_, _, nv| Util.constrain_value_boolean(nv, true) }
  validate_map(:free_end) { |_, _, nv| Util.constrain_value_boolean(nv, true) }
  validate_map(:trim_start) { |_, _, nv| Util.constrain_value_boolean(nv, true) }
  validate_map(:trim_end) { |_, _, nv| Util.constrain_value_boolean(nv, true) }

  def identifier
    NSBundle.mainBundle.bundleIdentifier
  end

  def app_key
    @app_key ||= identifier
  end

  def []=(key, value)
    if Persist.aliases.has_key?(key.to_s)
      self[Persist.aliases[key.to_s]] = value
    else
      old_value = self[key.to_s]
      new_value = Persist.validate?(key.to_sym, old_value, value)
      storage.setObject(new_value, forKey: storage_key(key).to_s)
      storage.synchronize
      fire_listeners(key.to_sym, old_value, new_value)
    end
  end

  def [](key)
    is_bool = key.to_s.end_with?('?')
    key2 = is_bool ? key.to_s[0...-1] : key
    rv = if Persist.aliases.has_key?(key2.to_s)
      self[Persist.aliases[key2.to_s]]
    else
      value = storage.objectForKey storage_key(key2).to_s

      # RubyMotion currently has a bug where the strings returned from
      # standardUserDefaults are missing some methods (e.g. to_data).
      # And because the returned object is slightly different than a normal
      # String, we can't just use `value.is_a?(String)`
      value.class.to_s == 'String' ? value.dup : value
    end
    is_bool ? (rv && rv != 0 && rv != NSOffState) : rv
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

  def key_for(key)
    if Persist.aliases.has_key?(key.to_s)
      self.key_for(Persist.aliases[key.to_s])
    else
      storage_key(key.to_s)
    end
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
      Info.last_version = self.last_version
      self.last_version = Info.version.to_s
      self.listen(:display_what) { |_, _, _|
        MainMenu.status_item.setImage(Persist.store.show_icon? ? NSImage.imageNamed('Status') : nil)
        MainMenu.status_item.setTitle(Persist.store.show_mem? ? Info.format_bytes(Info.get_free_mem) : '')
      }
      self.validate! :mem, :trim_mem,
                     :auto_threshold,
                     :pressure, :method_pressure, :freeing_method, :auto_escalate,
                     :update_while, :display_what,
                     :growl, :sticky, :notifications,
                     :free_start, :free_end, :trim_start, :trim_end,
                     :last_version
    }
  end

  def listen(*keys, &block)
    @listeners ||= {}
    keys.each { |key|
      @listeners[key.to_sym] ||= []
      @listeners[key.to_sym] << block
    }
  end

  def change_value(key, new_value)
    self[key.to_s] = new_value
  end

  def validate!(*keys)
    keys.each { |key|
      depend!(key)
      self[key.to_s] = self[key.to_s]
    }
  end

  def depend!(key)
    Persist.depend?(key).each { |v| self.validate!(v) }
  end

  def fire_listeners(key, old_value, new_value)
    @listeners ||= {}
    @listeners[key].each { |l| l.call(key, old_value, new_value) } if @listeners.has_key?(key) && !@no_refresh
  end
end