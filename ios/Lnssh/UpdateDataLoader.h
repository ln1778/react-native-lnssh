#import <Foundation/Foundation.h>
@interface UpdateDataLoader : NSObject
@property (nonatomic, strong) NSMutableDictionary* versionInfo;
@property (nonatomic, strong) NSString* device_token;




+ (UpdateDataLoader *) sharedInstance;
typedef void (^CallBack)(NSDictionary *data); // 定义函数指针类型
//创建bundle路径
-(void)createPath;
//获取版本信息
-(void)getAppVersion:(CallBack)callback;
-(void)downLoad:(CallBack)callback;
-(void)downLoadApp:(CallBack)callback;

-(void)writeAppVersionInfoWithDictiony:(NSMutableDictionary*)info;
-(NSString*)iOSFileBundlePath;
-(NSString*)useLocal;
@end
