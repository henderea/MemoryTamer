class ActionTarget
  def initialize(&block)
    @block = block
  end

  def action(sender)
    @block.call(sender)
  end
end

class Prefs < NSWindowController
  extend IB

  def self.shared_instance
    @instance ||= create_instance
  end

  def show_window
    self.window.makeKeyAndOrderFront(nil)
    self.window.orderFrontRegardless
  end

  PERSIST_SETTERS = {
      list:   -> (p, v) { Persist.store[p] = v },
      bool:   -> (p, v) { Persist.store[p] = v == NSOnState },
      slider: -> (p, v) { Persist.store[p] = v }
  }

  FIELD_SETTERS = {
      list:   -> (f, v) { f.selectItemWithTitle(v) },
      bool:   -> (f, v) { f.state = (v && v != 0 && v != NSOffState) ? NSOnState : NSOffState },
      slider: -> (f, v) { f.intValue = v }
  }

  FIELD_GETTERS = {
      list:   -> (f) { f.titleOfSelectedItem },
      bool:   -> (f) { f.state },
      slider: -> (f) { f.intValue }
  }

  # PROPERTY_NAMES = {
  #     list:   :selectedValue,
  #     bool:   :state,
  #     slider: :intValue
  # }

  def self.create_instance(tried = false)
    begin
      instance = alloc.initWithWindowNibName 'Prefs'
      instance.loadWindow
      instance.setup!
      instance
    rescue Exception => e
      NSLog e.inspect
      if tried
        Util.notify('ERROR: unable to open preferences; relaunching', :error)
        NSApp.relaunchAfterDelay(1)
      else
        self.create_instance(true)
      end
    end
  end

  def setup!
    notifications_nc.enabled  = Info.has_nc?
    freeing_method_mp.enabled = Info.mavericks?
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
    link :list, :freeing_pressure
    link :bool, :auto_escalate
    link :list, :display_what
    link :bool, :update_while
    link :slider, :mem_places_slider, :mem_places, :mem_places_field
    link :slider, :refresh_rate_slider, :refresh_rate, :refresh_rate_field

    self.free_slider.minValue         = 0
    self.free_slider.maxValue         = (Info.get_total_memory / 1024 ** 2)
    self.trim_slider.minValue         = 0
    self.trim_slider.maxValue         = (Info.get_total_memory / 1024 ** 2)
    self.mem_places_slider.minValue   = 0
    self.mem_places_slider.maxValue   = 3
    self.refresh_rate_slider.minValue = 1
    self.refresh_rate_slider.maxValue = 5
  end

  def link_slider_and_text(slider_name, text_name)
    slider = send(slider_name)
    text   = send(text_name)
    slider.bind('intValue', toObject: text, withKeyPath: 'intValue', options: { 'NSContinuouslyUpdatesValue' => true })
    text.bind('intValue', toObject: slider, withKeyPath: 'intValue', options: { 'NSContinuouslyUpdatesValue' => true })
    slider.target     = ActionTarget.new { |sender| text.intValue = sender.intValue }
    slider.continuous = true
  end

  def link(setter_type, field_name, persist_name = field_name, field_name_2 = nil)
    persist_name_str = persist_name.to_s
    field            = send(field_name)
    pv               = Persist.store[persist_name_str]
    FIELD_SETTERS[setter_type].call(field, pv) unless pv.nil?
    if setter_type == :slider && field_name_2
      field2 = send(field_name_2)
      FIELD_SETTERS[setter_type].call(field2, pv) unless pv.nil?
    end
    act   = ActionTarget.new { |sender|
      nv = FIELD_GETTERS[setter_type].call(sender)
      PERSIST_SETTERS[setter_type].call(persist_name, nv)
      nv = Persist.store[persist_name_str]
      FIELD_SETTERS[setter_type].call(field, nv)
      FIELD_SETTERS[setter_type].call(field2, nv) if field2
    }
    @acts ||= []
    @acts << act
    field.target     = act
    field.action     = 'action:'
    field.continuous = true
    if setter_type == :slider && field_name_2
      field2.target = act
      field2.action = 'action:'
    end
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
  outlet :suggest_threshold_button, NSButton
  outlet :freeing_method, NSPopUpButton
  outlet :freeing_method_mp, NSMenuItem
  outlet :freeing_pressure, NSPopUpButton
  outlet :auto_escalate, NSButton

  def suggest_threshold(sender)
    Thread.start {
      Info.freeing                          = true
      self.suggest_threshold_button.enabled = false
      Util.free_mem(Persist.store.pressure)
      nfm = Info.get_free_mem
      if Persist.store.auto_threshold == 'high'
        Persist.store.mem      = ((nfm.to_f * 0.5) / 1024**2).ceil
        Persist.store.trim_mem = ((nfm.to_f * 0.8) / 1024**2).ceil if Persist.store.trim_mem > 0
      else
        Persist.store.mem      = ((nfm.to_f * 0.3) / 1024**2).ceil
        Persist.store.trim_mem = ((nfm.to_f * 0.6) / 1024**2).ceil if Persist.store.trim_mem > 0
      end
      self.free_slider.intValue             = Persist.store.mem
      self.free_field.intValue              = Persist.store.mem
      self.trim_slider.intValue             = Persist.store.trim_mem
      self.trim_field.intValue              = Persist.store.trim_mem
      self.suggest_threshold_button.enabled = true
      Info.freeing                          = false
      Info.last_free                        = NSDate.date
    }
  end

  #endregion

  #region Display Tab
  outlet :display_what, NSPopUpButton
  outlet :update_while, NSButton
  outlet :mem_places_slider, NSSlider
  outlet :mem_places_field, NSTextField
  outlet :refresh_rate_slider, NSSlider
  outlet :refresh_rate_field, NSTextField
  #endregion

end