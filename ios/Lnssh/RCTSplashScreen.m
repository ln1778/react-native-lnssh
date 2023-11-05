#import "RCTSplashScreen.h"

static UIView *rootView = nil;
static UIImageView *view=nil;

@interface RCTSplashScreen()

@end

@implementation RCTSplashScreen

RCT_EXPORT_MODULE(SplashScreen)

+ (void)show:(UIView *)v {
    rootView = v;
   // v.frame=[UIApplication sharedApplication].delegate.window.frame;
    view = [[UIImageView alloc] init];
    view.frame=[UIApplication sharedApplication].delegate.window.frame;
    view.backgroundColor=[UIColor blueColor];
    view.image = [UIImage imageNamed:@"splash.jpg"];
//    [[NSNotificationCenter defaultCenter] removeObserver:rootView  name:RCTContentDidAppearNotification object:rootView];
    NSLog(@"splash_show");
    [v addSubview:view];
}
+ (void)splashshow{
    NSLog(@"splash_show000");
    if (!rootView||!view) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"splash_show111");
    [rootView addSubview:view];
      //  [rootView setLoadingView:view];
    });
}

+ (void)splashhide{
    NSLog(@"splash_show000");
    if (!rootView) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
        [view removeFromSuperview];
                   });
}

RCT_EXPORT_METHOD(hide) {
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
                                          view.hidden = YES;
                                       } completion:^(__unused BOOL finished) {
                                           [view removeFromSuperview];
                                       }];
                   });
}

@end
