#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

@interface MemInfo : NSObject
+ (int) getPageSize;
+ (int) getPagesFree;
+ (int) getPagesInactive;
+ (int) getMemoryPressure;
+ (int) getTotalMemory;
@end