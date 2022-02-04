#import "RCTpermissionSetting.h"



@interface RCTpermissionSetting: NSObject <RCTBridgeModule>

@end
@implementation RCTpermissionSetting






RCT_EXPORT_MODULE(permissionSetting);


RCT_EXPORT_METHOD(goPermission){
  NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
  if([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url];
  }
}

RCT_EXPORT_METHOD(goWifi){
  NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
  if([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url];
  }
}




-(float)folderSizeAtPath:(NSString *)path{
   int totalSize = 0;
  
  // 1.获得文件夹管理者
  NSFileManager *mgr = [NSFileManager defaultManager];
  
  // 2.检测路径的合理性
  BOOL dir = NO;
  BOOL exits = [mgr fileExistsAtPath:path isDirectory:&dir];
  if (!exits) return 0;
  
  // 3.判断是否为文件夹
  if (dir)//文件夹, 遍历文件夹里面的所有文件
  {
    //这个方法能获得这个文件夹下面的所有子路径(直接\间接子路径),包括子文件夹下面的所有文件及文件夹
    NSArray *subPaths = [mgr subpathsAtPath:path];
    
    //遍历所有子路径
    for (NSString *subPath in subPaths)
    {
      //拼成全路径
      NSString *fullSubPath = [path stringByAppendingPathComponent:subPath];
      
      BOOL dir = NO;
      [mgr fileExistsAtPath:fullSubPath isDirectory:&dir];
      if (!dir)//子路径是个文件
      {
        //如果是数据库文件，不加入计算
        NSDictionary *attrs = [mgr attributesOfItemAtPath:fullSubPath error:nil];
        totalSize += [attrs[NSFileSize] intValue];
      }
    }
    totalSize = totalSize / (1024 * 1024.0);//单位M
  }
  else//文件
  {
    NSDictionary *attrs = [mgr attributesOfItemAtPath:path error:nil];
    totalSize = [attrs[NSFileSize] intValue] / (1024 * 1024.0);//单位M
  }
  return totalSize;
}

RCT_EXPORT_METHOD(getCacheSize:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
  NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSNumber *resultDic;
  resultDic=@([self folderSizeAtPath:cachePath]);
    resolve(resultDic);
}
RCT_EXPORT_METHOD(clearCache:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
  NSString *cachesPath =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES).lastObject;
  [self clearCache:cachesPath];
  resolve(@"true");
}
//进行清理

- (void)clearCache:(NSString *)path{
  NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
  for (NSString *p in files)
  {
    NSError *error;
    NSString *path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
      [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
  }

}

RCT_EXPORT_METHOD(getNotification:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
  [self requestNotification];
  __block BOOL enabled = NO;
  if (@available(iOS 10.0, *)) {
    dispatch_semaphore_t sem;
    sem = dispatch_semaphore_create(0);
    UNUserNotificationCenter *notificationCenter=[UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      switch (settings.authorizationStatus) {
        case UNAuthorizationStatusAuthorized:
          enabled = YES;
          break;
        default:
          break;
      }
      dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER); //获取通知设置的过程是异步的，这里需要等待
  } else {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
      UIUserNotificationSettings *settings = [application currentUserNotificationSettings];
      if (settings.types != UIUserNotificationTypeNone) {
        enabled = YES;
      }
    }
  }
  resolve(@(enabled));
}

-(void) requestNotification
{
  if (@available(iOS 10, *))
  {
    UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
      
      if (granted) {
        // 允许推送
      }else{
        //不允许
      }
      
    }];
  }
  else if(@available(iOS 8 , *))
  {
    UIApplication * application = [UIApplication sharedApplication];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    [application registerForRemoteNotifications];
  }
  else
  {
    UIApplication * application = [UIApplication sharedApplication];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    [application registerForRemoteNotifications];
  }
}


@end
