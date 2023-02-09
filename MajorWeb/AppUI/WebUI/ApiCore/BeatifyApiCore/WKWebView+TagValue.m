#import "WKWebView+TagValue.h"
static const char *tagValueKey = "tagVauleKey";
@implementation WKWebView(TagValue)

- (id )tagValue {
    return objc_getAssociatedObject(self, tagValueKey) ;
}

-(void)setTagValue:(id)tagValue
{
    objc_setAssociatedObject(self, tagValueKey, tagValue, OBJC_ASSOCIATION_ASSIGN);
}
@end
