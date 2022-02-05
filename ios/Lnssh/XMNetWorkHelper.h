//
//  XMNetWorkHelper.h
//  helo
//
//  Created by linxp on 2017/12/15.
//  Copyright © 2017年 Facebook. All rights reserved.
//
#ifndef XMNetWorkHelper_h
#define XMNetWorkHelper_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^XMCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^XMSuccessBlock)(NSDictionary *data);
typedef void (^XMFailureBlock)(NSError *error);
@interface XMNetWorkHelper : NSObject
/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;
/**
 * post请求
 */
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;
@end
#endif /* XMNetWorkHelper_h */
