//
//  WebPushManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "WebCartoonManager.h"
#import "AppDelegate.h"
#import "FTWCache.h"
#import "YYCache.h"
#import "MajorCartoonAssetManager.h"
#define Cartoon_url_key @"Cartoon_url_key"
#define Cartoon_preUrl_key @"Cartoon_preUrl_key"
#define Cartoon_nextUrl_key @"Cartoon_nextUrl_key"
#define Cartoon_picUrl_key @"Cartoon_picUrl_key"
#define Cartoon_Type_key @"Cartoon_Type_key"

@interface WebCartoonManager ()<WebCartoonItemDelegate,MajorCartoonAssetManagerDelegate>{
    
}
@property (nonatomic,strong)YYCache *cacheObject;
@property (nonatomic,strong)NSString *typeKey;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,assign)BOOL isStart;
@property (nonatomic,copy)NSDictionary *parseInfo;
@property (nonatomic,strong)WebCartoonItem *reqeustItem;
@property (nonatomic,strong)NSMutableArray *arrayData;
@property (nonatomic,strong)NSMutableArray *parseData;
@property (nonatomic,assign)NSInteger retryTime;
@property (nonatomic,strong) dispatch_block_t afterBlock;
@property (nonatomic,assign)BOOL isDelData;
@property (nonatomic,assign)BOOL isReqeustSuccess;
@property (nonatomic, copy) void(^webPushFaild)(void);
@property (nonatomic, copy) void(^showBlock)(NSArray *array);
@property (nonatomic, copy) void(^beginUrlRequest)(void);
@property (nonatomic, copy) void(^webPushItemUpdate)(WebCartoonItem *item,NSArray *array,BOOL isRemoveOldAll);
@end

@implementation WebCartoonManager

+(WebCartoonManager*)getInstance
{
    static WebCartoonManager *g = NULL;
    if (!g) {
        g = [[WebCartoonManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    if (![[NSFileManager defaultManager]fileExistsAtPath:WebCartoonAsset]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:WebCartoonAsset withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [MajorCartoonAssetManager getInstance].delegate = self;
    self.arrayData = [NSMutableArray arrayWithCapacity:20];
    self.parseData = [NSMutableArray arrayWithCapacity:20];
    self.isReqeustSuccess = false;
    return self;
}

 
-(void)stop{
    [[MajorCartoonAssetManager getInstance] clearAllAsset];
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
    self.cacheObject = nil;
    self.webPushItemUpdate = nil;
    self.webPushFaild = nil;
    [self clearAllItem];
    [self.arrayData removeAllObjects];
    self.isStart = false;
}

-(void)clearAllItem{
    [[MajorCartoonAssetManager getInstance] clearAllAsset];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqeustNextAsset:) object:nil];
    self.cacheObject = nil;
    [self.reqeustItem stop];
    self.reqeustItem = nil;
}

-(void)startWithUrlUsrOldBlock:(NSString*)key url:(NSString*)url parseInfo:(nonnull NSDictionary *)parseInfo{
    [self clearAllItem];
    [self startWithUrl:key url: url parseInfo:parseInfo updateBlock:self.webPushItemUpdate beginUrlRequestBlock:self.beginUrlRequest falidBlock:self.webPushFaild];
}

-(void)showDateBlock:(void(^)(NSArray*))showBlock updateBlock:(void(^)(WebCartoonItem*item,NSArray *array,BOOL isRemoveOldAll))updateBlock falidBlock:(void(^)(void))falidBlock{
    self.showBlock = showBlock;
    self.webPushItemUpdate = updateBlock;
    self.webPushFaild = falidBlock;
    if (self.parseData.count>0) {
        self.showBlock(self.parseData);
    }
}

-(void)startWithUrl:(NSString*)key url:(NSString*)url parseInfo:(NSDictionary*)parseInfo updateBlock:(void(^)(WebCartoonItem*item,NSArray *array,BOOL isRemoveOldAll))updateBlock beginUrlRequestBlock:(void(^)(void))beginUrlBlock
 falidBlock:(void(^)(void))falidBlock{
    self.isStart = true;
    self.parseInfo  = parseInfo;
    self.webPushItemUpdate = updateBlock;
    self.webPushFaild = falidBlock;
    self.isDelData = true;
    self.typeKey = key;
    self.beginUrlRequest = beginUrlBlock;
    [self.arrayData removeAllObjects];
    self.cacheObject = [YYCache cacheWithPath:[NSString stringWithFormat:@"%@/%@_dir",WebCartoonAsset,key]];
    NSArray *array = [self.cacheObject allCacheKey];
    
    @weakify(self)
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        WebCartoonItem *item =  (WebCartoonItem*)[self.cacheObject objectForKey:obj];
        WebCartoonItem *newItem = [[WebCartoonItem alloc] initWithUrl:item.url referer:item.url preUrl:item.previousUrl nextUrl:item.nextUrl picUrl:item.picUrl typeKey:item.typeKey];
        newItem.insertTime = item.insertTime;
        if (![[MajorCartoonAssetManager getInstance] addAssetInfo:item]) {
            [self.arrayData addObject:newItem];
        }
    }];
    [self.arrayData sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
         double value1 = ((WebCartoonItem*)obj1).insertTime;
        double value2 = ((WebCartoonItem*)obj2).insertTime;
        if (value1>value2) {
            return NSOrderedDescending;
        }else if (value1 == value2){
            return NSOrderedSame;
        }
        else{return NSOrderedAscending;
     }
    }];
    if (self.webPushItemUpdate && self.arrayData.count>0) {
        self.webPushItemUpdate(nil, self.arrayData, true);
        self.isDelData = false;
    }
    [self.reqeustItem stop];
    self.reqeustItem =  [self.arrayData lastObject];
    BOOL isReqest = false;
    if (!self.reqeustItem) {
        isReqest = true;
        [self reqeustNextAsset:url];
    }
    else{
        if([self.reqeustItem.nextUrl length]>4){
            isReqest = true;
            [self reqeustNextAsset:self.reqeustItem.nextUrl];
        }
    }
    if (isReqest && self.beginUrlRequest && self.arrayData.count==0) {
        self.beginUrlRequest();
    }
}

