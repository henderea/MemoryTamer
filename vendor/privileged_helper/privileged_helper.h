@interface PrivilegedHelper : NSObject
@property (retain) id utilCallback;
@property (retain) xpc_connection_t connection;
+ (BOOL) blessHelperWithLabel: (NSString *) label
                        error: (NSString **) error;
+ (PrivilegedHelper *) createHelperConnection: (NSString *) label
                                    utilCallback: (id) utilCallback;
- (void) executeOperation: (char *) operation;
- (void) logError: (NSString *) message;
- (void) logDebug: (NSString *) message;
@end