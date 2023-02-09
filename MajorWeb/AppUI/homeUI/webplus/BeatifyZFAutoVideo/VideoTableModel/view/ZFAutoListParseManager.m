//
//  ZFAutoListParseManager.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/8/20.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ZFAutoListParseManager.h"
#import "BeatifyWebView.h"
#import "AppDelegate.h"
#import "WebPushItem.h"
#import "YYCache.h"
#define ZFAutoListParseSave @"ZFAutoListParseSave"
static BOOL updateList = true;

@implementation ZfAutoListCacheItem
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.assetUrl forKey:@"assetUrl"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [[ZfAutoListCacheItem alloc] init];
    if(self != nil)
    {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.assetUrl = [aDecoder decodeObjectForKey:@"assetUrl"];
    }
    return self;
}
@end

@interface ZFAutoListParseManager()<BeatifyWebViewDelegate,BeatifyWebViewPostMoreInfoDelegate,WebPushItemDelegate>{
    int subCount ;
    int currentIndex;
}
@property(nonatomic,strong)NSMutableDictionary *goldInfo;
@property(nonatomic,assign)BOOL isReadyInit;
@property(nonatomic,copy) NSString *typeMd5;
@property(nonatomic,assign)NSInteger typePos;
@property(nonatomic,strong)NSArray *assetArray;
@property(nonatomic,strong)NSMutableDictionary *uuidKey;
@property(nonatomic,strong)BeatifyWebView *webView;
@property(nonatomic,assign)NSInteger retryTime;
@property(strong,nonatomic)NSMutableArray *listArray;
@property(strong,nonatomic)NSMutableArray *webItemArray;
@property(assign,nonatomic)BOOL listArrayChange;
@property(strong,nonatomic)NSTimer *delaytTimer;
@property(strong,nonatomic)YYCache *zfautoFaviteCache;
@property(strong,nonatomic)YYCache *zfautolistCache;
@property(strong,nonatomic)NSMutableDictionary *zfautolistNoSave;
@end
@implementation ZFAutoListParseManager

+(ZFAutoListParseManager*)getInstance{
    static ZFAutoListParseManager *g = NULL;
    if (!g) {
        g = [[ZFAutoListParseManager alloc] init];
    }
    return g;
}

-(id)init{
   self = [super init];
    self.zfautoFaviteCache = [YYCache cacheWithName:@"zfautolistCache"];
    self.zfautolistCache = [YYCache cacheWithName:@"zfautolistTypeCache"];
    self.goldInfo = [NSMutableDictionary dictionaryWithCapacity:100];
    self.zfautolistNoSave = [NSMutableDictionary dictionaryWithCapacity:10];
    return self;
}

-(void)startParse{
    [self stopParse];
    currentIndex =0;
    self.uuidKey = [NSMutableDictionary dictionaryWithCapacity:200];
    self.listArray = [NSMutableArray arrayWithCapacity:10];
   
    self.webItemArray = [NSMutableArray arrayWithCapacity:10];
    self.retryTime = 0;subCount = 0;
    self.webView = [[BeatifyWebView alloc] initWithFrame:CGRectMake(0, 20000, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)isShowOpUI:false];
    [self.webView loadWebView];
    [self.webView loadAllJs:true];
    self.webView.delegate = self;
    self.webView.postMoreInfoDelegate = self;
    updateList = true;
    [GetAppDelegate.window.rootViewController.view addSubview:self.webView];
    [self loadWeb];
}

-(NSArray*)getDefaultArray{
    if (self.typePos>0) {
        return [NSArray array];
    }
        NSString *dataName = @"data";
        if (true/*GetAppDelegate.isGetSuccess*/) {
            dataName = @"newData";
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:dataName ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        return [rootDict objectForKey:@"list"];
}

-(void)updateTypePos:(NSInteger)pos delayTime:(float)time{
    [self.delaytTimer invalidate];self.delaytTimer = nil;
    if (pos<self.assetArray.count) {
        self.typePos = pos;
        id vv = [self.assetArray objectAtIndex:self.typePos];
        self.typeMd5 = [[vv objectForKey:@"url"] md5];
        NSArray*array = [self getDefaultData];
        self.listArray = [NSMutableArray arrayWithArray:array?array:[NSArray array]];
        [self stopParse];
        for (int i = 0; i < self.webItemArray.count; i++) {
            [[self.webItemArray objectAtIndex:i] stop];
        }
        self.delaytTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(delayTimer) userInfo:nil repeats:YES];
    }
}

-(void)delayTimer{
    [self.delaytTimer invalidate];self.delaytTimer = nil;
    [self startParse];
}

-(void)initAssetArray:(NSArray*)array{
    if (!self.isReadyInit) {
        self.assetArray = array;
        [self updateTypePos:0 delayTime:0];
        if (array.count>1) {
            self.isReadyInit = YES;
        }
    }
}

-(NSArray*)getDefaultData{
    if (self.typePos==0) {
        return (NSArray*)[self.zfautolistCache objectForKey:self.typeMd5];//[[NSUserDefaults standardUserDefaults]objectForKey:ZFAutoListParseSave];
    }
    return (NSArray*)[self.zfautolistNoSave objectForKey:self.typeMd5];
}

-(void)loadWeb{
    [self.webView loadURL:[NSURL URLWithString:[[self.assetArray objectAtIndex:self.typePos]objectForKey:@"url"]]];
}

