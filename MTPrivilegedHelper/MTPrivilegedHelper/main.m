//
//  main.m
//  MTPrivilegedHelper
//
//  Created by Eric Henderson on 1/6/15.
//  Copyright (c) 2015 Everyday Programming Genius. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <syslog.h>
#include <xpc/xpc.h>

static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
    syslog(LOG_NOTICE, "Received event in helper.");

    xpc_type_t type = xpc_get_type(event);

    if (type == XPC_TYPE_ERROR) {
        if (event == XPC_ERROR_CONNECTION_INVALID) {
            // The client process on the other end of the connection has either
            // crashed or cancelled the connection. After receiving this error,
            // the connection is in an invalid state, and you do not need to
            // call xpc_connection_cancel(). Just tear down any associated state
            // here.

        } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
            // Handle per-connection termination cleanup.
        }

    } else {
        char *operation = (char *) xpc_dictionary_get_string(event, "operation");

        char *responseMessage;

        if(strcmp(operation, "purge") == 0) {
            NSTask *purgeTask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/purge" arguments:nil];
            [purgeTask waitUntilExit];
            [purgeTask release];
            responseMessage = "purge complete";
        } else {
            responseMessage = "unknown operation";
        }

        xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);

        xpc_object_t reply = xpc_dictionary_create_reply(event);
        xpc_dictionary_set_string(reply, "result", responseMessage);
        xpc_connection_send_message(remote, reply);
        xpc_release(reply);
    }
}

static void __XPC_Connection_Handler(xpc_connection_t connection)  {
    syslog(LOG_NOTICE, "Configuring message event handler for helper.");

    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        __XPC_Peer_Event_Handler(connection, event);
    });

    xpc_connection_resume(connection);
}

int main(int argc, const char *argv[]) {
    xpc_connection_t service = xpc_connection_create_mach_service("us.myepg.MemoryTamer.MTPrivilegedHelper",
                                                                  dispatch_get_main_queue(),
                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);

    if (!service) {
        syslog(LOG_NOTICE, "Failed to create service.");
        exit(EXIT_FAILURE);
    }

    syslog(LOG_NOTICE, "Configuring connection event handler for helper");
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        __XPC_Connection_Handler(connection);
    });

    xpc_connection_resume(service);

    dispatch_main();

    xpc_release(service);

    return EXIT_SUCCESS;
}