-(void)reqeustNextAsset:(NSString*)url{
    if ([url length]>4 && self.isStart) {
        self.reqeustItem =   [[WebCartoonItem alloc] initWithUrl:url referer:url preUrl:nil nextUrl:nil picUrl:nil typeKey:self.typeKey];
        self.reqeustItem.parseInfo = self.parseInfo;
        self.reqeustItem.delegate = self;
        [self.reqeustItem start];
    }
}

-(void)updateItem:(NSArray*)array{
    if (array.count>0) {
        [self.arrayData removeAllObjects];
         //创建
      
    }
}

-(void)updateWebCartoonFaild:(id)object{
    WebCartoonItem *item = (WebCartoonItem*)object;
    NSLog(@"updateWebCartoonFaild = %@",item.picUrl);
    [self.cacheObject removeObjectForKey:item.uuid];
}

-(void)updateWebCartoonSuccess:(id)object{
    WebCartoonItem *item = (WebCartoonItem*)object;
    [item fixWillSave];
    NSString *nextUrl = item.nextUrl;
    NSString *picUrl = item.picUrl;
    __weak __typeof(self)weakSelf = self;
    if ([picUrl length]>10) {
        if (![self.cacheObject objectForKey:item.uuid]) {
            [self.cacheObject setObject:object forKey:item.uuid];
        }
        else{
        }
        if (![[MajorCartoonAssetManager getInstance] addAssetInfo:item]) {
            if (self.webPushItemUpdate) {
                self.webPushItemUpdate(object,nil,weakSelf.isDelData);
                self.isDelData = false;
            }
        }
        [self firNext:nextUrl];
    }
    else{
        [self firNext:nextUrl];
    }
}

-(void)firNext:(NSString*)nextUrl{
    @weakify(self)
    self.afterBlock = dispatch_block_create(0, ^{
        @strongify(self)
        [self reqeustNextAsset:nextUrl];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.16 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0),self.afterBlock);
}

-(void)beginCartoonAsset:(WebCartoonItem *)object{
    if (self.webPushItemUpdate) {
        self.webPushItemUpdate(object,nil,self.isDelData);
        self.isDelData = false;
    }
}

  

@end
