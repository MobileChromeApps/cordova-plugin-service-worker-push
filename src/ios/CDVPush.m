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

#import <Cordova/CDV.h>
#import "CDVPush.h"
#import <JavaScriptCore/JavaScriptCore.h>

NSString *DEVICE_TOKEN_STORAGE_KEY;

@implementation CDVPush

@synthesize completionHandler;
@synthesize serviceWorker;

- (void)setupPush:(CDVInvokedUrlCommand*)command
{
    DEVICE_TOKEN_STORAGE_KEY = [NSString stringWithFormat:@"%@/%@", @"CDVPush_devicetoken_", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    self.serviceWorker = [(CDVViewController*)self.viewController getCommandInstance:@"ServiceWorker"];
    [self setupSyncResponse];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
    NSString *dispatchCode = [NSString stringWithFormat:@"FirePushEvent(JSON.parse('%@'));", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [serviceWorker.context performSelectorOnMainThread:@selector(evaluateScript:) withObject:dispatchCode waitUntilDone:NO];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    self.completionHandler = completionHandler;
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
    NSString *dispatchCode = [NSString stringWithFormat:@"FirePushEvent(JSON.parse('%@'));", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [serviceWorker.context performSelectorOnMainThread:@selector(evaluateScript:) withObject:dispatchCode waitUntilDone:NO];

}

- (void)setupSyncResponse
{
    __weak CDVPush *weakSelf = self;
    serviceWorker.context[@"sendSyncResponse"] = ^(JSValue *responseType) {
        UIBackgroundFetchResult result;
        switch ([responseType.toNumber integerValue]) {
            case 0:
                result = UIBackgroundFetchResultNewData;
                break;
            case 1:
                result = UIBackgroundFetchResultFailed;
                break;
            default:
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:DEVICE_TOKEN_STORAGE_KEY];
    [defaults synchronize];
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

