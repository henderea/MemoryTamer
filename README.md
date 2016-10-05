MemoryTamer
===========

As of version 0.7.2, MemoryTamer is now a paid app.  Please visit <https://pay.paddle.com/checkout/492767> to get a Paddle license.  You can also buy in-app.

As of version 1.4.0, MemoryTamer now supports FastSpring as an alternate payment provider.  Please visit <http://sites.fastspring.com/memorytamer/product/memorytamer> to purchase a license through FastSpring.

Thank you to everyone who has bought MemoryTamer so far.  I've added a lot of features in the time since I put it up for sale at $1.99, and I feel that MemoryTamer is worth a bit more than when it started out.  As such, I have increased the price to $2.49.

A RubyMotion application for keeping memory usage in check.  Shows up in the menu bar and shows current free ram (refreshed every 2 seconds).

**Note:** The plain allocation method uses the C code from <http://forums.macrumors.com/showpost.php?p=8941184&postcount=54>

**Note:** In version 1.0, I bundled a copy of the Mavericks `memory_pressure` system command.

###Release notes
* **v0.3:** Initial public release.  Only supports Mavericks and up because it uses the memory_pressure command introduced then.  Configuration is in a plain text file in the home directory and only checked on startup.
* **v0.4:** Significant changes.  Now compiled to work all the way back to Lion (though not tested on anything other than Mavericks).  Has more configurations options and now lets you change them at runtime in the menu.  Besides memory threshold and freeing pressure, you can now control the notification system (Growl or Notification Center) and the freeing method (memory_pressure or plain allocation).
* **v0.4.1:** Fix a bug related to determining max memory and current memory pressure.  Also fix a bug relating to the cancel button on input dialogs.
* **v0.4.2:** fix an issue with Lion compatibility
* **v0.5:** add the ability to check for updates (currently not automatic)
* **v0.5.1:** add a setting to control the freeing pressure auto-escalate functionality and make MemoryTamer wait at least 30 seconds after launching before it tries to free memory
* **v0.6:** Change update checking to Sparkle update checker
* **v0.6.1:** show Sparkle checking for updates dialog when check for updates menu item is selected
* **v0.6.2:** add an option for hiding free memory in the menu bar
* **v0.7:** add an option to disable updating the free memory display while freeing memory; also change some preference items to checkbox items
* **v0.7.1:** hopefully decrease the amount of memory leaking
* **v0.7.2:** change to a paid app
* **v0.7.3:** add registration submenu
* **v0.7.4:** fix a bug in the plain allocation freeing method
* **v0.7.5:** show version in menu and add a link to file a ticket
* **v0.7.6:** update icon
* **v0.7.7:** add "Using MemoryTamer" to the Support menu
* **v0.7.8:** add retina status icon
* **v0.8:** add memory quick-trimming functionality and remove the old "reload preferences" menu item
* **v0.8.1:** add an option to control whether or not growl notifications are sticky
* **v0.8.2:** add ability to run Memory Trimming on demand
* **v0.9:** New experimental feature: auto-threshold.  Designed to automatically adjust your thresholds to the target frequency.  If you try it out, please provide feedback at <https://github.com/henderea/MemoryTamer/issues/4>
* **v0.9.1:** Make some changes to auto-threshold to hopefully improve it.  If you try it out, please provide feedback at <https://github.com/henderea/MemoryTamer/issues/4>
* **v0.9.2:** fix a bug introduced in v0.9.1 where memory threshold would be set to 0 if trim threshold was 0
* **v0.9.3:** Auto-threshold has changed.  My original design for it didn't turn out well, so I changed it to set the thresholds to a certain percent of post-freeing memory on a full freeing.  Hopefully this will work better.
* **v0.9.4:** fix a refreshing issue with auto-threshold
* **v0.9.5:** hopefully work around a memory leak by using a bundled copy of growlnotify; also, new icon
* **v0.9.6:** hopefully reduce memory leaks and add a mechanism for relaunching MemoryTamer when it starts using up too much memory
* **v0.9.6.1:** fix a integer overflow error
* **v1.0:** Big 1.0 release!  MemoryTamer now has a window-based preferences interface.
	* As part of the preferences update the "auto-threshold" feature has been changed into "Suggest Threshold".
	* As part of the preferences update, you can now turn off all notifications or individual ones.  Note that if you have the notification system set to "None", the individual notification checkboxes will be ignored.
	* When upgrading from a pre-1.0 version, the "update while freeing" option will be turned off the first time you launch 1.0. This is because the suddenly decreasing free memory amount may cause confusion. You can turn this option back on if desired.
	* Thanks to all of the beta testers that helped me get this version working well.
