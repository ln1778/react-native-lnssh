

#import <React/RCTRootView.h>
#import <React/RCTBridgeModule.h>

@interface RCTSplashScreen : NSObject <RCTBridgeModule>

-(void)show:(RCTRootView *)v;
-(void)hide;
+(instancetype)sharedInstance;
@end
