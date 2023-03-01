//
//  UpdateManager.m
//  Starts
//
//  Created by zss on 2018/9/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "UpdateManager.h"


@implementation UpdateManager

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"update_progress",@"onBackPressed"];
}


+ (UpdateManager *) sharedInstance

{
    static UpdateManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
      sharedInstance = [[UpdateManager alloc] init];
    });

    return sharedInstance;
}


- (void)sendUpdateProgress:(NSString *)message
{
  [self sendEventWithName:@"update_progress" body:@{@"value": message}];
}


RCT_EXPORT_METHOD(toast:(NSString *)text){
    if(text!=nil&&text!=@""){
        dispatch_async(dispatch_get_main_queue(), ^{
        [WHToast showMessage:text duration:2 finishHandler:^{
                      
                      }];
        });
    }
 
}



RCT_EXPORT_METHOD(exitApp){
    dispatch_async(dispatch_get_main_queue(), ^{
        exit(1);
    });
}

RCT_EXPORT_METHOD(open:(NSString *)type){
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
      [[UIApplication sharedApplication] openURL:url];
    }
}

@end
