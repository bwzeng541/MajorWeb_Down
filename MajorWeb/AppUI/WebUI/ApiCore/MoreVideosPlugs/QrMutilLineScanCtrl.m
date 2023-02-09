//
//  QrMutilLineScanCtrl.m
//  QRTools
//
//  Created by bxing zeng on 2020/5/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QrMutilLineScanCtrl.h"
#import "QrVideoNodeView.h"
#import "QRWKWebview.h"
#define DefaultQrVideosNumber 6
@interface QrMutilLineScanCtrl ()<QrVideoNodeViewDelegate,QRWKWebviewDelegate>
@property(weak)IBOutlet UIButton *btnClose;
@property(weak)IBOutlet UIButton *btnClear;
@property(weak)IBOutlet UIView *cententView;
@property(weak)IBOutlet UIView *backView;
@property(weak)IBOutlet UILabel *desLabel;
@property(strong)UIScrollView *qrViewParent;
@property(strong)NSMutableArray *qrVideoArray;
@property(strong)NSArray *defualtArray;
@property(assign)BOOL isDefautAsset;
@property(copy)NSString *mediaTitle;
@property(copy)NSString *defaultUrl;
@property(weak)WKWebView *webView;
@property(strong)QRWKWebview *changeNode;
@property(strong)NSTimer *delayTimer;
@property(strong)NSString *assetNew;
@property(assign)float progress;
@property(assign)BOOL isevaluateJs;
@property(assign)BOOL isChangeLoad;
@property(strong)NSMutableDictionary *assetKeyInfo;
@property(assign)NSInteger totlaNumber;
@end

@implementation QrMutilLineScanCtrl

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil array:(NSArray*)array webView:(WKWebView*)webView title:(NSString*)mediaTitle{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.defualtArray = array;
    self.webView = webView;
    self.mediaTitle = mediaTitle;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.qrVideoArray = [NSMutableArray arrayWithCapacity:1];
    self.assetKeyInfo = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view from its nib.
}

-(void)unLoadChangeNode{
    [self.delayTimer invalidate];self.delayTimer = nil;
     self.changeNode.qrWkdelegate = nil;
    [self.changeNode removeFromSuperview];
    self.changeNode = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.qrViewParent) {
        self.qrViewParent = [[UIScrollView alloc] initWithFrame:self.cententView.bounds];
        self.qrViewParent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.cententView addSubview:self.qrViewParent];
        self.qrViewParent.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentNever;
        [self addDefaultQrNodes];
    }
}

-(NSArray*)combinationNewArray:(NSArray*)urlArray asset:(NSString*)newUrl{
    if([[urlArray objectAtIndex:0] rangeOfString:newUrl].location!=NSNotFound){
        return urlArray;
    }
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i < [urlArray count]; i++) {
        NSString *asset =  [urlArray objectAtIndex:i];
        if (self.isDefautAsset && i ==0) {
            [arrayRet addObject:asset];
            continue;
        }
        NSRange range =  [asset rangeOfString:@"="];
        if (range.location!=NSNotFound) {
           NSString *vv = [[asset substringToIndex:range.location+range.length] stringByAppendingString:newUrl];
            [arrayRet addObject:vv];
        }
        else{
            [arrayRet addObject:asset];
        }
    }
    return [NSArray arrayWithArray:arrayRet];
}

-(void)initRealArray:(NSArray*)array asset:(NSString*)newUrl{
    self.btnClear.hidden = NO;
    #ifdef DEBUG
    NSLog(@"newUrl = %@ self.default = %@",newUrl,self.defaultUrl);
    #endif
    [self unLoadChangeNode];
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width*0.56);
    float y = 0;
    NSArray *arrayNew = [self combinationNewArray:array asset:newUrl];
    #ifdef DEBUG
for (int i= 0; i < self.defualtArray.count; i++) {
#else
    for (int i= 0; i < self.defualtArray.count; i++) {
#endif
    QrVideoNodeView *qrNodes = [[QrVideoNodeView alloc] initWithFrame:CGRectMake(0, y, size.width,  size.height)];
    qrNodes.delegate = self;
    [self.qrViewParent addSubview:qrNodes];
    [self.qrVideoArray addObject:qrNodes];
    y =qrNodes.frame.origin.y+qrNodes.frame.size.height;
        [qrNodes loadUrl:arrayNew[i] title:self.mediaTitle delay:0.2*i];
   }
   [self.qrViewParent setContentSize:CGSizeMake(0,(self.qrVideoArray.count+1)*size.height)];
}

