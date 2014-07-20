MemoryTamer
===========

A RubyMotion application for keeping memory usage in check.  Shows up in the menu bar and shows current free ram (refreshed every 2 seconds).

**Note:** I got the name idea from App Tamer (<http://www.stclairsoft.com/AppTamer/>), but I don't plan to sell this or distribute it widely, so hopefully the naming won't be an issue.

**Note:** The plain allocation method uses the C code from <http://forums.macrumors.com/showpost.php?p=8941184&postcount=54>

###Release notes
* **v0.3:** Initial public release.  Only supports Mavericks and up because it uses the memory_pressure command introduced then.  Configuration is in a plain text file in the home directory and only checked on startup.
* **v0.4:** Significant changes.  Now compiled to work all the way back to Lion (though not tested on anything other than Mavericks).  Has more configurations options and now lets you change them at runtime in the menu.  Besides memory threshold and freeing pressure, you can now control the notification system (Growl or Notification Center) and the freeing method (memory_pressure or plain allocation).
* **v0.4.1:** Fix a bug related to determining max memory and current memory pressure.  Also fix a bug relating to the cancel button on input dialogs.

###Versions (code-signed with developer ID):
* **v0.3:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.3> (Mavericks-only)
* **v0.4:** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.4> (should work back to Lion)
* **v0.4.1** <https://myepg-ds.s3.amazonaws.com/MemoryTamer-0.4.1>