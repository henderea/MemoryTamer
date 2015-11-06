@interface PrivilegedObject : NSObject

- (void)purge;

@end

@interface PrivilegedHelper : NSObject
@property (retain) id utilCallback;
@property (retain) PrivilegedObject *proxy;
+ (BOOL) blessHelperWithLabel: (NSString *) label
                        error: (NSString **) error;
+ (PrivilegedHelper *) createHelperConnection: (NSString *) label;
- (void) logError: (NSString *) message;
- (void) logDebug: (NSString *) message;
@end