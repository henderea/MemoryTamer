MemoryTamer
===========

As of version 0.7.2, Memory Tamer is now a paid app.  Please visit <https://pay.paddle.com/checkout/492767> to get a license.  You can also buy in-app.

A RubyMotion application for keeping memory usage in check.  Shows up in the menu bar and shows current free ram (refreshed every 2 seconds).

**Note:** The plain allocation method uses the C code from <http://forums.macrumors.com/showpost.php?p=8941184&postcount=54>

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
