//
//  DownloadTool.h
//  HMallsSellerApp
//
//  Created by linxp on 2017/12/15.
//  Copyright © 2017年 Facebook. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DownLoadTool : NSObject
@property (nonatomic, strong) NSString *zipPath;
@property (nonatomic, strong) UIView*  view;
+ (DownLoadTool *) defaultDownLoadTool;
typedef void (^DoCallBack)(Boolean b); // 定义函数指针类型
//根据url下载相关文件
-(void)downLoadWithUrl:(NSString*)url callback:(DoCallBack)callback;
//解压压缩包
-(BOOL)unZip;
//删除压缩包
-(void)deleteZip;
@end
