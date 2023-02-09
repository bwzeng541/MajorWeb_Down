//
//  WebPushItem.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "WebCartoonItem.h"
#import "MKNetworkKit.h"
#import "UIImage+webCartoonTools.h"
#import "AppDelegate.h"
#import "MajorCartoonAssetManager.h"
#import "Toast+UIView.h"
#import "ShareSdkManager.h"
#import "FTWCache.h"
@interface WebCartoonItem()
@property(nonatomic,assign)NSInteger retryTime;
@property(nonatomic,strong)MKNetworkEngine *netWorkKit;
@property(nonatomic,strong)MKNetworkOperation *operation;
@property(nonatomic,copy)NSString *response;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *uuid;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,copy)NSString *referer;
@property(nonatomic,copy)NSString *picUrl;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,strong)NSMutableArray *arrayPos;
@property(nonatomic,copy)NSString *previousUrl;
@property(nonatomic,copy)NSString *nextUrl;
@property(nonatomic,copy)NSString *typeKey;
@end
@implementation WebCartoonItem

- (id)copyWithZone:(NSZone *)zone
{
    WebCartoonItem *item = [[self class]allocWithZone:zone];
    item.url = self.url;
    item.nextUrl = self.nextUrl;
    item.previousUrl = self.previousUrl;
    item.typeKey = self.typeKey;
    item.picUrl = self.picUrl;
    item.insertTime = self.insertTime;
    return item;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSString *nextUrl = self.nextUrl?self.nextUrl:@"";
    NSString *previousUrl = self.previousUrl?self.previousUrl:@"";
    NSString *picUrl = self.picUrl?self.picUrl:@"";
    NSString *key = self.typeKey?self.typeKey:@"";
    NSString *urlSave = self.url;
    [aCoder encodeObject:[FTWCache encryptWithKeyNomarl:nextUrl] forKey:@"nextUrl"];
    [aCoder encodeObject:[FTWCache encryptWithKeyNomarl:previousUrl] forKey:@"previousUrl"];
    [aCoder encodeObject:[FTWCache encryptWithKeyNomarl:picUrl] forKey:@"picUrl"];
    [aCoder encodeObject:[FTWCache encryptWithKeyNomarl:key] forKey:@"key"];
    [aCoder encodeObject:[FTWCache encryptWithKeyNomarl:urlSave] forKey:@"url"];
    [aCoder encodeDouble:self.insertTime  forKey:@"insertTime"];
 }

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.nextUrl = [FTWCache decryptWithKey:[aDecoder decodeObjectForKey:@"nextUrl"]];
        self.picUrl = [FTWCache decryptWithKey:[aDecoder decodeObjectForKey:@"picUrl"]];
        self.url = [FTWCache decryptWithKey:[aDecoder decodeObjectForKey:@"url"]];
        self.previousUrl = [FTWCache decryptWithKey:[aDecoder decodeObjectForKey:@"previousUrl"]];
        self.typeKey = [FTWCache decryptWithKey:[aDecoder decodeObjectForKey:@"key"]];
        self.insertTime = [aDecoder decodeDoubleForKey:@"insertTime"];
    }
    return self;
}

-(void)fixWillSave{
    WebCartoonItem *item = self;
    self.nextUrl = item.nextUrl?item.nextUrl:@"";
    self.previousUrl = item.previousUrl?item.previousUrl:@"";
    self.picUrl = item.picUrl?item.picUrl:@"";
    self.typeKey = item.typeKey?item.typeKey:@"";
    self.url = item.url;
    self.insertTime = [NSDate date].timeIntervalSince1970;
}

-(id)initWithUrl:(NSString*)url referer:(NSString*)referer preUrl:(NSString*)preUrl nextUrl:(NSString*)nextUrl picUrl:(NSString*)picUrl typeKey:(NSString*)typeKey{
    self  = [super init];
    self.url = url;
    self.picUrl=picUrl;
    self.uuid = [self.url md5];
    self.typeKey = typeKey;
    self.filePath =  [NSString stringWithFormat:@"%@/%@_dir/%@",WebCartoonAsset,typeKey,self.uuid];
    self.referer = referer;
    self.previousUrl = preUrl;
    self.nextUrl = nextUrl;
    self.imageSize = CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_WIDTH*0.3125);
    return self;
}

-(void)dealloc{
    [self stop];
}

