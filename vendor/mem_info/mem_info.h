@interface MemInfo : NSObject
+ (long long) getPageSize;
+ (int) getPagesFree;
+ (int) getPagesInactive;
+ (long long) getMemoryPressure;
+ (long long) getTotalMemory;
+ (long long) getMTMemory;
+ (NSString *) getOSVersion;
+ (int) getMemoryPressurePercent;
@end