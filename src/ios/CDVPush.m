/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDVPlugin.h>
#import "CDVServiceWorker.h"
#import <Cordova/CDV.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

static NSString * const DEVICE_TOKEN_STORAGE_KEY = @"CDVPush_devicetoken";
static NSString * const USER_VISIBLE_STORAGE_KEY = @"CDVPush_userVisible";

@interface CDVPush : CDVPlugin {}

typedef void(^Completion)(UIBackgroundFetchResult);

@property (nonatomic, copy) Completion completionHandler;
@property (nonatomic, strong) CDVServiceWorker *serviceWorker;
@property (nonatomic, strong) JSValue *firePushEventContext;

@end

static CDVPush *this;

@implementation CDVPush

@synthesize completionHandler;
@synthesize serviceWorker;
@synthesize firePushEventContext;

- (void)setupPush:(CDVInvokedUrlCommand*)command
{
    self.serviceWorker = [self.commandDelegate getCommandInstance:@"ServiceWorker"];
    [self setupPushHandlers];
    [self setupSyncResponse];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setupPushHandlers
{
    this = self;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        Method original, swizzled;
        original = class_getInstanceMethod([self class], @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:));
        swizzled = class_getInstanceMethod([[[UIApplication sharedApplication] delegate] class], @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:));
        method_exchangeImplementations(original, swizzled);
    } else {
        class_addMethod([[[UIApplication sharedApplication] delegate] class], @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:), class_getMethodImplementation([self class], @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)), nil);
    }
}

- (void)hasPermission:(CDVInvokedUrlCommand*)command
{
    @try {
        if ([self hasPermission]) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"granted"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"denied"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }
    @catch (NSException *exception) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[exception description]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Received Remote notification");
    this.completionHandler = completionHandler;
    [this dispatchPushEvent:userInfo];
}

- (void)dispatchPushEvent:(NSDictionary*) userInfo
{
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
    NSString *dispatchCode = [NSString stringWithFormat:@"FirePushEvent('%@', %@);", userInfo[@"data"], [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [this.serviceWorker.context performSelectorOnMainThread:@selector(evaluateScript:) withObject:dispatchCode waitUntilDone:NO];
}

- (void)dispatchSubscriptionChangeEvent
{
    [this.serviceWorker.context performSelectorOnMainThread:@selector(evaluateScript:) withObject:@"FirePushSubscriptionChangeEvent();" waitUntilDone:NO];
}

- (void)setupSyncResponse
{
    __weak CDVPush *weakSelf = self;
    serviceWorker.context[@"sendSyncResponse"] = ^(JSValue *responseType) {
        UIBackgroundFetchResult result;
        switch ([responseType toInt32]) {
            case 0:
                NSLog(@"Fetched New Data");
                result = UIBackgroundFetchResultNewData;
                break;
            case 1:
                NSLog(@"Failed to get Data");
                result = UIBackgroundFetchResultFailed;
                break;
            default:
                NSLog(@"Fetched No Data");
                result = UIBackgroundFetchResultNoData;
                break;
        }
        if (weakSelf.completionHandler != nil) {
            weakSelf.completionHandler(result);
            weakSelf.completionHandler = nil;
        }
    };
}

- (void)storeDeviceToken:(CDVInvokedUrlCommand*)command
{
    NSString *deviceToken = [command argumentAtIndex:0];
    BOOL userVisible = [[command argumentAtIndex:1] boolValue];
    NSString *oldToken = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_STORAGE_KEY];
    if (![oldToken isEqualToString:deviceToken]) {
        [self dispatchSubscriptionChangeEvent];
    }
    [[NSUserDefaults standardUserDefaults] setBool:userVisible forKey:USER_VISIBLE_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DEVICE_TOKEN_STORAGE_KEY];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getDeviceToken:(CDVInvokedUrlCommand*)command
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:DEVICE_TOKEN_STORAGE_KEY];
    if (token != nil) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No Subscription"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (BOOL)hasPermission
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone;
    }
}
@end

