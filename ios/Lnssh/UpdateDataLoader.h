#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "WHToast.h"

@interface UpdateDataLoader:RCTEventEmitter<RCTBridgeModule>

@property (nonatomic, strong) NSMutableDictionary* versionInfo;
@property (nonatomic, strong) NSString* device_token;




+ (UpdateDataLoader *) sharedInstance;

typedef void (^CallBack)(NSDictionary *data); // 定义函数指针类型
//创建bundle路径
-(void)createPath;
//获取版本信息
-(void)getAppVersion:(NSString *)hosturl callback:(CallBack)callback;
-(void)downLoad:(NSString *)has_new callback:(CallBack)callback;
-(void)downLoadApp:(CallBack)callback;

-(void)writeAppVersionInfoWithDictiony:(NSMutableDictionary*)info;
-(NSString*)iOSFileBundlePath;
-(NSString*)useLocal;
@end
