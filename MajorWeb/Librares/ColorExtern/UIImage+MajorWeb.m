
#import "UIImage+MajorWeb.h"

@implementation UIImage (MajorWeb)

-(CGFloat)width{
    return self.size.width;
}

-(CGFloat)height{
    return self.size.height;
}

-(UIImage *)scaledToWidth:(float)i_width{
    if (self.size.width <= i_width) {
        return self;
    }
    
    float oldWidth = self.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = self.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)scaledToHeight:(float)i_height{
    if (self.size.height <= i_height) {
        return self;
    }
    
    float oldHeight = self.size.height;
    float scaleFactor = i_height / oldHeight;
    
    float newWidth = self.size.width * scaleFactor;
    float newHeight = i_height;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)scaledToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGRect r = CGRectZero;
    r.size = size;
    [self drawInRect:r];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//scale 9 图片
+(UIImage *)scaleNineImageWithImageName:(NSString *)imageName left:(CGFloat)l top:(CGFloat)t{
    return [UIImage scaleNineImageWithImageName:imageName left:l top:t right:l bottom:t];
}

+(UIImage *)scaleNineImageWithImageName:(NSString *)imageName left:(CGFloat)l top:(CGFloat)t right:(CGFloat)r bottom:(CGFloat)b{
    UIImage *img = [UIImage imageNamed:imageName];
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(t, l, b, r);
        img = [img resizableImageWithCapInsets:edgeInsets];
    }else{
        img = [img stretchableImageWithLeftCapWidth:l topCapHeight:t];
    }
    
    return img;
}

-(CGSize)sizeWithWidth:(CGFloat)w{
    CGFloat h = self.height*w/self.width;
    return CGSizeMake(w, h);
}

-(CGSize)sizeWithHeight:(CGFloat)h{
    CGFloat w = self.width*h/self.height;
    return CGSizeMake(w, h);
}

- (UIImage *)imageMaskedAndTintedWithColor:(UIColor *)color
{
    NSParameterAssert(color);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bounds = (CGRect){CGPointZero, self.size};
    
    // do a vertical flip so that image is correct
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, bounds.size.height);
    CGContextConcatCTM(ctx, flipVertical);
    
    // create mask of image
    CGContextClipToMask(ctx, bounds, self.CGImage);
    
    // fill with given color
    [color setFill];
    CGContextFillRect(ctx, bounds);
    
    // get back new image
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

@end
