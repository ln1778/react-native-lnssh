
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <UserNotifications/UserNotifications.h>
#import "WHToast.h"

@interface UpdateManager : NSObject<RCTBridgeModule>
+(instancetype)sharedInstance;

@end
