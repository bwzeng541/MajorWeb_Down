
#import <UIKit/UIKit.h>

@interface UIColor (MajorWeb)
+ (UIColor *)colorWithHexString:(NSString *)hexString;

-(UIImage *)image;
+(UIColor *)randomColor;

- (UIColor *)darkerColor;
- (UIColor *)lighterColor;
@end
