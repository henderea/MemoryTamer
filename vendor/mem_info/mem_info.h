#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>
#import <math.h>

@interface MemInfo : NSObject
+ (long long) getPageSize;
+ (int) getPagesFree;
+ (int) getPagesInactive;
+ (long long) getMemoryPressure;
+ (long long) getTotalMemory;
+ (long long) getMTMemory;
+ (NSString *) getOSVersion;
@end