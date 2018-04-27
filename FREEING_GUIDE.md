# Guide to MemoryTamer Freeing tab settings

* **Threshold in MB** - When the free memory of the computer gets at or below this point, it will run a full freeing
* **Trim Threshold in MB** - When the free memory of the computer gets at or below this point but is still above the `Threshold in MB`, it will run a quicker, lighter trimming of the memory that runs faster but doesn't free as much (helps keep it from requiring a full freeing)
* **Suggest Threshold** - This is a feature that will try to come up with some thresholds for you, but it should mainly be used as a starting point (if at all), and manual tweaking of the threshold settings may be needed
* **Freeing Method** - How to free memory.
    * `memory pressure` will use a built-in system command (introduced in macOS 10.9, which is the minimum OS version supported by the app) to push the system to a certain level of "pressure", which is basically a measure of how tight memory resources are on the computer.
    * `plain allocation` uses the same method as the trimming operation, running faster and being easier on the system, but probably not freeing as much.
* **Freeing Pressure** - The pressure level to target when using `memory pressure` freeing.  The levels are technically ranges, so it targets the low end of the range.  The names I use are what the system calls them.
    * `warn` is a moderate level of pressure.  In the graph on Activity Monitor's memory tab, it is the yellow color and is the faster of the two options, also causing less potential for the slowdown of the computer during the freeing.
    * `critical` is the higher level of pressure.  Activity Monitor shows it as red.  It can potentially take a little while to finish, and sometimes it can cause the computer to slow down a bit during the freeing due to the low memory availability.  However, it does free more RAM.
* **Auto-escalate** - When using `memory pressure` freeing set to `warn`, checking this checkbox will cause it to use `critical` pressure if the computer is already at the `warn` level.
