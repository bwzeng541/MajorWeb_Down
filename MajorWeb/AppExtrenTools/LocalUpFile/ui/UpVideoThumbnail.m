//
//  VideoThumbnail.m
//  WatchApp
//
//  Created by zengbiwang on 2017/9/26.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "UpVideoThumbnail.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+CWAdditions.h"
#import "SGWiFiUploadManager.h"
 @interface UpVideoThumbnail(){
    AVURLAsset *asset;
    AVAssetImageGenerator *generator;
    UIButton *share;
}
@property(copy)NSString *url;
@property(retain)UIImageView *imageView;
@end
@implementation UpVideoThumbnail

-(void)setThumbani:(UIImage*)resultImage{
     CGSize   size = self.bounds.size;
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        
        float w = 192,h = 188;
        if (IF_IPHONE) {
            w = w/2;h=h/2;
        }
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake((size.width-w)/2, (size.height-h)/2, w, h);
        imageView.image = [UIImage imageNamed:@"wifl_play"];
        [self addSubview:imageView];
        
        if ([[SGWiFiUploadManager sharedManager] isServerRunning] && [self.url rangeOfString:@"/upload_wifi/"].location!=NSNotFound) {
            share = [UIButton buttonWithType:UIButtonTypeCustom];
            float w = 136,h = 51;
            if (IF_IPHONE) {
                w/=2;h/=2;
            }
            share.frame = CGRectMake(size.width-w, (size.height-h)/2, w, h);
            [self addSubview:share];
            [share addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
            [self updateShareState];
#if DoNotKMPLayerCanShareVideo
            share.hidden = NO;
#else
#endif
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShareState) name:[NSString stringWithFormat:@"%@_localchange",[self getVideoName]] object:nil];
    }
    if  (resultImage.size.width>=size.width && resultImage.size.height>=size.height){
        self.imageView.image = [resultImage imageAtRect:CGRectMake((resultImage.size.width-size.width)/2, (resultImage.size.height-size.height)/2, size.width, size.height)];
    }
    else {
        float s1 = size.width/resultImage.size.width;
        float s2 = size.height/resultImage.size.height;
        float ss = s1>s2?s1:s2;
         resultImage = [resultImage scaleImage:ss];
        self.imageView.image = [resultImage imageAtRect:CGRectMake((resultImage.size.width-size.width)/2, (resultImage.size.height-size.height)/2, size.width, size.height)];
    }
}

-(void)updateShareState{
#if DoNotKMPLayerCanShareVideo
#else
   
#endif
}

-(NSString *)getVideoName{
    NSRange range = [self.url rangeOfString:@"/upload_wifi/"];
    NSString *name = [self.url substringFromIndex:range.location+6];
    SGWiFiUploadManager *bb =[SGWiFiUploadManager sharedManager];
    NSString *urlFile = [NSString stringWithFormat:@"http://%@:%d/%@",bb.ip,bb.port,name];
    return name;
}

-(void)share:(UIButton*)sender{
#if DoNotKMPLayerCanShareVideo
#else
    
#endif
}

-(void)showThumbanilUrl:(NSURL*)url{
 
    
    asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    //3.视频资源截图工具
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //4.获得某个时间的截图
    generator.appliesPreferredTrackTransform = YES;
    //4.1当前正在播放的秒 , 视频的帧率
    CMTime time = CMTimeMakeWithSeconds(5,600);
    //4.2将CMTime转换成NSValue
    NSValue *value = [NSValue valueWithCMTime:time];
    //4.3生成CMTime对应时间的截图
    __block CGSize   size = self.bounds.size;
    [generator generateCGImagesAsynchronouslyForTimes:@[value] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        //5.使用图片
        //5.1注意:要对这个image进行强引用,防止被释放
        CGImageRetain(image);
        //5.2回到主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            //5.3赋值图片
            
            UIImage *resultImage = [UIImage imageWithCGImage:image];
            if (!resultImage) {
                resultImage = [UIImage imageNamed:@"wifl_moren"];
                resultImage = [resultImage scaleImage:size.width/resultImage.size.width];
            }
            else{
                resultImage = [[UIImage imageWithCGImage:image] scaleImage:size.width/resultImage.size.width];
            }
            [self setThumbani:resultImage];
           
            //5.4释放图片
            CGImageRelease(image);
        });
    }];
    
}

-(void)showThumbanil:(NSString*)videoPath
{
    //2.视频资源
    if (asset) {
        return;
    }
    self.url = videoPath;
    [self showThumbanilUrl:[NSURL fileURLWithPath: videoPath]];
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [generator cancelAllCGImageGeneration];
    asset = nil;
    generator = nil;
}
@end
