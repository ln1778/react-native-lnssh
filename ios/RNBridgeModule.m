//
//  RNBridgeModule.m
//  MyApp
//
//  Created by liyong dai on 2020/8/5.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNBridgeModule.h"

//#import "MarketController.h"

#import "AppDelegate.h"
@implementation RNBridgeModule

RCT_EXPORT_MODULE(RNBridgeModule)

RCT_EXPORT_METHOD(RNOpenOneVC:(NSDictionary *)msg){
  dispatch_async(dispatch_get_main_queue(), ^{
//    MarketController *one = [[MarketController markets] init];
//    [[MarketController markets] onSetStart:msg];
//      NSLog(@"RNOpenOneVC:");
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [app.nav pushViewController:one animated:YES];
  });
}

@end
