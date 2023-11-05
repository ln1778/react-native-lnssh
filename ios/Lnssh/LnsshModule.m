
#import "LnsshModule.h"
#import "DownloadTool.h"

@implementation LnsshModule





UIViewController *topRootViewController;

UpdateDataLoader *upLoatder;
RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(splash_show){
    [RCTSplashScreen splashshow];
}

RCT_EXPORT_METHOD(splash_hide){
    [RCTSplashScreen splashhide];
}

RCT_EXPORT_METHOD(checkUpdate:(NSString *)hosturl resolve:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject ){
    RCTLogInfo(@"to checking!!!");
  upLoatder = [UpdateDataLoader sharedInstance];
  //保证存放路径是存在的
  [upLoatder createPath];
    
    [upLoatder getAppVersion:hosturl callback:^(NSDictionary *data) {
        resolve(data);
    }];
}

RCT_EXPORT_METHOD(isInstallPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject ){
   resolve(@"true");
}
RCT_EXPORT_METHOD(openInstallPermission:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
    resolve(@"true");
}
RCT_EXPORT_METHOD(restartApp){
   
}

RCT_EXPORT_METHOD(downloadNew:(NSString *)has_new resolve:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject ){
    [upLoatder downLoad:has_new callback:^(NSDictionary *data) {
        resolve(data);
    }];
}
RCT_EXPORT_METHOD(InstallApk:(NSString *)path resolve:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject ){
    resolve(@"true");
}

RCT_EXPORT_METHOD(goshareToSocial:(NSDictionary *)details resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    dispatch_async(dispatch_get_main_queue(), ^{
    NSData *decodedImageData;
    UIImage *shareImage=[UIImage imageNamed:@"logo"];
    UIActivityViewController *activityVC;
    NSString *title = details[@"title"]?details[@"title"]:@"";
    NSString *content =details[@"content"]?details[@"content"]:@"";
    NSString *image =details[@"image"]?details[@"image"]:@"logo";
    NSString *url =details[@"url"]?details[@"url"]:nil;
    
    if([NSURL URLWithString:url]){
        NSMutableArray *activityItems;
        activityItems = [NSMutableArray array];
        if(title==@""){
            [activityItems addObject:content];
        }else{
            [activityItems addObject:title];
        }
         [activityItems addObject:[NSURL URLWithString:url]];
        NSString *regex = @"^http.*";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL result = [predicate evaluateWithObject:image];
        if(result){
            if ([NSData dataWithContentsOfFile:image]) {
                  [activityItems addObject:[NSData dataWithContentsOfFile:image]];
              }
        }else{
            if(image&&image==@"logo"){
                if ([NSData dataWithContentsOfFile:image]) {
                      [activityItems addObject:[NSData dataWithContentsOfFile:image]];
                  }
            }else{
                decodedImageData = [[NSData alloc]initWithBase64EncodedString:image options:NSDataBase64DecodingIgnoreUnknownCharacters];
                [activityItems addObject:decodedImageData];
            }
        }
       activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    }else{
        NSLog(@"nourl");
        NSArray* activityItems;
        NSString *regex = @"^http.*";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL result = [predicate evaluateWithObject:image];
        if(result){
            shareImage = [UIImage imageWithData:image];
            if(title==@""){
                activityItems=@[content,shareImage];
            }else{
                activityItems=@[title,shareImage];
            }
        }else{
        if(image&&image==@"logo"){
                if(title==@""){
                    activityItems=@[content];
                }else{
                    activityItems=@[title];
                }
            }else{
                decodedImageData = [[NSData alloc]initWithBase64EncodedString:image options:NSDataBase64DecodingIgnoreUnknownCharacters];
                shareImage = [UIImage imageWithData:decodedImageData];
                if(title==@""){
                    activityItems=@[content,shareImage];
                }else{
                    activityItems=@[title,shareImage];
                }
            }
        }
      
       activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = [self excludetypes];
    }
 
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

        NSDictionary *result=@{};
        if(activityError!=nil){
            result = @{@"errorCode":@"400", @"errorMessage":activityError};
            resolve(result);
        }else{
            if (completed) {
                result = @{@"share_state":@"true"};
                resolve(result);
                NSLog(@"completed%@",activityType);
                //分享 成功
            } else  {
                NSLog(@"cancled");
                result = @{@"errorCode":@"400",@"errorMessage":@"您已取消了分享",@"didCancel":@"true"};
                resolve(result);
                }
            };
    };
  
    topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
    // 然后再进行present操作
    if(topRootViewController!=nil){
        while (topRootViewController.presentedViewController)
          {
              // 这里固定写法
            topRootViewController = topRootViewController.presentedViewController;
          }
       
         [topRootViewController presentViewController:activityVC animated:YES completion:nil];
       
    }
    });
}

