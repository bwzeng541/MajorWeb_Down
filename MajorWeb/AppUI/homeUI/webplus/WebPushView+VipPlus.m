
#import "WebPushView+VipPlus.h"
#import "VipPayPlus.h"
@implementation  WebPushView(VipPlus)
-(BOOL)isVaild{
    return [[VipPayPlus getInstance] isVaildOperation:false plugKey:NSStringFromClass([self class])];
}

@end
