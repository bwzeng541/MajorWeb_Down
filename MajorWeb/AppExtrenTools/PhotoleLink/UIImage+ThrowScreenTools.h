//
//  BeatfiyImageTools.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2018/11/15.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
//使用了SDWebImage里面的图像绘制，减少内存速度加快，ImageIO绘图,返回解码以后的数据
@interface UIImage  (ThrowScreenTools)
- (UIImage*)beatfiy_crop:(CGRect)rect;
- (UIImage*)deepCopy;
- (UIImage *)scaleImage:(float)scaleSize;//高清
- (BOOL)saveImageToPath:(NSString*)path;


+ (UIImage*)imageScale:(UIImage*)image scale:(float)scale quality:(CGInterpolationQuality)quality;
+ (UIImage*)drawImageAddRect:(CGSize)size   rect:(CGRect)rect image:(UIImage*)addImage  maskImage:(UIImage*)maskImage;
+ (UIImage *)captureView:(CALayer *)layer size:(CGSize)size frame:(CGRect)fra ;
+ (UIImage*)decode:(UIImage*)image;
//- (UIImage*)maskedImageWithPath:(UIImage*)maskImage;

@end
