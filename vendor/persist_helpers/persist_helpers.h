#import <Foundation/Foundation.h>

@interface PersistHelpers : NSObject
@property (retain) id persistInstance;
@property (retain) NSString *appKey;
+ (id) createInstanceWithPersistInstance: (id) pi;
- (NSUserDefaults *) storage;
- (void) setObject: (id) obj forKey: (NSString *);
- (id) getObjectForKey: (NSString *) key;
- (NSString *) getStorageKey: (NSString *) key;
- (void) validateValueForKey: (NSString *) key;
@end