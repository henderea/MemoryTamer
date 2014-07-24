MemoryTamer
===========

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

###Versions (code-signed with developer ID):
* **v0.3:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.3> (Mavericks-only)
* **v0.4:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.4> (<del>should work back to Lion</del> doesn't work on pre-ML)
* **v0.4.1:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.4.1>
* **v0.4.2:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.4.2> (actually tested and working on Lion)
* **v0.5:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.5>
* **v0.5.1:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.5.1>
* **v0.6:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.6>
* **v0.6.1:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.6.1>
* **v0.6.2:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.6.2>
* **v0.7:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.7>