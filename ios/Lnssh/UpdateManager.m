//
//  UpdateManager.m
//  Starts
//
//  Created by zss on 2018/9/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "UpdateManager.h"
#import "UpdateDataLoader.h"
#import <React/RCTRootView.h>
#import "WHToast.h"
#import "RCTSplashScreen.h"
#import "XMNetWorkHelper.h"

@implementation UpdateManager

RCT_EXPORT_MODULE();

UpdateDataLoader* upLoatder;
UIViewController *rootViewController;
RCTRootView *rootView;
UIView *topView;
RCTSplashScreen *usplashScreen;
NSDictionary *dappdata;
NSDictionary *icondata;
bool *dapp_flag;
bool *icons_flag;

+(instancetype)sharedInstance

{static UpdateManager *instance = nil;

    if (instance == nil) {

      instance = [[UpdateManager alloc] init];

     }return instance;
    
}


-(void)checkVersionUpdate:(Boolean *) toast hosturl:(NSString *)hosturl{
    RCTLogInfo(@"to checking!!!");
    upLoatder = [UpdateDataLoader sharedInstance];
    //保证存放路径是存在的
    [upLoatder createPath];
    //检查更新并下载，有更新则直接下载，无则保持默认配置
    [upLoatder getAppVersion:hosturl,^(NSDictionary *data){
        NSLog(@"data:%@",data);
        NSLog(@"has_new11:%@",[data valueForKey:@"has_new"]);
        NSString *has_new=data[@"has_new"];
        if(has_new!=nil&&has_new!=@"0"){
            NSString *update_content=[data valueForKey:@"update_content"];
            if(rootViewController==nil){
                rootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
                                    while (rootViewController.presentedViewController)
                                      {
                                          rootViewController = rootViewController.presentedViewController;
                                      }
                }
            UIAlertController * _alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"version_update",nil) message:update_content!=nil?update_content:NSLocalizedString(@"update_content", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *_doAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"update_btn", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                 {
                   NSLog(@"点击确定按钮后，想要的操作，可以加此处");
                
                [[LoadingView sharedInstance]showLoadingViewWithTitle:NSLocalizedString(@"downing", nil) superView:rootViewController.view];
                        if(has_new==@"1"){
                            [upLoatder downLoad:^(NSDictionary *rs){
                                [[LoadingView sharedInstance] closeLoadingView];
                                [WHToast showMessage:NSLocalizedString(@"update_success",nil) duration:2 finishHandler:^{
                                
                                }];
                            }];
                        }else if(has_new==@"2"){
                            [upLoatder downLoadApp:^(NSDictionary *rs){
                                [[LoadingView sharedInstance] closeLoadingView];
                                
                            }];
                        }
                 }];
          
            UIAlertAction *_cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"next_waring",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                 {
                            NSLog(@"点击取消按钮后，想要的操作");
                       
                 }];
                 [_alertVC addAction:_doAction];
                 [_alertVC addAction:_cancleAction];
        
            
                 [rootViewController presentViewController:_alertVC animated:YES completion:nil];
        }else{
            if(toast){
                [WHToast showMessage:NSLocalizedString(@"last_version",nil) duration:2 finishHandler:^{
                
                }];
            }
        }
    }];
}

//
//RCT_EXPORT_METHOD(toast:(NSString *)text)
//{
//    [WHToast showMessage:text duration:2 finishHandler:^{
//
//    }];
//}

RCT_EXPORT_METHOD(onUpdateCancel)
{
    if(rootView!=nil&&topView!=nil){
        [topView willRemoveSubview:rootView];
    }
}

RCT_REMAP_METHOD(checkUpdate, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    
  RCTLogInfo(@"to checking!!!");
  upLoatder = [UpdateDataLoader sharedInstance];
  //保证存放路径是存在的
  [upLoatder createPath];
  //检查更新并下载，有更新则直接下载，无则保持默认配置
  [upLoatder getAppVersion:^(NSDictionary *data){
    resolve(data);
  }];
}
RCT_REMAP_METHOD(downloadNew, resolver:(RCTPromiseResolveBlock)resolve rejecter2:(RCTPromiseRejectBlock)reject2 )
{
  [upLoatder downLoad:^(NSDictionary *rs){
    resolve(rs);
  }];
}





@end
