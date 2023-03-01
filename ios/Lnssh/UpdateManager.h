
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <UserNotifications/UserNotifications.h>
#import "WHToast.h"
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeDelegate.h>

@interface UpdateManager :RCTEventEmitter<RCTBridgeModule,RCTBridgeDelegate>
+ (UpdateManager *) sharedInstance;
- (void)sendUpdateProgress:(NSString *)message;

@end
