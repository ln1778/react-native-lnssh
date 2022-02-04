//
//  DownloadTool.m
//  HMallsSellerApp
//
//  Created by linxp on 2017/12/15.
//  Copyright © 2017年 Facebook. All rights reserved.
//
#import "DownloadTool.h"
#import "UpdateDataLoader.h"
@implementation DownLoadTool
+ (DownLoadTool *) defaultDownLoadTool{
  static DownLoadTool *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[DownLoadTool alloc] init];
  });
  
  return sharedInstance;
}
//下载了一个dmg文件
//
-(void)downLoadWithUrl:(NSString*)url callback:(DoCallBack) cb{
  
  
  
  
  NSURL *downloadurl = [NSURL URLWithString:url];  //string>url
  
  [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:downloadurl] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    
    
    NSString *destinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingString:@"/IOSBundle"];
    NSString *filename = [destinationPath stringByAppendingString:@"/index.ios.bundle"];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:destinationPath];
    if (!blHave) {
      NSLog(@"no  have bundle file !!!!!");
      
    }else {
      NSLog(@" have");
      BOOL blDele= [fileManager removeItemAtPath:destinationPath error:nil];
      if (blDele) {
        [fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"dele success !!!");
      }else {
        NSLog(@"dele fail !!!!!");
      }
      
    }
    
    [data writeToFile: filename atomically: NO];
    
    NSLog(@"file download success：%@",filename);
    //self.zipPath = filename;
    
    cb(true);
    
    
  }];
  
  
  
}
//解压压缩包
-(BOOL)unZip{
  if (self.zipPath == nil) {
    return NO;
  }
  //检查Document里有没有bundle文件夹
  NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString* bundlePath = [path stringByAppendingPathComponent:@"kiOSfileSetName"];
  BOOL isDir;
  //如果有，则删除后解压，如果没有则直接解压
  if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDir]&&isDir) {
    [[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil];
  }
  NSString *zipPath = self.zipPath;
  NSString *destinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingString:@"/IOSBundle"];
  BOOL success = true;//[SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
  return success;
}
//删除压缩包
-(void)deleteZip{
  NSError* error = nil;
  [[NSFileManager defaultManager] removeItemAtPath:self.zipPath error:&error];
}
@end
