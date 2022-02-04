#import <Foundation/Foundation.h>
@class MBProgressHUD;
 
@interface LoadingView : NSObject
 
@property (nonatomic, retain) MBProgressHUD *HUD;
 
+ (LoadingView *)sharedInstance;
 
/**
 *  加载中提示框
 *
 *  @param title     标题
 *  @param superView 父View
 */
- (void)showLoadingViewWithTitle:(NSString *)title superView:(UIView *)superView;
 
/**
 *  加载中提示框
 *
 *  @param title     标题
 *  @param delay     关闭时间
 *  @param superView 父View
 */
- (void)showLoadingViewWithTitle:(NSString *)title afterDelay:(NSTimeInterval)delay superView:(UIView *)superView;
 
/**
 *  关闭提示框
 */
- (void)closeLoadingView;
 
@end
