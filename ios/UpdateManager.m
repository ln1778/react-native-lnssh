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
#import "Threema-Swift.h"
#import "LoadingView.h"
#import "NewMessageToaster.h"
#import "WHToast.h"
#import "RCTSplashScreen.h"
#import "XMNetWorkHelper.h"

@implementation UpdateManager

RCT_EXPORT_MODULE();

NewMessageToaster *toaster;
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


- (NSArray<NSString *> *)supportedEvents
{
  return @[@"Walletconnect"];
}

-(void)downDappData:(NSString *)hash{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    NSString *api=@"http://ipfs.hgmalls.com/ipfs/";
    api = [api stringByAppendingString:hash];
    NSDictionary *param=@{@"t":timeString};
    [XMNetWorkHelper getWithUrlString:api parameters:param success:^(NSDictionary *data) {
        NSLog(@"downDappData请求成功%@",data);
        dappdata=data;
    } failure:^(NSError *error) {
        NSLog(@"downDappData请求失败%@",error);
        
    }];
}
-(void)downIconsData:(NSString *)hash{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    NSString *api=@"http://ipfs.hgmalls.com/ipfs/";
    api = [api stringByAppendingString:hash];
    NSDictionary *param=@{@"t":timeString};
    
    [XMNetWorkHelper getWithUrlString:api parameters:param success:^(NSDictionary *data) {
        NSLog(@"downIconsData请求成功%@",data);
        icondata=data;
    } failure:^(NSError *error) {
        NSLog(@"downIconsData请求失败%@",error);
    }];
}

-(void)checkVersionUpdate:(Boolean *) toast{
    RCTLogInfo(@"to checking!!!");
    upLoatder = [UpdateDataLoader sharedInstance];
    //保证存放路径是存在的
    [upLoatder createPath];
    //检查更新并下载，有更新则直接下载，无则保持默认配置
    [upLoatder getAppVersion:^(NSDictionary *data){
        NSLog(@"data:%@",data);
        NSLog(@"has_new11:%@",[data valueForKey:@"has_new"]);
        NSString *has_new=data[@"has_new"];
        NSString *dapphash=data[@"dapphash"];
        NSString *iconhash=data[@"iconhash"];
        [self downDappData:dapphash];
        [self downIconsData:iconhash];
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
RCT_EXPORT_METHOD(getDappData:(RCTResponseSenderBlock)callback)
{
    if(dappdata!=nil&&!dapp_flag){
        dapp_flag=true;
        callback(@[dappdata]);
    }
}

RCT_EXPORT_METHOD(getIconData:(RCTResponseSenderBlock)callback)
{
    if(icondata!=nil&&!icons_flag){
        icons_flag=true;
        callback(@[icondata]);
    }
}

RCT_EXPORT_METHOD(toast:(NSString *)toast)
{
    [WHToast showMessage:toast duration:2 finishHandler:^{
      
    }];
}

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



RCT_EXPORT_METHOD(hide_Rn_loading:(NSString *)s)
{
  NSLog(@"hide_Rn_loading:%@",s);
    usplashScreen=[RCTSplashScreen sharedInstance];
    [usplashScreen hide];
}
RCT_EXPORT_METHOD(Lognet:(NSString *)s)
{
  NSLog(@"logs:%@",s);
}

RCT_EXPORT_METHOD(getDeviceToken:(RCTResponseSenderBlock)callback)
{
  NSString *token2=[UpdateDataLoader sharedInstance].device_token;
  
  if (token2 !=nil){
    callback(@[token2]);
  }else{
    callback(@ [@""]);
  }
}

RCT_EXPORT_METHOD(getHideNavigationBar:(RCTResponseSenderBlock)callback)
{
 callback(@[@"true"]);
}





@end
