class Prefs < NSWindowController
  extend IB

  def self.shared_instance
    @instance ||= create_instance
  end

  def self.create_instance
    instance                          = alloc.initWithWindowNibName 'Prefs'
    # instance.notifications.wiretap
    instance.notifications_nc.enabled = Info.has_nc?
    ps_list                           = -> (p, v) { Persist.store[p] = v }
    fs_list                           = -> (f, v) { f.selectItemWithTitle(v) }
    ps_bool                           = -> (p, v) { Persist.store[p] = v == NSOnState }
    fs_bool                           = -> (f, v) { f.state = v ? NSOnState : NSOffState }
    instance.link(:notifications, :selectedValue, :notifications, ps_list, fs_list)
    instance.link(:growl_sticky, :state, :sticky, ps_bool, fs_bool)
    instance.link(:free_start, :state, :free_start, ps_bool, fs_bool)
    instance.link(:free_end, :state, :free_end, ps_bool, fs_bool)
    instance.link(:trim_start, :state, :trim_start, ps_bool, fs_bool)
    instance.link(:trim_end, :state, :trim_end, ps_bool, fs_bool)
    # instance.add_tap(:notifications, :selectedValue).listen { |v| Persist.store.notifications = v if v }
    # Persist.listen(:notifications) { |_, _, nv| instance.notifications.selectItemWithTitle(nv) }
    # instance.add_tap(:growl_sticky, :state).listen { |v| Persist.store.sticky = v == NSOnState }
  end

  def add_tap(name, property)
    @wiretaps ||= []
    obj       = send(name)
    tap       = obj && MW(obj, property)
    @wiretaps << tap if tap
    tap
  end

  def link(field_name, field_property, persist_name, persist_setter, field_setter)
    persist_name_str = persist_name.to_s
    field            = send(field_name)
    self.add_tap(field_name, field_property).listen { |v| persist_setter.call(persist_name_str, v) if v }
    Persist.listen(persist_name) { |_, _, nv| field_setter.call(field, nv) if nv }
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
  outlet :freeing_pressure, NSPopUpButton
  outlet :auto_escalate, NSButton
  #endregion

  #region Display Tab
  outlet :show_mem, NSButton
  outlet :update_while, NSButton
  #endregion

end