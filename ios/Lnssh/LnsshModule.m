#import <UIKit/UIKit.h>
#import "LnsshModule.h"
#import "UpdateManager.h"
#import "RCTSplashScreen.h"


@implementation LnsshModule

RCTPromiseResolveBlock *imgpromise;
RCTPromiseRejectBlock *imgreject;
CallBack *imgback;

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

RCT_EXPORT_METHOD(splash_show){
    [RCTSplashScreen splashshow];
}
RCT_EXPORT_METHOD(splash_hide){
    [RCTSplashScreen hide];
}


RCT_EXPORT_METHOD(check_version:(NSString *)hosturl){
    [[UpdateManager sharedInstance] checkVersionUpdate:true hosturl:hosturl];
}


RCT_EXPORT_METHOD(goshareToSocial:(NSDictionary *)details callback:(RCTResponseSenderBlock)callback){
    NSData *decodedImageData;
    UIImage *shareImage=[UIImage imageNamed:@"QRlogo"];
    UIActivityViewController *activityVC;
    NSString *title = details[@"title"]?details[@"title"]:@"";
    NSString *content =details[@"content"]?details[@"content"]:@"";
    NSString *image =details[@"image"]?details[@"image"]:@"logo";
    NSString *url =details[@"url"]?details[@"url"]:nil;
    if([NSURL URLWithString:url]) {
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
        NSDictionary *backdata;
        
        if(activityError!=nil){
            [backdata setValue:@"400" forKey:@"errorCode"];
            [backdata setValue:activityError forKey:@"errorMessage"];
            callback(backdata);
        }else{
            if (completed) {
                [backdata setValue:@"true" forKey:@"share_state"];
                callback(backdata);
                NSLog(@"completed%@",activityType);
                //分享 成功
                } else  {
                NSLog(@"cancled");
                    [backdata setValue:@"true" forKey:@"didCancel"];
                    callback(backdata);
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
        dispatch_async(dispatch_get_main_queue(), ^{
         [topRootViewController presentViewController:activityVC animated:YES completion:nil];
        });
    }
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

RCT_EXPORT_METHOD(saveImage:(NSString *) imageurl callback:(CallBack)callback){
    NSArray *imageArray = [imageurl componentsSeparatedByString:@","];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageArray[1] options:NSDataBase64DecodingIgnoreUnknownCharacters];];
    UIImage *image = [UIImage imageWithData:imageData];
    imgback=callback;
    UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    callback(@"true");
}

RCT_EXPORT_METHOD(donwloadSaveImg:(NSString *) filePaths (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject ){
    UIImage *img=[UIImage imageNamed:filePaths];
    imgpromise=resolve;
    imgreject=rejecter;
    UIImageWriteToSavedPhotosAlbum(img, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
}
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
        if(imgpromise!=nil){
            imgpromise(@"false");
            imgpromise=nil;
        }
        if(imgback!=nil){
            imgback(@"false");
            imgback=nil;
        }
    }else{
        if(imgback!=nil){
            imgback(@"true");
            imgback=nil;
        }
        msg = @"保存图片成功" ;
        if(imgreject!=nil){
            imgreject(@"true");
            imgreject=nil;
        }
    }
}


@end