-(void)startToChangeNode{
    self.isevaluateJs = false;
    self.isChangeLoad = false;
    self.btnClear.hidden = YES;
    self.changeNode = [[QRWKWebview alloc] initWithFrame:self.backView.bounds uuid:nil userAgent:PCUserAgent isExcutJs:true];
      [self.changeNode setWebViewType:webView_Short];
       self.changeNode.qrWkdelegate = self;
    [self.backView addSubview:self.changeNode];
    [self.changeNode loadUrl:self.defaultUrl];
#ifdef DEBUG
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(delayFaild:) userInfo:nil repeats:YES];
#else
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(delayFaild:) userInfo:nil repeats:YES];
#endif
    [self.backView sendSubviewToBack:self.changeNode];
}

-(void)delayFaild:(NSTimer*)timer{
    [self.delayTimer invalidate];self.delayTimer = nil;
    NSString *tmpNew = [self.changeNode.webView.URL absoluteString] ;
    if (tmpNew) {
         self.assetNew = tmpNew;
     }
    if (self.assetNew) {
        [self initRealArray:self.defualtArray asset:self.assetNew];
    }
    else{
        [self initRealArray:self.defualtArray asset:self.defaultUrl];
    }
}

-(void)addDefaultQrNodes{
    float y = 0;
    if (self.defualtArray.count>0) {
    __weak __typeof(self)weakSelf = self;
        self.defaultUrl = [self.webView.URL absoluteString];
        if (self.webView) {//checkUrlVaild
            NSString *old = [NSString stringWithFormat:@"%@%@%@%@%@",@"m",@".",@"iqi",@"yi.c",@"om"];
            NSString *newold = [NSString stringWithFormat:@"%@%@%@%@%@",@"www",@".",@"iqi",@"yi.c",@"om"];
            if ([self.defaultUrl rangeOfString:old].location!=NSNotFound) {
                self.defaultUrl = [self.defaultUrl stringByReplacingOccurrencesOfString:old withString:newold];
                [self initRealArray:self.defualtArray asset:self.defaultUrl];
                return;
            }
            [self.webView evaluateJavaScript:@"checkUrlVaild()" completionHandler:^(id ret , NSError * _Nullable error) {
             if ([ret isKindOfClass:[NSNull class]] || error) {
                 [weakSelf startToChangeNode];
             }
             else{
                 weakSelf.assetNew = ret;
                 [weakSelf initRealArray:self.defualtArray asset:weakSelf.assetNew];
             }
            }];
        }
        else{
            [self initRealArray:self.defualtArray asset:self.defaultUrl];
        }
    }
    else {
        CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width*0.56);
        for (int i= 0; i < DefaultQrVideosNumber; i++) {
            QrVideoNodeView *qrNodes = [[QrVideoNodeView alloc] initWithFrame:CGRectMake(0, y, size.width,  size.height)];
            qrNodes.delegate = self;
            [self.qrViewParent addSubview:qrNodes];
            [self.qrVideoArray addObject:qrNodes];
            y =qrNodes.frame.origin.y+qrNodes.frame.size.height;
        }
        [self.qrViewParent setContentSize:CGSizeMake(0,(self.qrVideoArray.count+1)*size.height)];
    }
}

-(IBAction)pressClose:(id)sender{
    [self unLoadChangeNode];
    [self.delayTimer invalidate];self.delayTimer = nil;
    [self.changeNode removeFromSuperview];
    self.changeNode = nil;
    [self.delegate qrMutitlLineRemove];
}

-(IBAction)pressClear:(id)sender{
    [self unLoadChangeNode];
    [self.delayTimer invalidate];self.delayTimer = nil;
    [self.changeNode removeFromSuperview];
    self.changeNode = nil;
    [self.qrVideoArray makeObjectsPerformSelector:@selector(clearNodeAsset)];
}


-(void)removeAllSubView{
     self.totlaNumber = 0;
    [self.assetKeyInfo removeAllObjects];
    [self.qrVideoArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.qrVideoArray removeAllObjects];
}

-(void)selectQrVideoNode{
     [self.delegate qrMutitlLineRemove];
}

-(void)addJustFaildObject:(id)object{
    #ifdef DEBUG
        return;
    #endif
     [self.qrVideoArray removeObject:object];
           [self.qrVideoArray makeObjectsPerformSelector:@selector(removeNotClear)];
           [(QrVideoNodeView*)object removeFromSuperview];
           object = nil;
           [self addJustScorllView];
           [self.qrViewParent setContentSize:CGSizeMake(0,(self.qrVideoArray.count+1)* self.view.bounds.size.width*0.56)];
}

