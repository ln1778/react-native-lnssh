#import "RCTSplashScreen.h"

static RCTRootView *rootView = nil;
static UIImageView *view=nil;

@interface RCTSplashScreen()

@end

@implementation RCTSplashScreen

RCT_EXPORT_MODULE(SplashScreen)

+ (void)show:(RCTRootView *)v {
    rootView = v;
    rootView.frame=[UIApplication sharedApplication].delegate.window.frame;
    view = [[UIImageView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
    view.image = [UIImage imageNamed:@"splash"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:rootView  name:RCTContentDidAppearNotification object:rootView];
    NSLog(@"splash_show");
    dispatch_async(dispatch_get_main_queue(), ^{
    [rootView addSubview:view];
    });
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

RCT_EXPORT_METHOD(hide) {
    if (!rootView) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(rootView.loadingViewFadeDuration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       [UIView transitionWithView: rootView
                                         duration:rootView.loadingViewFadeDelay
                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                       animations:^{
                                          view.hidden = YES;
                                       } completion:^(__unused BOOL finished) {
                                           [view removeFromSuperview];
                                       }];
                   });
}

@end
