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

+ (PrivilegedHelper *) createHelperConnection: (NSString *) label {
    PrivilegedHelper *ph = [[PrivilegedHelper alloc] init];

    NSConnection *c = [NSConnection connectionWithRegisteredName:@"us.myepg.MemoryTamer.MTPrivilegedHelper.mach" host:nil]; 
    PrivilegedObject *proxy = (PrivilegedObject *)[c rootProxy];

    [ph setProxy: proxy];

    return ph;
}
@end