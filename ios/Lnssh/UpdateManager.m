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
#import "LoadingView.h"


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
    [upLoatder getAppVersion:hosturl callback:^(NSDictionary *data) {
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
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * _alertVC = [UIAlertController alertControllerWithTitle:@"版本更新" message:update_content!=nil?update_content:@"更新内容" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *_doAction = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                 {
                   NSLog(@"点击确定按钮后，想要的操作，可以加此处");
                [WHToast showMessage:@"后台静默下载中" duration:2 finishHandler:^{
                
                }];
              [[LoadingView sharedInstance]showLoadingViewWithTitle:@"下载中" superView:rootViewController.view];
                        if(has_new==@"1"){
                            [upLoatder downLoad:^(NSDictionary *rs){
                              [[LoadingView sharedInstance] closeLoadingView];
                                [WHToast showMessage:@"更新完成" duration:2 finishHandler:^{
                                    NSLog(@"更新完成1");
                                }];
                            }];
                        }else if(has_new==@"2"){
                            [upLoatder downLoadApp:^(NSDictionary *rs){
                              [[LoadingView sharedInstance] closeLoadingView];
                                NSLog(@"更新完成2");
                            }];
                        }
                 }];
          
            UIAlertAction *_cancleAction = [UIAlertAction actionWithTitle:@"下次提醒" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                 {
                            NSLog(@"点击取消按钮后，想要的操作");
                       
                 }];
                 [_alertVC addAction:_doAction];
                 [_alertVC addAction:_cancleAction];
        
            
                 [rootViewController presentViewController:_alertVC animated:YES completion:nil];
            });
        }else{
            if(toast){
                [WHToast showMessage:@"已经上最新版本" duration:2 finishHandler:^{
                
                }];
            }
        }
    }];
}






@end
