class NotificationTabLayout < MotionKit::Layout
  def layout
    add NSTextField, :notification_label
    add NSPopUpButton, :notification_method
    add NSButton, :growl_sticky
    add NSButton, :free_start
    add NSButton, :free_end
    add NSButton, :trim_start
    add NSButton, :trim_end
  end

  def notification_label_style
    bezeled false
    draws_background false
    editable false
    selectable false
    string_value 'Notifications'
    size_to_fit
    origin [25, 300 - target.frame.size.height]
  end

  def notification_method_style
    target.addItemsWithTitles ['Notification Center', 'Growl', 'None']
    target.itemWithTitle('Notification Center').setEnabled(Info.has_nc?)
    target.selectItemWithTitle(Persist.notifications)
    size_to_fit
    origin [450 - target.frame.size.width, 300 - target.frame.size.height]
  end

  def growl_sticky_style
    button_type NSSwitchButton
    state Persist.sticky_state?
    title 'Sticky Growl Notifications'
    size_to_fit
    frame below(:notification_label, down: 5)
  end

  def free_start_style
    button_type NSSwitchButton
    # state Persist.sticky_state?
    title 'Freeing start notification'
    size_to_fit
    frame below(:growl_sticky, down: 5)
    end

  def free_end_style
    button_type NSSwitchButton
    # state Persist.sticky_state?
    title 'Freeing end notification'
    size_to_fit
    frame from_top_left(:free_start, up: 5)
    end

  def trim_start_style
    button_type NSSwitchButton
    # state Persist.sticky_state?
    title 'Trim start notification'
    size_to_fit
    frame below(:free_end, down: 5)
  end

  def trim_end_style
    button_type NSSwitchButton
    # state Persist.sticky_state?
    title 'Trim end notification'
    size_to_fit
    frame from_top_left(:trim_start, up: 5)
  end
end