RCT_EXPORT_METHOD(isPinCodeWithImage:(NSString *)imageName callback:(RCTResponseSenderBlock)callback){
     NSString *content = @"" ;
//      NSURL *imagesrc = [NSURL URLWithString:[self.dataURL2Image imageName]];
       NSURL *url = [NSURL URLWithString: imageName];
      NSData *data = [NSData dataWithContentsOfURL: url];
    CIImage* _imageView=[CIImage imageWithData:data];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                 context:[CIContext contextWithOptions:nil]
                                                 options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
       NSArray *features = [detector featuresInImage:_imageView];
       if (features.count) {
           for (CIFeature *feature in features) {
               if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
                   content = ((CIQRCodeFeature *)feature).messageString;
                     callback(@[[NSNull null], content]);
                   break;
               }
           }
       } else {
           NSLog(@"未正常解析二维码图片, 请确保iphone5/5c以上的设备");
       }
}

-(NSArray *)excludetypes{
  NSMutableArray *excludeTypesM =  [NSMutableArray arrayWithArray:@[//UIActivityTypePostToFacebook,
                                                                     UIActivityTypePostToTwitter,
                                                                    UIActivityTypePostToWeibo,
                                                                    UIActivityTypeMessage,
                                                                   UIActivityTypeMail,
                                                                   UIActivityTypePrint,
                                                                 UIActivityTypeCopyToPasteboard,
                                                                   UIActivityTypeAssignToContact,
                                                                UIActivityTypeSaveToCameraRoll,
                                                                  UIActivityTypeAddToReadingList,
                                                                 UIActivityTypePostToFlickr,
                                                                 UIActivityTypePostToVimeo,
                                                                UIActivityTypePostToTencentWeibo,
                                                                      UIActivityTypeAirDrop,
                                                                 UIActivityTypeOpenInIBooks]];
  
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0) {
      [excludeTypesM addObject:UIActivityTypeMarkupAsPDF];
  }
  
  return excludeTypesM;
}

+ (NSString *)stringFromCiImage:(CIImage *)ciimage {

    NSString *content = @"" ;
    if (!ciimage) {
        return content;
    }
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:[CIContext contextWithOptions:nil]
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciimage];
    if (features.count) {
        for (CIFeature *feature in features) {
            if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
                content = ((CIQRCodeFeature *)feature).messageString;
                break;
            }
        }
    } else {
        NSLog(@"未正常解析二维码图片, 请确保iphone5/5c以上的设备");
    }
    return content;

}

RCT_EXPORT_METHOD(saveImage:(NSString *)imageurl callback:(RCTResponseSenderBlock)callback){
//    NSArray *imageArray = [imageurl componentsSeparatedByString:@","];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageurl options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:imageData];
    NSLog(@"img%@",image);
    if(image!=nil){
      
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
               [PHAssetChangeRequest creationRequestForAssetFromImage:image];
           } completionHandler:^(BOOL success, NSError * _Nullable error) {
          
               if (error) {
                   NSLog(@"error:",error);
                   NSLog(@"%@",@"保存失败");
                   callback(@[@"failed"]);
               } else {
                   NSLog(@"%@",@"保存成功");
                   callback(@[@"true"]);
               }
           }];
    }else{
        NSLog(@"error:",@"图片解析错误");
        callback(@[@"failed"]);
    }
  
}

RCT_EXPORT_METHOD(donwloadSaveImg:(NSString *)filePaths resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    UIImage *image=[UIImage imageNamed:filePaths];
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
           [PHAssetChangeRequest creationRequestForAssetFromImage:image];
       } completionHandler:^(BOOL success, NSError * _Nullable error) {
           if (error) {
               NSLog(@"%@",@"保存失败");
               resolve(@[@"false"]);
           } else {
               NSLog(@"%@",@"保存成功");
               resolve(@[@"true"]);
           }
       }];
}


@end
