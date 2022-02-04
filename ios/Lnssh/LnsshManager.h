//
//  Lnssh.h
//  Lnssh
//
//  Created by ln on 2022/2/4.
//

#import <Foundation/Foundation.h>

@interface LnsshManager : NSObject
+ (void)show:(RCTRootView *)v;
+(void)CheckVersionHost:(NSString *)hosturl;
@end
