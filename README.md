MemoryTamer
===========

As of version 0.7.2, Memory Tamer is now a paid app.  Please visit <https://pay.paddle.com/checkout/492767> to get a license.  You can also buy in-app.

Thank you to everyone who has bought MemoryTamer so far.  I've added a lot of features in the time since I put it up for sale at $1.99, and I feel that MemoryTamer is worth a bit more than when it started out.  As such, I have increased the price to $2.49.

A RubyMotion application for keeping memory usage in check.  Shows up in the menu bar and shows current free ram (refreshed every 2 seconds).

**Note:** The plain allocation method uses the C code from <http://forums.macrumors.com/showpost.php?p=8941184&postcount=54>

**Note:** In version 1.0, I bundled a copy of the Mavericks memory_pressure system command.

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
