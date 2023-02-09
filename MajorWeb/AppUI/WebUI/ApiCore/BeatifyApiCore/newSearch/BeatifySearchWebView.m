//
//  BeatifySearchWebView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/31.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifySearchWebView.h"
#import "BeatifyWebAdManager.h"
typedef enum setWordOptionType{
    Set_Word_Loading,//加载网页
    Set_Word_StartClick,//检查网页是否有对应的项，然后点击click事件
    Set_Word_StartClickFinish,//检查网页是否有对应的项，然后点击click事件
    Set_Word_Result//检查超时结果
}_SetWordOptionType;

@interface BeatifySearchWebView ()<BeatifyWebViewExternDelegate,BeatifyWebViewDelegate>
@property(assign,nonatomic)BOOL isPostType;
@property(copy,nonatomic)NSString *word;
@property(strong,nonatomic)NSTimer *delayTimer;
@property(assign,nonatomic)_SetWordOptionType actionType;
@end
@implementation BeatifySearchWebView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame ];
    
    return self;
}

-(void)removeFromSuperview{
    [self.delayTimer invalidate];
       self.delayTimer = nil;
    [super removeFromSuperview];
}

-(void)loadUrlFromParam:(NSDictionary*)info{
   NSString *url =   [info objectForKey:@"url"];
   self.isPostType = !([[info objectForKey:@"type"] compare:@"get"] == NSOrderedSame);
   self.word = [info objectForKey:@"word"];
   self.actionType = Set_Word_Loading;
    if (!self.isPostType && self.word) {
        url = [url stringByAppendingString:self.word];
    }
    [self loadURL:[NSURL URLWithString:url]];
}

-(void)loadURL:(NSURL *)URL{
    self.externDelegate = self;
    self.delegate = self;
    [super loadURL:URL];
}


-(void)delayClick
{
    [self.delayTimer invalidate];
    self.delayTimer = nil;
    NSString *js = [NSString stringWithFormat:@"startClick()"];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        NSLog(@"delayClick error = %@",[error description]);
    }];
}

- (void)webViewLoadingPogress:(float)progress uuid:(nonnull NSString *)uuid{
    if(progress>0.5 && self.isPostType && self.word){
        if (self.actionType == Set_Word_Loading) {
            NSString *js =  [NSString stringWithFormat:@"startCheckInput('%@')",self.word];
            [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
                NSLog(@"errrpr = %@",[error description]);
            }];
        }
        else if (self.actionType==Set_Word_StartClick){
          //  [self.delayTimer invalidate];
            self.actionType = Set_Word_StartClickFinish;
          //  self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(delayClick) userInfo:nil repeats:YES];
        }
    }
    NSArray *array = [[BeatifyWebAdManager getInstance] getAdDomCss:[self.webView.URL absoluteString]];
    if (array.count>0) {
        NSString *msg = [NSString stringWithFormat:@"[%@]",[array componentsJoinedByString:@","]];
        NSString *js = [NSString stringWithFormat:@"window.__beatify__.setElementHidingArray(%@,true,60,0,60,[],[],'')",msg];
        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            NSLog(@"removeDomCssNativeArray = %@",error);
        }];
    }
}

-(void)webViewSetClickSuccessCallBack:(BOOL)isSuccess uuid:(nonnull NSString *)uuid{
    if (self.actionType != Set_Word_Result) {//referrer videoUrl;
        self.actionType = Set_Word_Result;
    }
}

-(void)webViewSetWordSuucessCallBack:(BOOL)isSuccess uuid:(NSString*)uuid{
    if (self.isPostType && self.actionType != Set_Word_StartClick) {
             self.actionType = Set_Word_StartClick;
        [self.delayTimer invalidate];
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(delayClick) userInfo:nil repeats:YES];
        }
}

- (void)webViewDidFinishLoad:(BeatifyWebView *)webView{
    [webView evaluateJavaScript:@"fixImageAsset()" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
}


@end
