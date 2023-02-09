//
//  UIImage+Whawhawhat.h
//  whawhawhatLib
//
//  Created by Tianwei on 14/11/5.
//  Copyright (c) 2014年 whawhawhat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MajorWeb)

- (CGFloat)width;
- (CGFloat)height;
- (UIImage *)scaledToWidth:(float)i_width;
- (UIImage *)scaledToHeight:(float)i_height;
- (UIImage *)scaledToSize:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;

+(UIImage *)scaleNineImageWithImageName:(NSString *)imageName left:(CGFloat)l top:(CGFloat)t;
+(UIImage *)scaleNineImageWithImageName:(NSString *)imageName left:(CGFloat)l top:(CGFloat)t right:(CGFloat)r bottom:(CGFloat)b;

-(CGSize)sizeWithWidth:(CGFloat)w;
-(CGSize)sizeWithHeight:(CGFloat)h;

- (UIImage *)imageMaskedAndTintedWithColor:(UIColor *)color;
@end
