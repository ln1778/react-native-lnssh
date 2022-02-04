//
//  UpdateManager.h
//  Starts
//
//  Created by zss on 2018/9/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//
#ifndef UpdateManager_h
#define UpdateManager_h
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <React/RCTEventEmitter.h>
#import <UserNotifications/UserNotifications.h>
#import <React/RCTEventEmitter.h>


#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface UpdateManager : RCTEventEmitter<RCTBridgeModule>
-(void)checkVersionUpdate:(Boolean *) toast hosturl:(NSString *)hosturl;
+(instancetype)sharedInstance;

@end
#endif /* UpdateManager_h */
