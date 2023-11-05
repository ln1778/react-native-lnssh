

#import <React/RCTRootView.h>
#import <React/RCTBridgeModule.h>

@interface RCTSplashScreen : NSObject <RCTBridgeModule>

+(void)show:(UIView *)v;
+ (void)splashshow;
+ (void)splashhide;
@end
