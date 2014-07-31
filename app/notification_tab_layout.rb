class NotificationTabLayout < MotionKit::Layout
  def layout
    add NSPopUpButton, :notification_method
    add NSButton, :growl_sticky
  end

  def notification_method_style
  end

  def growl_sticky_style
    button_type NSSwitchButton
  end
end