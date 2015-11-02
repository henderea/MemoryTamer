@interface MemInfo : NSObject
+ (long long) getPageSize;
+ (int) getPagesFree;
+ (int) getPagesUsed;
+ (int) getPagesInactive;
+ (int) getPagesFileCache;
+ (int) getPagesAppMemory;
+ (int) getPagesWired;
+ (int) getPagesCompressed;
+ (int) getPagesInCompressor;
+ (int) getPagesInSwap;
+ (long long) getMemoryPressure;
+ (long long) getTotalMemory;
+ (long long) getMTMemory;
+ (long long) getMTCompressedMemory;
+ (NSString *) getOSVersion;
+ (int) getMemoryPressurePercent;
@end