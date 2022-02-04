
#import "RCTSplashScreen.h"

static RCTRootView *rootView = nil;

@interface RCTSplashScreen()



@end


@implementation RCTSplashScreen

UIImageView *gifImageView;


+(instancetype)sharedInstance

{static RCTSplashScreen *instance = nil;

    if (instance == nil) {

      instance = [[RCTSplashScreen alloc] init];

     }
    return instance;
}


- (void)show:(RCTRootView *)v {
    rootView = v;
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"spleash" withExtension:@"gif"];
      NSData *date = [NSData dataWithContentsOfURL:fileUrl];
    [[NSNotificationCenter defaultCenter] removeObserver:rootView  name:RCTContentDidAppearNotification object:rootView];
    [self animationWithImageArr:[self praseGIFDataToImageArray:date]];
    // [rootView setLoadingView:view];

}
- (NSMutableArray *)praseGIFDataToImageArray:(NSData *)data;

{

    NSMutableArray *images = [[NSMutableArray alloc] init];

    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);

    if (src) {

        size_t l = CGImageSourceGetCount(src);

        images = [NSMutableArray arrayWithCapacity:l];

        for (size_t i = 0; i < l; i++) {

            CGImageRef imgRef = CGImageSourceCreateImageAtIndex(src, i, NULL);

            UIImage *aImage = [[UIImage alloc]initWithCGImage:imgRef];

            [images addObject:aImage];

        }

        CFRelease(src);

    }

    return images;

}
-(void)animationWithImageArr:(NSMutableArray *)imagesArray

{
    gifImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSArray *gifArray = [imagesArray mutableCopy];

    gifImageView.animationImages = gifArray; //动画图片数组

    gifImageView.animationDuration = 4; //执行一次完整动画所需的时长

    gifImageView.animationRepeatCount = MAXFLOAT;  //动画重复次数

    [gifImageView startAnimating];
    NSLog(@"gifomage",@"true");
    [rootView addSubview:gifImageView];

}
-(void)hide{
    if (!rootView) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                      dispatch_get_main_queue(),
                      ^{
                          [UIView transitionWithView: rootView
                                            duration:1
                                             options:UIViewAnimationOptionTransitionCrossDissolve
                                          animations:^{
                              if(gifImageView!=nil){
                                  [gifImageView stopAnimating];
                                  gifImageView.hidden = YES;
                              }
                                          } completion:^(__unused BOOL finished) {
                                              [gifImageView removeFromSuperview];
                                          }];
                      });
}


@end
