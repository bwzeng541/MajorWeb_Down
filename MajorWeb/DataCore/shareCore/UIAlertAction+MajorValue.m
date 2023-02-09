
#import "UIAlertAction+MajorValue.h"

static const char *contentValueKey = "contentVauleKey";
@implementation UIAlertAction(MajorValue)

- (NSString* )contentValue {
    return objc_getAssociatedObject(self, contentValueKey);
}

-(void)setContentValue:(NSString *)contentValue
{
    objc_setAssociatedObject(self, contentValueKey, contentValue, OBJC_ASSOCIATION_COPY);
}
@end
