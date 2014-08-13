class Prefs < NSWindowController
  extend IB

  def self.shared_instance
    @instance ||= create_instance
  end

  def self.create_instance
    instance                          = alloc.initWithWindowNibName 'Prefs'
    # instance.notifications.wiretap
    instance.notifications_nc.enabled = Info.has_nc?
    instance.add_tap(:notifications, :selectedValue).listen { |v| Persist.notifications = v if v }
    Persist.listen(:notifications) { |_, _, nv| instance.notifications.selectItemWithTitle(nv) }
  end

  def add_tap(name, property)
    @wiretaps ||= []
    obj       = send(name)
    tap       = obj && MW(obj, property)
    @wiretaps << tap if tap
    tap
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