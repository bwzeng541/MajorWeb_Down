//
//  WebPushItem.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WebCartoonAsset [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0],@"WebCartoonAsset"]
NS_ASSUME_NONNULL_BEGIN
@protocol WebCartoonItemDelegate <NSObject>
-(void)updateWebCartoonSuccess:(id)object;
-(void)updateWebCartoonFaild:(id)object;
@end
@protocol WebCartoonImageDelegate <NSObject>
-(void)updateWebImageSuccess:(id)object ;
-(void)updateWebImageFromWeb:(id)object ;
-(void)updateWebImageSizeSuccess:(id)object ;
-(void)updateWebImageProgress:(id)object;
-(void)updateWebImageFaild:(id)object ;
@end
//解析网页图像的数据
@interface WebCartoonItem : NSObject<NSCopying>
@property(nonatomic,readonly)NSString *uuid;
@property(nonatomic,readonly)NSString *url;
@property(nonatomic,readonly)NSString *previousUrl;
@property(nonatomic,readonly)NSString *picUrl;
@property(nonatomic,readonly)NSString *nextUrl;
@property(nonatomic,readonly)NSString *referer;
@property(nonatomic,readonly)NSString *filePath;
@property(nonatomic,readonly)UIImage *image;
@property(nonatomic,assign)NSTimeInterval insertTime;
@property(nonatomic,assign)CGSize imageSize;
@property(nonatomic,assign)CGSize adSize;
@property(nonatomic,readonly)NSString *typeKey;
@property(nonatomic,strong)NSDictionary *parseInfo;
@property(nonatomic,weak)id<WebCartoonItemDelegate>delegate;
@property(nonatomic,weak)id<WebCartoonImageDelegate>imagedelegate;
-(id)initWithUrl:(NSString*)url referer:(NSString*)referer preUrl:(NSString*)preUrl nextUrl:(NSString*)nextUrl picUrl:(NSString*)picUrl typeKey:(NSString*)typeKey;
-(BOOL)tryToLoaclFile;
-(void)start;
-(void)stop;
-(void)reqeustAsset;
-(void)saveToDevice;
-(void)fixWillSave;
-(UIImage*)getSaveImage;
@end

NS_ASSUME_NONNULL_END
