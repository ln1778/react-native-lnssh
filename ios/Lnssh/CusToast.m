#import "CusToast.h"

@implementation CusToast

RCT_EXPORT_MODULE(Toast);


RCT_EXPORT_METHOD(info:(NSString *)text){
  [WHToast showMessage:text duration:2 finishHandler:^{
                
                }];
}
@end
