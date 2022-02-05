#import "CusToast.h"

@implementation CusToast

RCT_EXPORT_MODULE(Toast);


RCT_EXPORT_METHOD(info:(NSString *)text){
    if(text!=nil&&text!=@""){
        dispatch_async(dispatch_get_main_queue(), ^{
        [WHToast showMessage:text duration:2 finishHandler:^{
                      
                      }];
        });
    }
 
}
@end