* **v1.0.1:** integrate a crash reporter
* **v1.0.2:** change update handler
* **v1.0.3:** add the option to choose between showing both the icon and free memory, just the free memory, or just the icon.  The only new state is the one with just the free memory.
* **v1.0.4:** add the option to control the number of decimal places
* **v1.0.5:** remove the out of date usage link and add a link to the app twitter account
* **v1.0.6:** add option to control refresh rate
* **v1.0.7:** hopefully fix crash on Mavericks by using the system copy of `memory_pressure`
* **v1.0.8:** handle errors in launching preferences window better
* **v1.0.9:** put log messages into a file and include them in the automatic crash reports
* **v1.0.10:** fix an issue with icon hiding not being respected on relaunch
* **v1.0.11:** fix a bug that could cause MemoryTamer to not start up after a crash, slightly reduce the amount of memory plain allocation tries to free in order to reduce the chance of slowing down the computer, and add a link to write a review
* **v1.0.12:** fix a bug that could cause a crash when freeing memory with memory pressure
* **v1.1:** integrate a feedback form
* **v1.1.1:** fix notification system "None" not working and fix "Update free memory display while freeing" not working on first launch
* **v1.1.2:** display MemoryTamer memory usage in menu and add "relaunch" menu item
* **v1.1.3:** add a "Deactivate License" menu item and fix some logging issues
* **v1.1.4:** display how long it's been since MemoryTamer last launched and fix the auto-relaunch feature
* **v1.1.4.1:** fix the fix from 1.1.4
* **v1.2:** Unfortunately, due to a change in the build system I use, MemoryTamer no longer supports OS X 10.7 Lion.  I can still issue bug fixes for Lion, but all new features will require OS X 10.8 Mountain Lion and up.
* **v1.2.1/v1.1.5:** add anonymous tracking of OS version to determine number of users on Lion
* **v1.2.2:** add a link to vote on the next feature for MemoryTamer
* **v1.2.3/v1.1.6:** enable cmd+w for closing feedback and preferences windows
* **v1.2.4:** add a menu item for launching on login
* **v1.2.4.1:**
    * Update Paddle purchasing framework to latest version
    * Change minimum OS X version requirement to 10.9 Mavericks.  Almost no MemoryTamer users are still running 10.8 Mountain Lion, so removing support for it allows the compiler to make a more optimized and potentially more stable executable.
* **v1.2.4.2:** Fix a minor problem in the integration with the new Paddle framework version
* **v1.2.5:** Add a menu item for displaying memory pressure percentage
* **v1.3.0:** Add some memory stats like Activity Monitor and fix a bug causing some display-only menu items to be clickable
* **v1.3.1:** Add the rest of the memory stats from Activity monitor and fix a bug causing incorrect free memory amounts
* **v1.3.1.1:** Fix the value for Swap Used
* **v1.3.1.2:** Update to latest version of Paddle selling and licensing framework
* **v1.3.1.3:** Because of some recent issues with Paddle activation, MemoryTamer will now not block you from using the app when your trial runs out.  This is temporary while a solution gets worked out, but it should help those who are having trouble activating their copy.
* **v1.4.0:** Now supports FastSpring as an alternate payment provider.  Due to some issues in the licensing dialog, currently the FastSpring license can only be activated via the link you get in the delivery information email.  You will need to have MemoryTamer already installed before you click the link.  You may need to allow it to open/run.
* **v1.4.1:** Hopefully fix a startup crash
* **v1.4.1.1:** Fix a crash related to the trial system
* **v1.4.2:** Update the Paddle framework to hopefully fix some issues
* **v1.4.2.1:** Update some dependencies to hopefully reduce problems
* **v1.4.3:** Update some dependencies and make Paddle licensing the default again.  Also, add an option to pause automatic freeing and trimming
* **v1.4.4:**
    * Update multiple dependencies, including a new version of the Paddle library with better support for OS X 10.11 El Capitan
    * Refreshed app icon
* **v1.4.5:**
    * Update multiple dependencies, including a new version of the Paddle library with better support for OS X 10.11 El Capitan
    * Fix the display of app memory and file cache
    * Display the compressed memory for MemoryTamer and relaunch if it gets over 100MB