-(void)recviceQrVideoStateFaild:(id)v object:(nonnull id)object{
  #ifdef DEBUG
         return;
     #endif
     [self.assetKeyInfo removeObjectForKey:v];
    [self addJustFaildObject:object];
}

-(BOOL)reviceAndCheckIsVaild:(id)v object:(nonnull id)object isFaild:(BOOL)isFaild{
     
    if (isFaild || [self.assetKeyInfo objectForKey:v] ) {
        [self addJustFaildObject:object];
        return false;
    }
#ifdef DEBUG          
#else
      if (self.assetKeyInfo.count>=4) {
              [self addJustFaildObject:object];
               while (self.qrVideoArray.count>4) {
                   [self addJustFaildObject:self.qrVideoArray.lastObject];
               }
               return false;
           }
#endif
 
    [self.assetKeyInfo setObject:@"0" forKey:v];
    self.desLabel.text = @"";
    return true;
}

-(BOOL)recviceCheckNumber:(id)v{
#ifdef DEBUG
    return self.totlaNumber>=30;
#else
    return self.totlaNumber>=3;
#endif
}

-(BOOL)recviceAndCheckIsMutilFront{
        return self.isMutilFront;
}
    
-(void)recviceQrVideoState:(id)v{
#ifdef DEBUG
    return;
#endif
     if (self.defualtArray.count>1) {
 
        NSInteger pos = [self.qrVideoArray indexOfObject:v];
        #ifdef DEBUG
        NSLog(@"recviceQrVideoState pos = %ld\n",pos);
        #endif
        if (pos!=0) {
            [self.qrVideoArray removeObject:v];
            #ifdef DEBUG
            printf("recviceQrVideoState self.totlaNumber = %ld url = %s\n",self.totlaNumber,[((QrVideoNodeView*)v).reqeutUrl UTF8String]);
                  #endif
            if (self.totlaNumber==0) {
                 [self.qrVideoArray insertObject:v atIndex:0];
            }
            else{
                [self.qrVideoArray insertObject:v atIndex:self.totlaNumber];
            }
            [self.qrVideoArray makeObjectsPerformSelector:@selector(removeNotClear)];
            [self addJustScorllView];
        }
        self.totlaNumber++;
    }
}

-(void)addJustScorllView{
     float y = 0;
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width*0.56);
    for (int i = 0; i < self.qrVideoArray.count; i++) {
                   QrVideoNodeView *qrNodes = [self.qrVideoArray objectAtIndex:i];
                   qrNodes.frame = CGRectMake(0, y, size.width,  size.height);
                   y =qrNodes.frame.origin.y+qrNodes.frame.size.height;
                   [self.qrViewParent addSubview:qrNodes];
    }
}

-(void)checkWKWebViewFinish{
    [self.changeNode.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        #ifdef DEBUG
          NSLog(@"userAgent :%@", result);
        #endif
      }];
      __weak __typeof(self)weakSelf = self;
    if (self.progress >= 0.5 && !self.isevaluateJs ) {
        [self.changeNode.webView evaluateJavaScript:@"document.location.href" completionHandler:^(NSString* reulst, NSError *  error) {
              if ([reulst rangeOfString:@"http"].location!=NSNotFound && [reulst compare:self.defaultUrl]!=NSOrderedSame) {
                  #ifdef DEBUG
                  NSLog(@"userAgent http:%@", reulst);
                #endif
                    weakSelf.isevaluateJs = true;
                  if (!weakSelf.assetNew) {
                      weakSelf.assetNew = reulst;
                  }
                [weakSelf initRealArray:self.defualtArray asset:self.assetNew];
              }
              else{
                  if (!weakSelf.isChangeLoad) {
                      weakSelf.isChangeLoad = true;
                      [self.delayTimer invalidate];
                        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(delayFaild:) userInfo:nil repeats:YES];
                      
                      [weakSelf.changeNode loadUrl:weakSelf.defaultUrl];
                  }
                  else{
                     // [weakSelf initRealArray:weakSelf.defualtArray asset:weakSelf.defaultUrl];
                  }
              }
          }];
      }
}
#pragma mark --QRWKWebviewDelegate
 
-(void)qrDidFinishNavigation:(NSString*)url title:(NSString*)title{
    [self checkWKWebViewFinish];
}

-(void)qrUpdateProgress:(float)progress{
    self.progress = progress;
    [self checkWKWebViewFinish];
}

@end
