class Prefs
  def self.sharedInstance
    @instance ||= Prefs.new
  end

  def initialize
    load_window
  end

  def load_window
    @main_window             = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
                                                                  styleMask: NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask,
                                                                  backing:   NSBackingStoreBuffered,
                                                                  defer:     false)
    @main_window.title       = 'MemoryTamer Preferences'
    @tab_view                = NSTabView.alloc.initWithFrame([[0,0],[480,360]])
    @main_window.contentView = @tab_view
    @notification_tab_layout = NotificationTabLayout.new
    @tab_view.addTabViewItem(create_tab(@notification_tab_layout, :notification_tab))
  end

  def show_window
    @main_window.orderFrontRegardless
  end

  def create_tab(layout, id)
    tab      = NSTabViewItem.alloc.initWithIdentifier id
    tab.view = layout.view
    tab
  end
end