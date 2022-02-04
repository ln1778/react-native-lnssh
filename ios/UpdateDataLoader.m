#import "UpdateDataLoader.h"
#import "DownloadTool.h"
#import "XMNetWorkHelper.h"
#import <sqlite3.h>




static sqlite3 *db;//是指向数据库的指针,我们其他操作都是用这个指针来完成
@implementation UpdateDataLoader
+ (UpdateDataLoader *) sharedInstance
{
  static UpdateDataLoader *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[UpdateDataLoader alloc] init];
  });

  return sharedInstance;
}


//创建bundle路径
-(void)createPath{
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
  NSString *path = [paths lastObject];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *directryPath = [path stringByAppendingPathComponent:@"IOSBundle"];
  
  if (![fileManager fileExistsAtPath:directryPath]) {
    [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
}
-(NSString*)useLocal{
  
  
  
  NSInteger localV=[self getLocalVersion];
  NSInteger localBuild=[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
  
  if(localV>localBuild){
    NSString* iOSBundlePath = [self iOSFileBundlePath];
    NSString* filePath=[iOSBundlePath stringByAppendingString:@"/index.bundle"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      return filePath;
    }
  }
  
  return nil;
}


//获取版本信息
-(void)getAppVersion:(CallBack)callback{
  
  [self createPath];
  
  //从服务器上获取版本信息,与本地plist存储的版本进行比较
  //假定返回的结果集
  /*{
   bundleVersion = 2;
   downloadUrl = "www.baidu.com";
   }*/
  
  
  NSInteger localV=[self getLocalVersion];
  
  
  
  
  NSInteger localBuild=[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
  
  NSLog(@"local version is ：%ld,src build is：%ld",(long)localV,(long)localBuild);
  
  if (localBuild>localV){
    localV=localBuild;
  }
  
  NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
  
  NSTimeInterval a=[dat timeIntervalSince1970];
  
  NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
  
  NSString *api=@"https://chatapp.hwanc.net/hwancchat/app/version.json";
  NSDictionary *param=@{@"t":timeString};
  
  [XMNetWorkHelper getWithUrlString:api parameters:param success:^(NSDictionary *data) {
    NSLog(@"请求成功%@",data);
    
    //2  服务器版本 假定为3
    NSInteger serviceV=0;
    //强力更新版本
    NSInteger qlServiceV=0;
    serviceV=[[NSString stringWithFormat:@"%@", data[@"ios_build"]] intValue];
    qlServiceV=[[NSString stringWithFormat:@"%@", data[@"ios_ql_build"]] intValue];
    NSLog(@"server version is：%ld",(long)serviceV);
    
    if(qlServiceV>localV){
      [data setValue:@"2" forKey:@"has_new"];
      [data setValue:data[@"ios_ql_url"] forKey:@"ios_ql_url"];
      callback(data);
      return;
    }
    
    if(serviceV>localV){
      //下载bundle文件 存储在 Doucuments/IOSBundle/下
      
      [data setValue:@"1" forKey:@"has_new"];
      
      
      
      //NSString*url=@"http://www.lsmalls.com/hmallsapp/index.ios.bundle";
      
      //[[DownLoadTool defaultDownLoadTool] downLoadWithUrl:url data:data];
      
      
      NSMutableDictionary *data2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", data[@"ios_build"]],@"bundleVersion",[NSString stringWithFormat:@"%@", data[@"ios_url"]],@"downloadUrl",nil];
      
      
      
      [UpdateDataLoader sharedInstance].versionInfo=data2;
      
      
      
      [self closeSqlite];
      
      callback(data);
      
    }else{
      [data setValue:@"0" forKey:@"has_new"];
      callback(data);
    }
    
  } failure:^(NSError *error) {
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"0", @"has_new",
                          nil];
     
    callback(dic2);
    NSLog(@"请求失败");
  }];
  
}
//获取版本信息
-(void)downLoad:(CallBack)cb{
  
  
  
  NSString* url=[NSString stringWithFormat:@"%@",[UpdateDataLoader sharedInstance].versionInfo[@"downloadUrl"]];
  
  [[DownLoadTool defaultDownLoadTool] downLoadWithUrl:url callback:^(Boolean t){
    
    if(t){
      [[UpdateDataLoader sharedInstance] writeAppVersionInfoWithDictiony:[UpdateDataLoader sharedInstance].versionInfo];
      
      
    }
    cb([UpdateDataLoader sharedInstance].versionInfo);
    
    
  }];
  
  
  //NSMutableDictionary *data2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", data[@"datas"][@"build"]],@"bundleVersion",[NSString stringWithFormat:@"%@", data[@"datas"][@"url"]],@"downloadUrl",nil];
  
  
  
}
//获取版本信息
-(void)downLoadApp:(CallBack)cb{
  NSString* iosurl=[NSString stringWithFormat:@"%@",[UpdateDataLoader sharedInstance].versionInfo[@"downloadUrl"]];
    NSURL *url =[NSURL URLWithString:[iosurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"url:%@",url);
    [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
          cb([UpdateDataLoader sharedInstance].versionInfo);
    }];
}


//获取Bundle 路径
-(NSString*)iOSFileBundlePath{
  //获取沙盒路径
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString* path = [paths objectAtIndex:0];
  NSLog(@"the save version file's path is :%@",path);
  //填写文件名
  NSString* filePath = [path stringByAppendingPathComponent:@"/IOSBundle"];
  return  filePath;
}
//获取版本信息储存的文件路径
-(NSString*)getVersionPlistPath{
  
  NSString *destinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingString:@"/IOSBundle/version.json"];
  return destinationPath;
}
//创建或修改版本信息
-(void)writeAppVersionInfoWithDictiony:(NSMutableDictionary*)dictionary{
  
  
  [self openSqlite];
  
  NSInteger new_version=[dictionary[@"bundleVersion"] integerValue];
  
  NSLog(@"写入新版本 %zd",(long)new_version);
  
  NSString *sqlite = [NSString stringWithFormat:@"insert into bundle_version(version) values ('%zd')",new_version];
  //2.执行sqlite语句
  char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
  int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
  if (result == SQLITE_OK) {
    NSLog(@"添加数据成功");
  } else {
    NSLog(@"添加数据失败");
  }
  
  
  
  [self closeSqlite];
  
}
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
  
  NSError *parseError = nil;
  
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
  
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  
}
- (int)getLocalVersion {
  
  int localV=0;
  
  [self openSqlite];
  [self createTable];
  
  //1.准备sqlite语句
  NSString *sqlite = [NSString stringWithFormat:@"select * from bundle_version order by id desc limit 1"];
  
  //2.伴随指针
  sqlite3_stmt *stmt = NULL;
  //3.预执行sqlite语句
  int result = sqlite3_prepare(db, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
  if (result == SQLITE_OK) {
    NSLog(@"查询成功");
    //4.执行n次
    while (sqlite3_step(stmt) == SQLITE_ROW) {
      
      //从伴随指针获取数据,第0列
      
      //从伴随指针获取数据,第1列
      localV = sqlite3_column_int(stmt, 1);
    }
  } else {
    NSLog(@"查询失败");
  }
  //5.关闭伴随指针
  sqlite3_finalize(stmt);
  
  
  [self closeSqlite];
  return localV;
}
- (void)openSqlite {
  //判断数据库是否为空,如果不为空说明已经打开
  if(db != nil) {
    NSLog(@"数据库已经打开");
    return;
  }
  
  //获取文件路径
  NSString *str = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *strPath = [str stringByAppendingPathComponent:@"my.sqlite"];
  NSLog(@"%@",strPath);
  //打开数据库
  //如果数据库存在就打开,如果不存在就创建一个再打开
  int result = sqlite3_open([strPath UTF8String], &db);
  //判断
  if (result == SQLITE_OK) {
    NSLog(@"数据库打开成功");
  } else {
    NSLog(@"数据库打开失败");
  }
}
#pragma mark - 3.增删改查
//创建表格
- (void)createTable {
  //1.准备sqlite语句
  NSString *sqlite = [NSString stringWithFormat:@"create table if not exists 'bundle_version' ('id' integer primary key autoincrement not null,'version' integer)"];
  //2.执行sqlite语句
  char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
  int result = sqlite3_exec(db, [sqlite UTF8String], nil, nil, &error);
  //3.sqlite语句是否执行成功
  
  if (result == SQLITE_OK) {
    NSLog(@"创建表成功");
  } else {
    NSLog(@"创建表失败");
  }
}
#pragma mark - 4.关闭数据库
- (void)closeSqlite {
  
  int result = sqlite3_close(db);
  if (result == SQLITE_OK) {
    db=nil;
    NSLog(@"数据库关闭成功");
  } else {
    NSLog(@"数据库关闭失败");
  }
}

@end
