#Using MemoryTamer

**NOTE:** I have plans for making a better preferences interface but have not gotten that accomplished yet.  Hopefully that will be coming soon.  As with my other updates, it will be free to existing users.

##Explanation of Preferences

###Notifications
This option is the pair of menu items that appear at the top of the Preferences menu.  It controls which notification system you are using.

If you are on OS X 10.7 Lion, it will be set to Growl and not allow changing.  If you are on OS X 10.8 Mountain Lion or above, it will default to Notification Center with the option to switch to Growl.

Notifications are shown when the memory freeing process begins and when it ends.

**NOTE:** if you do not have Growl installed, it will use a backup notification system built into the app for the Growl option.

###Memory Threshold
This option is the next pair of items in the Preferences menu, after Notifications.  It controls at what amount of remaining free memory MemoryTamer will start to automatically free memory.

**NOTE:** MemoryTamer will not run automatic freeing less than 30 seconds after app startup or 60 seconds after the last manual or automatic freeing.  This is so it does not free too often.

The memory threshold defaults to 1024 when you first start the app.  It is measured in MB (megabytes), so 1024 is one gigabyte.  You can set it to any value from 0 (to disable automatic freeing) up to your maximum system memory (likely somewhere between 1024 (1GB) and 16,384 (16GB)).

####Tips
The memory threshold can be hard to get right.  I would suggest that you try freeing up memory manually, and see how much is free afterwards.  This will give you a general idea of what the free memory will go up to when the memory is freed.  You should set it to be lower than this amount (probably not more than half of it), but it will take some trial and error to figure out what threshold works right.

Another tip is to pay attention to how quickly the free memory drops after you free it up.  It would probably be a good idea to avoid using a threshold that it gets back down to quickly.

###Memory Trim Threshold
Version 0.8 introduced Memory Trimming.  The settings for this have been placed directly under Memory Threshold.  This setting controls at what amount of free memory MemoryTamer will do a quick "trim" of the memory.

This uses the plain allocation method (see Freeing Method) tool, but will also run when the method is set to memory pressure.  This will not try to free up as much memory as a full freeing, but it should be faster than a typical freeing and should cause less slowness than a full plain allocation freeing.

The default value for this setting is 0 (disabled), but if you do use it, you should set the value above your full memory freeing threshold.  A suggestion might be to make it 1.5 or 2 times the amount, but it will probably take some experimentation to figure a good value out.

###Freeing Pressure
This option is the next pair of items in the Preferences menu, after Memory Trim Threshold.  It controls how aggressive it will be when freeing.

**NOTE:** this option is only available on OS X 10.9 Mavericks and up, and only applies to the "memory pressure" freeing method

**DEFINITION:** Memory pressure is basically a measure of how tight RAM resources are, and is a concept introduced in Mavericks.

The default and recommended value is "warn".  This means that it will target a warning level of memory pressure during its freeing, which will usually not cause a noticeable slow down on your computer.

The value "normal" is provided only because it is a valid value for the system function used to free memory this way.  It will not actually do anything as far as I am aware.

The value "critical" is the most aggressive of the options.  It will target a critical level of memory pressure during its freeing, which may cause your computer to slow down or even temporarily freeze up while freeing.  However, it will likely free up more memory than the "warn" option.

###Freeing Method
This option is the next pair of items in the Preferences menu, after Freeing Pressure.  It controls which tool will be used to free memory.

**EXPLANATION:** Memory freeing apps work by running a process that demands a lot of memory and then exiting that process when it has eaten up enough.  When a single process is demanding a lot of memory, the system will ask other applications to release some of the memory that they are holding onto but don't currently need.  It will also free up some of the memory the system is holding onto from apps that you have closed but that it thinks you might open back up.  Freeing up this memory will not cause things to crash, but depending on how aggressive the memory freeing is, it may slow things down.

The "memory pressure" freeing method is the default, but is only available on OS X 10.9 Mavericks and up because it uses a system function introduced in Mavericks.  This method will try to force the memory pressure to the level set in the Freeing Pressure option.  This is done by running a system operation that eats up memory until it reaches the target pressure level and then frees all of it.  By targeting a pressure level instead of a memory amount, it can free memory with less impact on system performance while freeing.

The "plain allocation" freeing method is available on all supported versions of OS X and is the only available method on Lion (10.7) and Mountain Lion (10.8).  This will target a certain amount of memory to eat up instead of targeting a specific pressure level.  This method can be faster but can also cause your computer to slow down while it is running.

###Auto-escalate
This option is the next item in the Preferences menu, after Freeing Method.  It controls whether or not the freeing pressure will be automatically increased when pressure is already at the target level. It is unchecked by default. It only applies to the "memory pressure" freeing method.

###Show Free Memory
This option is the next item in the Preferences menu, after Auto-escalate.  It controls whether or not the current amount of free memory is shown in the menu bar next to the icon.  It is checked by default.  The value shown in the menu bar is updated every 2 seconds.

###Update While Freeing
This option is the next item in the Preferences menu, after Show Free Memory.  It controls whether or not the current amount of free memory is updated while the freeing process is running.  It is checked by default.  This should not have a noticeable impact on performance either way, but if, for example, you want to see what level the memory was at when it started freeing, you could uncheck this and be able to look at that value while it is freeing.

##Registration
This menu has 2 items.  The first will show "Not Registered" if you have not yet purchased a license, or the e-mail address it is registered to if you have a license.

The second item will show "Buy / Register" if you do not have a license, or "View Registration" if you do.

**NOTE:** MemoryTamer offers a 7-day free trial, but if you like it and want to continue using it, you will need to buy a license through Paddle for $1.99 USD.  You can buy in-app or at <https://pay.paddle.com/checkout/492767>.

##Support
This menu currently has 2 items.  The first will open up a page where you can file a bug or feature request.  The second will open up these usage notes.