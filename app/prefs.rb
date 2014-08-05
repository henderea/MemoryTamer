class Prefs < NSWindowController
  extend IB

  #region Notifications Tab
  ib_outlet :notifications, NSPopUpButton
  ib_outlet :notifications_nc, NSMenuItem
  ib_outlet :growl_sticky, NSButton
  ib_outlet :free_start, NSButton
  ib_outlet :free_end, NSButton
  ib_outlet :trim_start, NSButton
  ib_outlet :trim_end, NSButton
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