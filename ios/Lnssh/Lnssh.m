//
//  Lnssh.m
//  Lnssh
//
//  Created by ln on 2022/2/4.
//

#import "Lnssh.h"
#import "RCTSplashScreen.h"
#import "UpdateManager.h"


@implementation Lnssh


+ (void)show:(RCTRootView *)v {
    [RCTSplashScreen show:v];
}
+(void)CheckVersionHost:(NSString *)hosturl{
    [[UpdateManager sharedInstance] checkVersionUpdate:false hosturl:hosturl];
}

@end