-(BOOL)tryToLoaclFile{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
    {
        return true;
    }
    return false;
}
//解析html
-(void)start{
    if (self.picUrl && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
    {
        self.image = [UIImage decode:[UIImage imageWithContentsOfFile:self.filePath]];
        [self postImageSuccss];
        if ([self.delegate respondsToSelector:@selector(updateWebCartoonSuccess:)]) {
            [self.delegate updateWebCartoonSuccess:self];
        }
    }
    else if (!self.netWorkKit) {
        self.netWorkKit = [[MKNetworkEngine alloc] init];
        self.operation =[self.netWorkKit operationWithURLString:self.url timeOut:5];
        [self.operation onCompletion:^(MKNetworkOperation *completedOperation) {
            [self parse:completedOperation];
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
            [self stop];
            [self performSelector:@selector(start) withObject:nil afterDelay:2];
        }];
        [self.operation addHeaders:@{@"User-Agent":IosIphoneOldUserAgent}];
        [self.netWorkKit enqueueOperation:self.operation];
    }
}

-(void)parse:(MKNetworkOperation*)completedOperation{
    NSString *str = completedOperation.responseString;
    self.response = str;
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSArray *array = [str componentsSeparatedByString:@"\r\n"];
    self.arrayPos = [NSMutableArray arrayWithArray:array];
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [weakSelf parseCanoot];
    });
}

-(NSString*)getPicUrlFromStr:(NSString*)str srcKey:(NSString*)strKey{
    NSString *strRet = nil;
    NSString *findKey = [NSString stringWithFormat:@"src=%@http",strKey];
    if ((([str rangeOfString:@"img alt="].location != NSNotFound || [str rangeOfString:@"img src="].location != NSNotFound)&&
                         ([str rangeOfString:findKey].location != NSNotFound))) {//图片地址
        NSRange range =  [str rangeOfString:findKey];
        str = [str substringFromIndex:range.location+5];
        NSRange range1 =  [str rangeOfString:strKey];
        if (range1.location!=NSNotFound) {
            strRet = [str substringToIndex:range1.location];
        }
    }
    return strRet;
}

-(void)parseHtmlStr{
    NSScanner * scanner = [NSScanner scannerWithString:self.response];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {/* imgshow /li  */
        NSString *findKeyStart = [self.parseInfo objectForKey:@"picUrlStart"];
        NSString *findKeyEnd = [self.parseInfo objectForKey:@"picUrlEnd"];
        if (findKeyStart&&findKeyEnd) {
            [scanner scanUpToString:findKeyStart intoString:nil];
            [scanner scanUpToString:findKeyEnd intoString:&text];
            text = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            NSArray *array = [text componentsSeparatedByString:@"\r\n"];
            if ([array count]<7) {
                for (int i = 0; i < array.count; i++) {
                    NSString *str = [array objectAtIndex:i];
                    if (!self.picUrl) {
                        self.picUrl = [self getPicUrlFromStr:str srcKey:@"\'"];
                    }
                    if (!self.picUrl) {
                        self.picUrl = [self getPicUrlFromStr:str srcKey:@"\""];
                    }
                    if (self.picUrl) {
                        break;
                    }
                }
            }
            else{
                self.picUrl = @"";
            }
        }
        else{
            self.picUrl = @"";
        }
        break;
    }
    NSString *findKeyPre = [self.parseInfo objectForKey:@"preUrlStart"];
    NSString *findKeyNext = [self.parseInfo objectForKey:@"nextUrlStart"];

    for (int i = 0; i < self.arrayPos.count; i++) {
        NSString *str =  [self.arrayPos objectAtIndex:i];//上一篇
        if (findKeyPre && !self.previousUrl && [str rangeOfString:findKeyPre].location != NSNotFound &&
            [str rangeOfString:@"href"].location != NSNotFound){//前一个网页
            NSRange range =  [str rangeOfString:findKeyPre];
            str = [str substringFromIndex:range.location+range.length] ;
            self.previousUrl = [self subUrlhref:str];
        }//下一篇
        str = [self.arrayPos objectAtIndex:i];
       if (findKeyNext && !self.nextUrl && [str rangeOfString:findKeyNext].location != NSNotFound &&
                 [str rangeOfString:@"href"].location != NSNotFound){//前一个网页
            //NSLog(@"str = %@",str);
           NSRange range =  [str rangeOfString:findKeyNext];
           str = [str substringFromIndex:range.location+range.length] ;
            self.nextUrl = [self  subUrlhref:str];
        }
        if (self.nextUrl && self.picUrl && self.previousUrl) {
            break;
        }
    }
}

-(void)parseCanoot{
    [self parseHtmlStr];
    if ([self.picUrl length]<7) {
        NSLog(@"error picurl = %@",self.url);
    }
    if (!self.nextUrl || !self.picUrl) {
        NSLog(@"error picurl = %@",self.url);
    }
    NSURL *url = [NSURL URLWithString:self.url];
    if (self.nextUrl&&[self.nextUrl rangeOfString:@"http"].location==NSNotFound) {
        self.nextUrl = [NSString stringWithFormat:@"%@://%@%@",url.scheme,url.host,self.nextUrl];
    }
    if (self.previousUrl&&[self.previousUrl rangeOfString:@"http"].location==NSNotFound) {
        self.previousUrl = [NSString stringWithFormat:@"%@://%@%@",url.scheme,url.host,self.previousUrl];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(updateWebCartoonSuccess:)]) {
            [self.delegate updateWebCartoonSuccess:self];
        }
    });
}

