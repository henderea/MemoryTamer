#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>
#import "privileged_helper.h"

@implementation PrivilegedHelper
+ (BOOL) blessHelperWithLabel: (NSString *) label
                        error: (NSString **) error {

	BOOL result = NO;

	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				|
										kAuthorizationFlagInteractionAllowed	|
										kAuthorizationFlagPreAuthorize			|
										kAuthorizationFlagExtendRights;

	AuthorizationRef authRef = NULL;

	/* Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper). */
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status != errAuthorizationSuccess) {
        *error = [NSString stringWithFormat:@"Failed to create AuthorizationRef. Error code: %d", (int)status];
	} else {
		/* This does all the work of verifying the helper tool against the application
		 * and vice-versa. Once verification has passed, the embedded launchd.plist
		 * is extracted and placed in /Library/LaunchDaemons and then loaded. The
		 * executable is placed in /Library/PrivilegedHelperTools.
		 */
		NSError *error2 = nil;
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)label, authRef, (CFErrorRef *)&error2);
		if(!result) {
		    *error = [NSString stringWithFormat:@"Failed to bless helper. Error: %@", error2];
		}
	}

	return result;
}

+ (PrivilegedHelper *) createHelperConnection: (NSString *) label
                                    utilCallback: (id) utilCallback {
    PrivilegedHelper *ph = [[PrivilegedHelper alloc] init];
    [ph setUtilCallback: utilCallback];

    xpc_connection_t connection = xpc_connection_create_mach_service("com.apple.bsd.SMJobBlessHelper", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);

    if (!connection) {
        [ph logError:@"Failed to create XPC connection."];
        return nil;
    }

    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);

        if (type == XPC_TYPE_ERROR) {

            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                [ph logError:@"XPC connection interrupted."];

            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                [ph logError:@"XPC connection invalid, releasing."];
                xpc_release(connection);

            } else {
                [ph logError:@"Unexpected XPC connection error."];
            }

        } else {
            [ph logError:@"Unexpected XPC connection event."];
        }
    });

    xpc_connection_resume(connection);

    [ph setConnection: connection];

    return ph;
}

- (void) executeOperation: (char*) operation {
    xpc_connection_t connection = [self connection];
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    const char* request = operation;
    xpc_dictionary_set_string(message, "operation", request);

    [self logDebug:[NSString stringWithFormat:@"Sending request: %s", request]];


    xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, "result");
        [self logDebug:[NSString stringWithFormat:@"Received response: %s.", response]];
        [[self utilCallback] privileged_helper_response: response];
    });
}

- (void) logError: (NSString *) message {
    [[self utilCallback] error: message];
}
- (void) logDebug: (NSString *) message {
    [[self utilCallback] debug: message];
}
@end