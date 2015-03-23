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

@implementation CDVPush

@synthesize completionHandler;
@synthesize serviceWorker;

- (void)pluginInitialize
{
    self.serviceWorker = [(CDVViewController*)self.viewController getCommandInstance:@"ServiceWorker"];
    [self setupSyncResponse];
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
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    self.completionHandler = completionHandler;
    [serviceWorker.context evaluateScript:@"FirePushEvent();"];
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
        weakSelf.completionHandler(result);
        weakSelf.completionHandler = nil;
    };
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