-(NSString*)subUrlhref:(NSString*)url{
    NSString *urlRet = @"";
    NSRange range =  [url rangeOfString:@"href="];
    if (range.location!=NSNotFound) {
        url = [url substringFromIndex:range.location+range.length];
        range = [url rangeOfString:@".html"];
        if (range.location!=NSNotFound) {
            urlRet = [url substringToIndex:range.location+range.length];
            urlRet = [urlRet stringByReplacingOccurrencesOfString:@"\'" withString:@""];
            urlRet = [urlRet stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
    }
    return urlRet;
}

-(void)postImageFaild{
    self.image = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    if ([self.imagedelegate respondsToSelector:@selector(updateWebImageFaild:)]) {
        [self.imagedelegate updateWebImageFaild:self];
    }
    if ([self.delegate respondsToSelector:@selector(updateWebCartoonSuccess:)]) {
        [self.delegate updateWebCartoonFaild:self];
    }
}

-(void)postImageSuccss{
    if ([self.imagedelegate respondsToSelector:@selector(updateWebImageFromWeb:)]) {
        [self.imagedelegate updateWebImageFromWeb:self];
    }
}

-(UIImage*)getSaveImage{
    if ([[NSFileManager defaultManager]fileExistsAtPath:self.filePath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.filePath];
        UIImage *maskImage = UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/majorcartoon_banner_gg");
        //640*50
        float maskW = image.width;
        float maskH = maskW*(50/640.0);
        CGRect maskRect = CGRectMake(0, image.height, maskW, maskH);
        image = [UIImage drawImageAddRect:CGSizeMake(maskW,image.height+maskH) rect:CGRectMake(0, 0, image.size.width, image.size.height) image:image maskRect:maskRect maskImage:maskImage];
        return image;
    }
    return nil;
}

-(void)saveToDevice{
    UIImage *image = [self getSaveImage];
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), nil);
    }
}

- (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
    [[[UIApplication sharedApplication] keyWindow] makeToast:!error?@"图片保存成功":@"图片保存失败" duration:2 position:@"center"];
}

//图片下载必须用单个队列处理，保证顺序
-(void)reqeustAsset
{
    if (self.picUrl && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        self.image = [UIImage decode:[UIImage imageWithContentsOfFile:self.filePath]];
        if ([self.delegate respondsToSelector:@selector(updateWebCartoonSuccess:)]) {
            [self.delegate updateWebCartoonSuccess:self];
        }
        [self postImageSuccss];
    }
    else{
        if (!self.netWorkKit) {
            self.netWorkKit = [[MKNetworkEngine alloc] init];
        }
        self.operation =[self.netWorkKit operationWithURLString:self.picUrl timeOut:15];
        [self.operation onCompletion:^(MKNetworkOperation *completedOperation) {
            NSInteger code = completedOperation.HTTPStatusCode;
            if ((code>=200 && code<=300)  &&[completedOperation.responseData length]>100) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                   UIImage *image =   [UIImage imageWithData:completedOperation.responseData];
                    if(image.size.width>MY_SCREEN_WIDTH)
                        image = [UIImage imageScale:image scale:MY_SCREEN_WIDTH/image.size.width quality:(kCGInterpolationHigh)];
                    if ([[UIImage decode:image] saveImageToPath:self.filePath]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self postImageSuccss];
                        });
                    }
                    else{
                        [self postImageFaild];
                    }
                });
            }
        } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
            NSLog(@"reqeustAsset = %@",[error description]);
            [self stop];
            [self postImageFaild];
            [self performSelector:@selector(reqeustAsset) withObject:nil afterDelay:2];
        }];
         [self.netWorkKit enqueueOperation:self.operation];
    }
}


-(void)reviceMajorAssetNofiti:(NSNotification*)object{
    if ([object.object objectForKey:@"errorKey"]){
        NSLog(@"reviceMajorAssetNofiti error");
        [self.imagedelegate updateWebImageFaild:self];
        if ([self.delegate respondsToSelector:@selector(updateWebCartoonSuccess:)]) {
            [self.delegate updateWebCartoonFaild:self];
        }
    }
    else if([object.object objectForKey:@"imageKey"]){
        /*
        self.image =  [object.object objectForKey:@"imageKey"];
        self.image = [UIImage decode:self.image];
        if (!CGSizeEqualToSize(self.image.size, self.imageSize)) {
            self.imageSize = self.image.size;
            [self.imagedelegate updateWebImageSizeSuccess:self];
        }
        [self.imagedelegate updateWebImageProgress:self];*/
        if ([[object.object objectForKey:@"finshState"] boolValue]) {
            [self.imagedelegate updateWebImageFromWeb:self];
        }
    }
}

//停止解析
-(void)stop{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
    [self.operation cancel];
    self.operation =nil;
    self.netWorkKit=nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqeustAsset) object:nil];
}
@end
