
#import "TYAlertAction+TagValue.h"

static const char *tagValueKey = "tagVauleKey";
@implementation TYAlertAction(TagValue)

- (NSInteger )tagValue {
    return [objc_getAssociatedObject(self, tagValueKey) integerValue];
}

-(void)setTagValue:(NSInteger)tagValue
{
    objc_setAssociatedObject(self, tagValueKey, [NSNumber numberWithInteger:tagValue], OBJC_ASSOCIATION_ASSIGN);
}
@end
