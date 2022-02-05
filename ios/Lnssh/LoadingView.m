#import "LoadingView.h"
#import "MBProgressHUD.h"
 
@implementation LoadingView
 
@synthesize HUD;
 
static LoadingView *_shardLoadingView = nil;
 
+ (LoadingView *)sharedInstance
{
    if (_shardLoadingView == nil) {
        _shardLoadingView = [[LoadingView alloc]init];
    }
    return _shardLoadingView;
}
 
- (id)init
{
    self = [super init];
    if (self) {
         HUD = [[MBProgressHUD alloc] init];
    }
    return self;
}
 
- (void)showLoadingViewWithTitle:(NSString *)title superView:(UIView *)superView
{
    HUD.label.text  = title;
    [superView addSubview:HUD];
    [superView bringSubviewToFront:HUD];
    [HUD showAnimated:YES];
 
}
 
- (void)showLoadingViewWithTitle:(NSString *)title afterDelay:(NSTimeInterval)delay superView:(UIView *)superView
{
    HUD.label.text = title;
    [superView addSubview:HUD];
    [superView bringSubviewToFront:HUD];
    [HUD showAnimated:YES];
 
    [HUD hideAnimated:YES afterDelay:delay];
}
 
- (void)closeLoadingView
{
    [HUD hideAnimated:YES];
}
 
@end
