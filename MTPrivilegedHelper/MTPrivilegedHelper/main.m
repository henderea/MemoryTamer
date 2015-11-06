//
//  main.m
//  MTPrivilegedHelper
//
//  Created by Eric Henderson on 1/6/15.
//  Copyright (c) 2015 Everyday Programming Genius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <launch.h>
#import <syslog.h>

@interface PrivilegedObject : NSObject

- (void)purge;

@end

@implementation PrivilegedObject

- (void)purge
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/sbin/purge"];
    [task launch];
}

@end

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        syslog(LOG_NOTICE, "MTPrivilegedHelper launched (uid: %d, euid: %d, pid: %d)", getuid(), geteuid(), getpid());
        
        launch_data_t req = launch_data_new_string(LAUNCH_KEY_CHECKIN);
        launch_data_t resp = launch_msg(req);
        launch_data_t machData = launch_data_dict_lookup(resp, LAUNCH_JOBKEY_MACHSERVICES);
        launch_data_t machPortData = launch_data_dict_lookup(machData, "us.myepg.MemoryTamer.MTPrivilegedHelper.mach");

        mach_port_t mp = launch_data_get_machport(machPortData);
        launch_data_free(req);
        launch_data_free(resp);

        NSMachPort *rp = [[NSMachPort alloc] initWithMachPort:mp];
        NSConnection *c = [NSConnection connectionWithReceivePort:rp sendPort:nil];

        PrivilegedObject *obj = [PrivilegedObject new];
        [c setRootObject:obj];
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}