-(void)stopParse{
    for (int i = 0; i < self.webItemArray.count; i++) {
        [[self.webItemArray objectAtIndex:i] stop];
    }
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

- (void)webViewWithError:(BeatifyWebView *)webView didFailLoadWithError:(NSError *)error{
   // printf("listParse error\n");
    if (self.webView && self.retryTime++<4) {
        [self performSelector:@selector(loadWeb) withObject:nil afterDelay:4];
    }
    else{
        [self stopParse];
    }
}

- (void)webViewDidFinishLoad:(BeatifyWebView *)webView{
    [webView evaluateJavaScript:@"gotoParseWeb()" completionHandler:^(NSDictionary* ret, NSError * _Nullable error) {
        //printf("error = %s count = %ld \n",[[error description]UTF8String],ret.count);
    }];
}

-(void)webViewPostAssetInfoCallBack:(NSDictionary *)info{
    [self updateItem:[info objectForKey:@"array"] isClose:[[info objectForKey:@"isClose"]boolValue]];
}

-(NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to
{
    return (NSInteger)(from + (arc4random()%(to-from + 1)));
}

- (NSMutableArray *) randomizedArrayWithArray:(NSArray *)array {
    NSMutableArray *results = [[NSMutableArray alloc]initWithArray:array];
    NSInteger i = [results count];
    if (i>6) {
        i = [self getRandomNumber:0 to:i-1];
        while(--i > 0) {
            int j = rand() % (i+1);
            [results exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
    }
    return results;
}

-(void)updatelistArray{
    if (self.listArray.count>6 && updateList && !self.isCanUpdate) {updateList = false;
        self.listArray = [self randomizedArrayWithArray:self.listArray];
    }
}

-(void)updateItem:(NSArray *)array isClose:(BOOL)isClose{
    if (array.count>0) {
              [self startItemParse:array];
    }
    if(isClose){
        [self stopParse];
    }
}

-(void)startItemParse:(NSArray*)array{
    NSLog(@"uuid asset (NSArray*) = %ld",array.count);
    for (int i =0; i < array.count; i++) {
        NSDictionary *info = [array objectAtIndex:i];
        WebPushItem* webItem = [[WebPushItem alloc] initWithUrl:[info objectForKey:@"url"] iconUrl:[info objectForKey:@"imgUrl"] referer:[info objectForKey:@"referer"] title:[info objectForKey:@"title"]];
        id value = [self.goldInfo objectForKey:webItem.uuid];
        if (value) {
            [self updateWebInfoSuccess:value uuid:webItem.uuid];
        }
        else{
            if(![self.uuidKey objectForKey:webItem.uuid]){
                [self.uuidKey setObject:@"0" forKey:webItem.uuid];
                webItem.delegate = self;
                webItem.isVertical = [[info objectForKey:@"isVertical"] boolValue];
            //dispatch_async(dispatch_get_main_queue(), ^{
                [webItem delayStart:currentIndex++*0.05];
            //});
                [self.webItemArray addObject:webItem];
            }
            else
            {
            //NSLog(@"uuid asset = ok");
            }
        }
    }
}

-(void)updateWebInfoSuccess:(id)value uuid:(NSString*)uuid{
    [self.goldInfo setObject:value forKey:uuid];
    [self updateFavite:uuid assetObject:value];
    // NSLog(@"webPushItem = %@",[info description]);
    [self.listArray addObject:value];
    if (self.typePos==0) {
        [self.zfautolistCache setObject:self.listArray forKey:self.typeMd5];
    }
    else{
        [self.zfautolistNoSave setObject:self.listArray forKey:self.typeMd5];
    }
    if(subCount%10==0 || self.webItemArray.count==0 ){
        // [[NSUserDefaults standardUserDefaults] setObject:self.listArray forKey:ZFAutoListParseSave];
        // [[NSUserDefaults standardUserDefaults] synchronize];
        self.listArrayChange = !self.listArrayChange;
    }
    subCount++;
}

-(void)updateWebPushSuccess:(WebPushItem*)object{
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:4];
        [info setObject:object.playUrl forKey:@"video_url"];
        if (object.isVertical) {
            [info setObject:@"135" forKey:@"video_width"];
            [info setObject:@"240" forKey:@"video_height"];
        }
        else{
            [info setObject:@"240" forKey:@"video_width"];
            [info setObject:@"135" forKey:@"video_height"];
        }
        [info setObject:object.title forKey:@"title"];
        if(object.iconUrl){
            [info setObject:object.iconUrl forKey:@"thumbnail_url"];
        }
        [info setObject:object.uuid forKey:@"uuid"];
    [self updateWebInfoSuccess:info uuid:object.uuid];
    [self.webItemArray removeObject:object];
}

-(void)addFavite:(NSString*)uuid assetObject:(id)aasetObject{
    if(uuid){
        [[UIApplication sharedApplication].keyWindow makeToast:@"添加收藏成功" duration:3 position:@"center"];
      [self.zfautoFaviteCache setObject:aasetObject forKey:uuid];
    }
}

-(void)updateFavite:(NSString*)uuid assetObject:(id)aasetObject{
    if ([self.zfautoFaviteCache objectForKey:uuid]) {
        [self.zfautoFaviteCache setObject:aasetObject forKey:uuid];
    }
}

#define ZFAutoListPlayLastAsset @"asset_20191005145325"
-(NSString*)getLastAsset{
  return   [[NSUserDefaults standardUserDefaults] objectForKey:ZFAutoListPlayLastAsset];
}

-(void)saveLastAsset:(NSString*)uuid{
    if (uuid) {
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:ZFAutoListPlayLastAsset];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSArray*)getFavite{
    NSArray *array = [self.zfautoFaviteCache allCacheKey];
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:10];
    for (int i =0; i < array.count;i++) {
      [arrayRet addObject:[self.zfautoFaviteCache objectForKey:array[i]]]  ;
    }
    return arrayRet;
}

-(void)removeFavite:(NSString*)uuid{
    if(uuid)
    [self.zfautoFaviteCache removeObjectForKey:uuid];
    
}
@end
