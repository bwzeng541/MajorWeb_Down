//
//  WebPushItem.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "WebPushItem.h"
#import "MKNetworkKit.h"
@interface WebPushItem()
@property(nonatomic,strong)MKNetworkEngine *netWorkKit;
@property(nonatomic,strong)MKNetworkOperation *operation;
@property(copy)NSString *url;
@property(copy)NSString *iconUrl;
@property(copy)NSString *title;
@property(copy)NSString *referer;
@property(copy)NSString *playUrl;
@property(copy)NSString *uuid;
@property(strong)NSTimer *delayTimer;
@end
@implementation WebPushItem
-(id)initWithUrl:(NSString*)url iconUrl:(NSString*)iconUrl referer:(NSString*)referer title:(NSString*)title{
    self  = [super init];
    self.url = url;
    self.uuid = [url md5];
    self.title = title;
    self.iconUrl = iconUrl;
    self.referer = referer;
    self.playUrl = nil;
   // [self start];
    return self;
}

-(void)dealloc{
    [self stop];
}

-(void)delayStart:(float)time{
    [self.delayTimer invalidate];
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(start) userInfo:nil repeats:YES];
}
//解析html
-(void)start{
    [self.delayTimer invalidate];self.delayTimer = nil;
    if (!self.netWorkKit) {
        self.netWorkKit = [[MKNetworkEngine alloc] init];
        self.operation =[self.netWorkKit operationWithURLString:self.url timeOut:3];
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

-(NSString*)findPic:(NSString*)str{
    NSRange range = [str rangeOfString:@"picURL"];
    if (range.location!=NSNotFound) {
        NSString* strNew = [str substringFromIndex:range.length+range.location];
        NSRange range1 = [strNew rangeOfString:@"'"];
        NSString *strSecond = [strNew substringFromIndex:range1.length+range1.location];
        NSRange range2 = [strSecond rangeOfString:@"'"];
        if (range1.location!=NSNotFound && range2.location!=NSNotFound && range2.location>range1.location) {
            NSString *picUrl =  [strSecond substringToIndex:range2.length+range2.location];
            NSURL *url = [NSURL URLWithString:picUrl];
            if (url) {
                NSLog(@"picUrl = %@",[url absoluteString]);
                return picUrl;
            }
        }
    }
    return nil;
}

//0
-(BOOL)parseNext:(NSString*)msgContent{
    NSString *str = msgContent;
    NSRange range = [str rangeOfString:@"hasvedio"];
    NSRange range_my = [str rangeOfString:@"hasBeatifyVideo"];
    //    NSRange range = [str rangeOfString:@"hasvideo"];
    NSString *findStr = @".m3u8";
    if (range_my.location!=NSNotFound) {
        findStr = @".mp4";
        range =range_my ;
    }
    BOOL isPareOk = true;
    if (range.location!=NSNotFound) {
        NSString* strNew = [str substringFromIndex:range.length+range.location];
        NSRange range1 = [strNew rangeOfString:@"'"];
        NSRange range2 = [strNew rangeOfString:findStr];
        {//多了个key，在rang2后查找?字符
        if (range2.location!=NSNotFound) {
                     NSString *v =  [strNew substringWithRange:NSMakeRange(range2.location+range2.length, 1)];
            if (v&&[v compare:@"?"]==NSOrderedSame) {
                 NSString *tmpStr =   [strNew substringFromIndex:range2.location+range2.length];
                 NSRange ranle =   [tmpStr rangeOfString:@"'"];
                if (ranle.location!=NSNotFound) {
                    range2 = NSMakeRange(range2.location, range2.length+ranle.location);
                }
             }
            }
        }
        if (range1.location!=NSNotFound && range2.location!=NSNotFound) {
            strNew =  [strNew substringWithRange:NSMakeRange(range1.location+1, range2.length+range2.location-range1.location-1)];
            NSString *scheme = [[NSURL URLWithString:strNew] scheme];
            if (!scheme) {
                strNew = [@"http:" stringByAppendingString:strNew];
            }
            self.playUrl = strNew;
            NSString *strIcon = [self findPic:str];
            if (strIcon) {
                self.iconUrl = strIcon;
            }
        }
        else{
            isPareOk = false;
        }
    }
    else{
        isPareOk = false;
    }
    return isPareOk;
}

-(void)parse:(MKNetworkOperation*)completedOperation{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        bool isPareOk = [self parseNext:completedOperation.responseString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isPareOk) {
                if ([self.delegate respondsToSelector:@selector(updateWebPushSuccess:)]) {
                    [self.delegate updateWebPushSuccess:self];
                    [self stop];
                }
            }
            else{
                [self stop];
                [self performSelector:@selector(start) withObject:nil afterDelay:2];
            }
        });
    });
}

//停止解析
-(void)stop{
    self.delegate = nil;
    [self.delayTimer invalidate];self.delayTimer = nil;
    [self.operation cancel];
    self.operation =nil;
    self.netWorkKit=nil;
}
@end
