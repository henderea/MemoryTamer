class Prefs < NSWindowController
  extend IB

  def self.shared_instance
    @instance ||= create_instance
  end

  PERSIST_SETTERS = {
      list:   -> (p, v) { Persist.store[p] = v },
      bool:   -> (p, v) { Persist.store[p] = v == NSOnState },
      slider: -> (p, v) { Persist.store[p] = v }
  }

  # PERSIST_MAPPERS = {
  #     list: nil,
  #     bool: -> ()
  # }

  FIELD_SETTERS = {
      list:   -> (f, v) { f.selectItemWithTitle(v) },
      bool:   -> (f, v) { f.state = v ? NSOnState : NSOffState },
      slider: -> (f, v) { f.intValue = v }
  }

  PROPERTY_NAMES = {
      list:   :selectedValue,
      bool:   :state,
      slider: :intValue
  }

  def self.create_instance
    instance = alloc.initWithWindowNibName 'Prefs'
    instance.loadWindow
    instance.setup!
    instance
  end

  def setup!
    notifications_nc.enabled = Info.has_nc?
    # freeing_method_mp.enabled = Info.mavericks?
    link :list, :notifications
    link :bool, :growl_sticky
    link :bool, :free_start
    link :bool, :free_end
    link :bool, :trim_start
    link :bool, :trim_end
    link :slider, :free_slider, :mem, :free_field
    link :slider, :trim_slider, :trim_mem, :trim_field
    link :list, :auto_level, :auto_threshold
    link :list, :freeing_method
    link :bool, :auto_escalate
    link :bool, :show_mem
    link :bool, :update_while

    self.free_slider.minValue = 0
    self.free_slider.maxValue = Info.get_total_memory
    self.trim_slider.minValue = 0
    self.trim_slider.maxValue = Info.get_total_memory
  end

  def link_slider_and_text(slider_name, text_name)
    slider = send(slider_name)
    text   = send(text_name)
    slider.bind('intValue', toObject: text, withKeyPath: 'intValue', options: { 'NSContinuouslyUpdatesValue' => true })
    text.bind('intValue', toObject: slider, withKeyPath: 'intValue', options: { 'NSContinuouslyUpdatesValue' => true })
  end

  def link(setter_type, field_name, persist_name = field_name, field_name_2 = nil)
    if setter_type == :slider && field_name_2
      link_slider_and_text(field_name, field_name_2)
    end
    persist_name_str = persist_name.to_s
    field            = send(field_name)
    pv               = Persist.store[persist_name_str]
    FIELD_SETTERS[setter_type].call(field, pv) if pv
    field.bind(PROPERTY_NAMES[setter_type], toObject: NSUserDefaultsController.sharedUserDefaultsController, withKeyPath: "values.#{Persist.store.key_for(persist_name)}", options: { 'NSContinuouslyUpdatesValue' => true })
    NSUserDefaultsController.sharedUserDefaultsController.bind("values.#{Persist.store.key_for(persist_name)}", toObject: field, withKeyPath: PROPERTY_NAMES[setter_type], options: { 'NSContinuouslyUpdatesValue' => true })
    Persist.store.listen(persist_name) { |_, _, nv| FIELD_SETTERS(setter_type).call(field, nv) if nv }
  end

  #region Notifications Tab
  outlet :notifications, NSPopUpButton
  outlet :notifications_nc, NSMenuItem
  outlet :growl_sticky, NSButton
  outlet :free_start, NSButton
  outlet :free_end, NSButton
  outlet :trim_start, NSButton
  outlet :trim_end, NSButton
  #endregion

  #region Freeing Tab
  outlet :free_slider, NSSlider
  outlet :free_field, NSTextField
  outlet :trim_slider, NSSlider
  outlet :trim_field, NSTextField
  outlet :auto_level, NSPopUpButton
  outlet :freeing_method, NSPopUpButton
  outlet :freeing_method_mp, NSMenuItem
  outlet :freeing_pressure, NSPopUpButton
  outlet :auto_escalate, NSButton
  #endregion

  #region Display Tab
  outlet :show_mem, NSButton
  outlet :update_while, NSButton
  #endregion

end