* **v1.4.5.1:** fix downloading of updates (hopefully)
* **v1.4.5.2:** update dependencies, including a new version of the Paddle library with some fixes and improvements
* **v1.4.5.3:** fix the value of the MemoryTamer memory usage to match Activity Monitor and add some extra MemoryTamer memory usage stats that can be shown by holding down the Option key when opening the menu
* **v1.4.5.4:** Update multiple frameworks, including a security update to the Sparkle updater framework, bug fix and improvement updates to the Paddle purchasing framework, and bug fix and improvement updates to the RubyMotion build system.
* **v1.4.5.5:** Update multiple dependencies
* **v1.4.5.6:** Update multiple dependencies
* **v1.4.5.6:** Update the Paddle selling framework
* **v1.4.6:**
    * Fix an issue on macOS Sierra that was causing the preferences dialog to pop up on app launch with default values.  You may still see some startup errors related to this issue, but from my testing, those don't actually affect anything, and the preferences dialog will still launch.
    * Add an option to use a grayscale (well, single-color) menu bar icon.  This mono-color icon will switch colors when you enable dark mode (on Yosemite and up)
    * Update some frameworks and dependencies, including the RubyMotion build framework and the Paddle licensing framework

###Versions (code-signed with developer ID):
* **v0.3:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.3.zip> (Mavericks-only)
* **v0.4:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.4.zip> (<del>should work back to Lion</del> doesn't work on pre-ML)
* **v0.4.1:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.4.1.zip>
* **v0.4.2:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.4.2.zip> (actually tested and working on Lion)
* **v0.5:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.5.zip>
* **v0.5.1:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.5.1.zip>
* **v0.6:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.6.zip>
* **v0.6.1:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.6.1.zip>
* **v0.6.2:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.6.2.zip>
* **v0.7:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.zip>
* **v0.7.1:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.1.zip>
* **v0.7.2:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.2.zip>
* **v0.7.3:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.3.zip>
* **v0.7.4:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.4.zip>
* **v0.7.5:** <http://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.5.zip>
* **v0.7.6:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.6.zip>
* **v0.7.7:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.7.zip>
* **v0.7.8:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.7.8.zip>
* **v0.8:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.8.zip>
* **v0.8.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.8.1.zip>
* **v0.8.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.8.2.zip>
* **v0.9:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.zip>
* **v0.9.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.1.zip>
* **v0.9.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.2.zip>
* **v0.9.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.3.zip>
* **v0.9.4:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.4.zip>
* **v0.9.5:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.5.zip>
* **v0.9.6:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.6.zip>
* **v0.9.6.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-0.9.6.1.zip>
* **v1.0:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.zip>
* **v1.0.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.1.zip>
* **v1.0.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.2.zip>
* **v1.0.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.3.zip>
* **v1.0.4:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.4.zip>
* **v1.0.5:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.5.zip>
* **v1.0.6:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.6.zip>
* **v1.0.7:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.7.zip>
* **v1.0.8:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.8.zip>
* **v1.0.9:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.9.zip>
* **v1.0.10:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.10.zip>
* **v1.0.11:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.11.zip>
* **v1.0.12:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.0.12.zip>
* **v1.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.zip>
* **v1.1.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.1.zip>
* **v1.1.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.2.zip>
* **v1.1.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.3.zip>
* **v1.1.4:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.4.zip>
* **v1.1.4.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.4.1.zip>
* **v1.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.zip> (10.8 and up)
* **v1.2.1/v1.1.5:**
	* **v1.2.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.1.zip> (10.8 and up)
	* **v1.1.5:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.5.zip> (10.7 and up)
* **v1.2.1.1/v1.1.5.1:**
	* **v1.2.1.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.1.1.zip>
	* **v1.1.5.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.5.1.zip>
* **v1.2.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.2.dmg>
* **v1.2.3/v1.1.6:**
	* **v1.2.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.3.dmg>
	* **v1.1.6:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.1.6.dmg>
* **v1.2.4:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.4.dmg> (10.8 and up)
* **v1.2.4.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.4.1.dmg> (10.9 and up)
* **v1.2.4.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.4.2.dmg>
* **v1.2.5:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.2.5.dmg>
* **v1.3.0:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.3.0.dmg>
* **v1.3.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.3.1.dmg>
* **v1.3.1.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.3.1.1.dmg>
* **v1.3.1.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.3.1.2.dmg>
* **v1.3.1.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.3.1.3.dmg>
* **v1.4.0:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.0.dmg>
* **v1.4.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.1.dmg>
* **v1.4.1.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.1.1.dmg>
* **v1.4.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.2.dmg>
* **v1.4.2.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.2.1.dmg>
* **v1.4.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.3.dmg>
* **v1.4.4:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.4.dmg>
* **v1.4.5:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.dmg>
* **v1.4.5.1:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.1.dmg>
* **v1.4.5.2:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.2.dmg>
* **v1.4.5.3:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.3.dmg>
* **v1.4.5.4:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.4.dmg>
* **v1.4.5.5:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.5.dmg>
* **v1.4.5.6:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.6.dmg>
* **v1.4.5.7:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.5.7.dmg>
* **v1.4.6:** <https://memorytamer.s3.amazonaws.com/MemoryTamer-1.4.6.dmg>
