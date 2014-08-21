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
    instance                          = alloc.initWithWindowNibName 'Prefs'
    instance.notifications_nc.enabled = Info.has_nc?
    # instance.freeing_method_mp.enabled = Info.mavericks?
    instance.link :list, :notifications
    instance.link :bool, :growl_sticky
    instance.link :bool, :free_start
    instance.link :bool, :free_end
    instance.link :bool, :trim_start
    instance.link :bool, :trim_end
    instance.link :slider, :free_slider, :mem, :free_field
    instance.link :slider, :trim_slider, :trim_mem, :trim_field
    instance.link :list, :auto_level, :auto_threshold
    instance.link :list, :freeing_method
    instance.link :bool, :auto_escalate
    instance.link :bool, :show_mem
    instance.link :bool, :update_while
  end

  def add_tap(name, property)
    @wiretaps ||= []
    obj       = send(name)
    tap       = obj && MW(obj, property)
    @wiretaps << tap if tap
    tap
  end

  def link_slider_and_text(slider_name, text_name)
    slider = send(slider_name)
    text   = send(text_name)
    add_tap(slider, :intValue).bind_to(text, :intValue)
    add_tap(text, :intValue).bind_to(slider, :intValue)
  end

  def link(setter_type, field_name, persist_name = field_name, field_name_2 = nil)
    if setter_type == :slider && field_name_2
      link_slider_and_text(field_name, field_name_2)
    end
    persist_name_str = persist_name.to_s
    field            = send(field_name)
    pv               = Persist.store[persist_name_str]
    FIELD_SETTERS(setter_type).call(field, pv) if pv
    self.add_tap(field_name, PROPERTY_NAMES[setter_type]).listen { |v| PERSIST_SETTERS(setter_type).call(persist_name_str, v) if v }
    Persist.listen(persist_name) { |_, _, nv| FIELD_SETTERS(setter_type).call(field, nv) if nv }
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