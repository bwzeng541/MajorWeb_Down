//
//  BeatfiyImageTools.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2018/11/15.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "UIImage+ThrowScreenTools.h"
#import <CoreServices/CoreServices.h>
#import "SDWebImageCoder.h"
#import "SDWebImageCodersManager.h"
#import "SDWebImageImageIOCoder.h"
#import "UIImage+ForceDecode.h"
#import "SDWebImageCoderHelper.h"
#import "SDWebImageCoder.h"
@implementation  UIImage (BeatfiyImageTools)

- (UIImage *)scaleImage:(float)scaleSize
{
    UIImage *scaledImage = nil;
   
    @autoreleasepool {
        SDImageFormat format;
        if (SDCGImageRefContainsAlpha(self.CGImage)) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
        NSData *data = nil;
        UIImage *decompressImage = [[SDWebImageCodersManager sharedInstance]decompressedImageWithImage:self data:&data options:@{SDWebImageCoderScaleDownLargeImagesKey: @(YES)}];
        scaledImage = [UIImage imageScale:decompressImage scale:scaleSize quality:kCGInterpolationHigh];
        data = nil;
    }

     return scaledImage;
}

+(UIImage*)imageScale:(UIImage*)image scale:(float)scale quality:(CGInterpolationQuality)quality{
    if (fabsf(scale-1)<FLT_EPSILON) {
        return image;
    }
    CGContextRef destContext;
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    // on iOS7, do not forget to call [[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool {
        CGImageRef sourceImageRef = image.CGImage;
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef);
        sourceResolution.height = CGImageGetHeight(sourceImageRef);
        float imageScale = scale;
        CGSize destResolution = CGSizeZero;
        destResolution.width = (int)(sourceResolution.width*imageScale);
        destResolution.height = (int)(sourceResolution.height*imageScale);
        CGColorSpaceRef colorspaceRef = SDCGColorSpaceGetDeviceRGB();
        destContext = CGBitmapContextCreate(NULL,
                                            destResolution.width,
                                            destResolution.height,
                                            8,//kBitsPerComponent
                                            0,
                                            colorspaceRef,
                                            kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        if (destContext == NULL) {
            return image;
        }
        CGContextSetInterpolationQuality(destContext,quality );
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        // The source tile height is dynamic. Since we specified the size
        // of the source tile in MB, see how many rows of pixels high it
        // can be given the input image width.
        sourceTile.size.height = (int)(scale * sourceTile.size.width );
        sourceTile.origin.x = 0.0f;
        // The output tile is the same proportions as the input tile, but
        // scaled to image scale.
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        // The source seem overlap is proportionate to the destination seem overlap.
        // this is the amount of pixels to overlap each tile as we assemble the ouput image.
        float sourceSeemOverlap = (int)((2.0/*kDestSeemOverlap*//destResolution.height)*sourceResolution.height);
        CGImageRef sourceTileImageRef;
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // If tile height doesn't divide the image height evenly, add another iteration
        // to account for the remaining pixels.
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if(remainder) {
            iterations++;
        }
        // Add seem overlaps to the tiles, but save the original tile height for y coordinate calculations.
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += 2.0/*kDestSeemOverlap*/;
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = destResolution.height - (( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + 2.0/*kDestSeemOverlap*/);
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImageRef, sourceTile );
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
            }
        }
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }
        UIImage *destImage = [[UIImage alloc] initWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
}

- (UIImage*)beatfiy_crop:(CGRect)rect
{
    UIImage *img = [self cropImage:self toRect:rect];
    return img;
}

- (UIImage *)cropImage:(UIImage*)image toRect:(CGRect)rect {
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    // use the rect to crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    // create a new UIImage and set the scale and orientation appropriately
    UIImage *result = [UIImage decodedImageWithImage:[UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation]];
    // memory cleanup
    CGImageRelease(imageRef);
    
    return result;
}


- (BOOL)saveImageToPath:(NSString*)path
{
         SDImageFormat format;
        if (SDCGImageRefContainsAlpha(self.CGImage)) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
        NSData *data;
        BOOL ret = [self encodedDataWithImageAndSave:self data:&data path:path format:SDImageFormatJPEG quality:0.9];

        data = nil;
        return ret;
     return false;
}


+ (UIImage*)drawImageAddRect:(CGSize)size  rect:(CGRect)rect image:(UIImage*)addImage maskImage:(UIImage*)maskImage{
    UIImage *img = nil;
        CGSize destResolution = size;
        CGColorSpaceRef colorspaceRef = SDCGColorSpaceGetDeviceRGB();
        CGContextRef destContext = CGBitmapContextCreate(NULL,
                                        destResolution.width,
                                        destResolution.height,
                                        8,
                                        0,
                                        colorspaceRef,
                                         kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
            if (destContext == NULL) {
                return img;
            }
            CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
            CGContextDrawImage( destContext, rect, addImage.CGImage );
            if (maskImage) {
                CGContextDrawImage( destContext, CGRectMake(0, 0, size.width, size.height), maskImage.CGImage );
            }
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
            CGContextRelease(destContext);
            if (destImageRef) {
                img = [UIImage imageWithCGImage:destImageRef];
                img = [UIImage decodedImageWithImage:img];
                CGImageRelease(destImageRef);
            }
    return img;
}

- (UIImage*)deepCopy
{
    return [UIImage decode:self];
}

+ (UIImage*)decode:(UIImage*)image
{
    if(image==nil){  return nil; }
    UIImage *retImage = nil;
    @autoreleasepool {
        SDImageFormat format;
        if (SDCGImageRefContainsAlpha(image.CGImage)) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
        
        NSData *data;
        retImage = [[SDWebImageCodersManager sharedInstance]decompressedImageWithImage:image data:&data options:@{SDWebImageCoderScaleDownLargeImagesKey: @(NO)}];
        data = nil;
    }
    return retImage;
}

+ (UIImage *)captureView:(CALayer *)layer size:(CGSize)size  frame:(CGRect)fra {
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [layer renderInContext:context];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, fra);
    
    UIImage *i = [UIImage imageWithCGImage:ref];
    i = [UIImage decodedImageWithImage:i];
    CGImageRelease(ref);
    
    return i;
    
}

- (BOOL)encodedDataWithImageAndSave:(UIImage *)image data:(NSData *__autoreleasing  _Nullable *)data path:(NSString*)filePath format:(SDImageFormat)format quality:(float)quality{//(0-1)
    if (!image) {
        return false;
    }
    
    if (format == SDImageFormatUndefined) {
        BOOL hasAlpha = SDCGImageRefContainsAlpha(image.CGImage);
        if (hasAlpha) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:format];
    
    // Create an image destination.
    CGImageDestinationRef imageDestination = nil;
    if(!filePath)
    {
       imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    }
    else{
       imageDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath],
                                        imageUTType,
                                        1,
                                        NULL);
    }
    if (!imageDestination) {
        // Handle failure.
        return false;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
#if SD_UIKIT || SD_WATCH
    NSInteger exifOrientation = [SDWebImageCoderHelper exifOrientationFromImageOrientation:image.imageOrientation];
    [properties setValue:@(exifOrientation) forKey:(__bridge_transfer NSString *)kCGImagePropertyOrientation];
    [properties setValue:@(quality) forKey:(__bridge_transfer NSString *)kCGImageDestinationLossyCompressionQuality];

#endif
    
    // Add your image to the destination.
    CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)properties);
    
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
        CFRelease(imageDestination);
        return false;
    }
    CFRelease(imageDestination);
    *data = imageData;
    return true;
}
@end
