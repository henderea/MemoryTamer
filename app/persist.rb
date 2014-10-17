class NSObject
  def to_weak
    WeakRef.new(self)
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
        name_s   = name.to_s
        define_method("#{name_s.to_weak}".to_weak) { self[name_s] }
        define_method("#{name_s.to_weak}?".to_weak) { Util.value_to_bool(self[name_s]) }
        define_method("#{name_s.to_weak}_state?".to_weak) { self[name_s] ? NSOnState : NSOffState }
        define_method("#{name_s.to_weak}=".to_weak) { |v| self[name_s] = v }
      }
    end

    def calculated_property(*names, &getter)
      names.each { |name|
        name_s = name.to_s.to_weak
        define_method("#{name_s}".to_weak) { getter.call(self) }
        define_method("#{name_s}?".to_weak) { Util.value_to_bool(getter.call(self)) }
        define_method("#{name_s}_state?".to_weak) { getter.call(self) ? NSOnState : NSOffState }
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
  end

  property :mem, :trim_mem,
           :auto_threshold,
           :pressure, :method_pressure, :freeing_method, :auto_escalate,
           :update_while, :display_what, :mem_places, :refresh_rate,
           :sticky, :notifications,
           :free_start, :free_end, :trim_start, :trim_end,
           :last_version

  calculated_property(:show_mem) { |s| ['Show Icon + Free Memory', 'Show Free Memory'].include?(s.display_what) }
  calculated_property(:show_icon) { |s| ['Show Icon + Free Memory', 'Show Icon'].include?(s.display_what) }

  validate_map(:mem) { |_, _, nv| Util.constrain_value_range((0..MemInfo.getTotalMemory), nv, 1024) }
  validate_map(:trim_mem) { |_, _, nv| Util.constrain_value_range((0..MemInfo.getTotalMemory), nv, 0) }
  validate_map(:auto_threshold) { |_, ov, nv| Util.constrain_value_list(%w(low high), ov, nv, 'low') }
  validate_map(:pressure) { |_, ov, nv| Util.constrain_value_list(%w(warn critical), ov, nv, 'warn') }
  validate_map(:growl) { |_, _, nv| Util.constrain_value_boolean(nv, false, Info.has_nc?, false) }
  validate_map(:method_pressure) { |_, _, nv| Util.constrain_value_boolean(nv, true, Info.mavericks?) }
  validate_map(:freeing_method) { |_, ov, nv| Util.constrain_value_list_enable_map({ 'memory pressure' => Info.mavericks?, 'plain allocation' => true }, ov, nv, 'memory pressure', 'plain allocation') }
  validate_map(:update_while) { |_, _, nv| Util.constrain_value_boolean(nv, false, Info.last_version >= '1.0b6') }
  validate_map(:display_what) { |_, ov, nv| Util.constrain_value_list(['Show Icon + Free Memory', 'Show Icon', 'Show Free Memory'], ov, nv, 'Show Icon + Free Memory') }
  validate_map(:mem_places) { |_, _, nv| Util.constrain_value_range((0..3), nv, 2) }
  validate_map(:refresh_rate) { |_, _, nv| Util.constrain_value_range((1..5), nv, 2) }
  validate_map(:sticky) { |_, _, nv| Util.constrain_value_boolean(nv, false) }
  validate_map(:auto_escalate) { |_, _, nv| Util.constrain_value_boolean(nv, false) }
  validate_map(:notifications) { |_, ov, nv| Util.constrain_value_list_enable_map({ 'None' => true, 'Growl' => true, 'Notification Center' => Info.has_nc? }, ov, nv, 'Notification Center', 'Growl') }
  validate_map(:free_start) { |_, _, nv| Util.constrain_value_boolean(nv, true) }
  validate_map(:free_end) { |_, _, nv| Util.constrain_value_boolean(nv, true) }
  validate_map(:trim_start) { |_, _, nv| Util.constrain_value_boolean(nv, true) }
  validate_map(:trim_end) { |_, _, nv| Util.constrain_value_boolean(nv, true) }

  def persist_helper
    @persist_helper ||= PersistHelpers.createInstanceWithPersistInstance(self)
  end

  def validateCheck(key, withOldValue: old_value, andNewValue: value)
    Persist.validate?(key.to_sym, old_value, value)
  end

  def []=(key, value)
    self.persist_helper.setObject(value, forKey: key.to_s)
  end

  def [](key)
    self.persist_helper.getObjectForKey(key.to_s)
  end

  def load_prefs
      Info.last_version = self.last_version
      self.last_version = Info.version.to_s
      self.listen(:display_what) { |_, _, _| MainMenu.status_item.setImage(Persist.store.show_icon? ? NSImage.imageNamed('Status') : nil) }
      self.listen(:display_what, :mem_places) { |_, _, _| MainMenu.status_item.setTitle(Persist.store.show_mem? ? Info.format_bytes(Info.get_free_mem) : '') }
      self.validate! :mem, :trim_mem,
                     :auto_threshold,
                     :pressure, :method_pressure, :freeing_method, :auto_escalate,
                     :update_while, :display_what, :mem_places, :refresh_rate,
                     :growl, :sticky, :notifications,
                     :free_start, :free_end, :trim_start, :trim_end
  end

  def listen(*keys, &block)
    @listeners ||= {}
    keys.each { |key|
      @listeners[key.to_sym] ||= []
      @listeners[key.to_sym] << block
    }
  end

  def validate!(*keys)
    keys.each { |key| self.persist_helper.validateValueForKey(key.to_s) }
  end

  def fireListeners(key, withOldValue: old_value, andNewValue: new_value)
    key = key.to_sym
    @listeners ||= {}
    @listeners[key].each { |l| l.call(key, old_value, new_value) } if @listeners.has_key?(key)
  end
end