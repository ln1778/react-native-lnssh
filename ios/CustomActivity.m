#import "CustomActivity.h"

@implementation CustomActivity

- (instancetype)initWithImage:(UIImage *)shareImage
                        atURL:(NSString *)URL
                      atTitle:(NSString *)title
          atShareContentArray:(NSArray *)shareContentArray {
    if (self = [super init]) {
        _shareImage = shareImage;
        _URL = URL;
        _title = title;
        _shareContentArray = shareContentArray;
    }
    return self;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return _title;
}

- (NSString *)activityTitle {
    return _title;
}

- (UIImage *)activityImage {
    return _shareImage;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    if (nil == _title) {
        return;
    }

    NSLog(@"%@", _shareContentArray);
    NSLog(@"%@", _title);

    [self activityDidFinish:YES];//默认调用传递NO
}

- (void)activityDidFinish:(BOOL)completed {
    if (completed) {
        NSLog(@"%s", __func__);
    }
}

@end
