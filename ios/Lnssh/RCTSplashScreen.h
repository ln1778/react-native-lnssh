

#import <React/RCTRootView.h>
#import <React/RCTBridgeModule.h>

@interface RCTSplashScreen : NSObject <RCTBridgeModule>

+(void)show:(RCTRootView *)v;
+ (void)splashshow;
+(void)hide;
@end
