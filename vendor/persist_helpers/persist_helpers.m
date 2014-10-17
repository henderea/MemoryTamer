#import "persist_helpers.h"

@implementation PersistHelpers
+ (id) createInstanceWithPersistInstance: (id) pi {
    id phi = [[PersistHelpers alloc] init];
    [phi setPersistInstance: pi];
    [phi setAppKey: [[NSBundle mainBundle] bundleIdentifier]];
    return phi;
}
- (NSUserDefaults *) storage {
    return [NSUserDefaults standardUserDefaults];
}
- (void) setObject: (id) obj forKey: (NSString *) key {
    id oldValue = [self getObjectForKey: key];
    id newValue = [[self persistInstance] validateCheck: key withOldValue: oldValue andNewValue: obj];
    [[self storage] setObject: newValue forKey: key];
    [[self storage] synchronize];
    [[self persistInstance] fireListeners: key withOldValue: oldValue andNewValue: newValue];
}
- (id) getObjectForKey: (NSString *) key {
    return [[self storage] objectForKey: [self getStorageKey: key]];
}
- (NSString *) getStorageKey: (NSString *) key {
    return [NSString stringWithFormat: @"%@_%@", [self appKey], key];
}
- (void) validateValueForKey: (NSString *) key {
    [self setObject: [self getObjectForKey: key] forKey: key];
}
@end