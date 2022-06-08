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


+(instancetype)sharedInstance

{static UpdateManager *instance = nil;

    if (instance == nil) {

      instance = [[UpdateManager alloc] init];

     }return instance;
    
}

RCT_EXPORT_METHOD(toast:(NSString *)text){
    if(text!=nil&&text!=@""){
        dispatch_async(dispatch_get_main_queue(), ^{
        [WHToast showMessage:text duration:2 finishHandler:^{
                      
                      }];
        });
    }
 
}






@end
