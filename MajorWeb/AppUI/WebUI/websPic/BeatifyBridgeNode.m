
#import "BeatifyBridgeNode.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "WebBrigdgeNode.h"
#import "MKNetworkKit.h"
#import "YYCache.h"
static YYCache *g_beatifyBridgeYY = nil;
@interface BeatifyBridgeNode()<ZyBrigdgeNodeDelegate>
@property(strong,nonatomic)MKNetworkEngine *imageKit;
@property(copy,nonatomic)NSString *uuid;
@property(strong,nonatomic)NSMutableDictionary *goldBridgeNode;
@property(strong,nonatomic)NSMutableArray *arrayList;
@property(assign,nonatomic)NSInteger index;
@property(strong,nonatomic)WebBrigdgeNode *birggegNode;
@property(strong,nonatomic)MKNetworkOperation *operation;
@property(assign,nonatomic)BOOL useRerfer;
@property(assign,nonatomic)NSInteger oldType;
@property(strong,nonatomic)NSTimer *nextTimer;
@property(copy,nonatomic)void(^totalBlock)(NSInteger totalNo);
@property(copy,nonatomic)void(^addImageBlock)(NSString *filePath);
@property(copy,nonatomic)void(^imageBlock)(NSString*imageDom,NSInteger index,NSInteger total);
@end
@implementation BeatifyBridgeNode

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)startWithUrl:(NSArray*)webUrls  type:(NSInteger)type useRerfer:(BOOL)useRerfer  totalBlock:(void(^)(NSInteger totalNo))totalBlock  imageBlock:(void(^)(NSString*imageDom,NSInteger index,NSInteger total))imageBlock addImageBlock:(void(^)(NSString* filePath))addImageBlock{
    if (!self.goldBridgeNode) {
       self.goldBridgeNode = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    if (!g_beatifyBridgeYY) {
        g_beatifyBridgeYY = [YYCache cacheWithName:@"brigdeCache"];
    }
    self.addImageBlock = addImageBlock;
    self.useRerfer = useRerfer;
    self.index = 0;
    self.totalBlock = totalBlock;
    self.imageBlock = imageBlock;
    if (webUrls.count>0) {
        self.uuid = [[webUrls objectAtIndex:0] md5];
        NSArray *array = (NSArray *)[g_beatifyBridgeYY objectForKey:self.uuid];
        if (array.count>0) {
            type = 1;
            webUrls = array;
        }
    }
    self.oldType = type;
    self.arrayList = [NSMutableArray arrayWithArray:webUrls];
    [self startUpdateUrl:[webUrls objectAtIndex:0] type:type];
}

-(void)stop{
    [self.nextTimer invalidate];self.nextTimer = nil;
    [self.operation cancel];
    self.operation = nil;
    self.imageKit = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tryToParseNext) object:nil];
    [self.birggegNode stop];
    self.birggegNode = nil;
    self.totalBlock = nil;
    self.imageBlock = nil;
    self.addImageBlock = nil;
    [self.goldBridgeNode removeAllObjects];
}

-(void)startUpdateUrl:(NSString *)url type:(NSInteger)type{
    if(!self.birggegNode){
        self.birggegNode = [[WebBrigdgeNode alloc] init];
        self.birggegNode.delegate = self;
    }
    [self.birggegNode startUrl:url type:type];
}

-(void)revicePic:(NSString*)filePath{
    if (self.addImageBlock) {
        self.addImageBlock(filePath);
    }
}

-(void)updateListArray:(NSArray*)array{
    if (self.arrayList.count<=0) {
        self.arrayList = [NSMutableArray arrayWithArray:array];
    }
    if (self.oldType==0) {
        self.oldType = 1;
        [g_beatifyBridgeYY setObject:array forKey:self.uuid];
        self.arrayList = [NSMutableArray arrayWithArray:array];
    }
}


-(void)updateDomContent:(NSString*)domContent url:(NSString*)url imageUrl:(nonnull NSString *)imageUrl isLocal:(BOOL)isLocal picName:(NSString*)picName{
    if ([domContent length]>10&& ![self.goldBridgeNode objectForKey:[url md5]]) {
        [self.goldBridgeNode setObject:@"1" forKey:[url md5]];
        if (!self.imageKit) {
            if (self.useRerfer) {
                self.imageKit = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:@{@"Referer":url}];
            }
            else{
                self.imageKit = [[MKNetworkEngine alloc] init];
            }
        }
        [self.birggegNode stopLoading];
        if (isLocal) {
            self.imageBlock(domContent, self.index,self.arrayList.count);
            [self performSelector:@selector(tryToParseNext) withObject:nil afterDelay:0.1];
        }
        else{
            self.operation =  [self.imageKit operationWithURLString:imageUrl timeOut:3];
            [self.imageKit enqueueOperation:self.operation];
            [self.operation onCompletion:^(MKNetworkOperation *completedOperation) {
               NSString *fileSave = [[BeatifyWebPicsViewWebRoot stringByAppendingPathComponent:BeatifyWebPicsViewPicDirName] stringByAppendingPathComponent:picName];
                [completedOperation.responseData writeToFile:fileSave atomically:YES];
                //本地图片地址
                [self revicePic:fileSave];
                //end
                fileSave = [[NSURL fileURLWithPath:fileSave] absoluteString];
                NSString *name = [fileSave substringFromIndex:[fileSave rangeOfString:@"/pics/"].location+6];
                fileSave = [@"http://localhost:10086" stringByAppendingFormat:@"%@%@",@"/pics/",name];
                NSString *tmpdomContent = [domContent stringByReplacingOccurrencesOfString:@"20191101pic_key" withString:fileSave];
                self.imageBlock(tmpdomContent, self.index,self.arrayList.count);
                [self.nextTimer invalidate];self.nextTimer = nil;
                self.nextTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tryToParseNext) userInfo:nil repeats:YES];
            } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
                //self.imageBlock(domContent, self.index,self.arrayList.count);
                [self.nextTimer invalidate];self.nextTimer = nil;
                self.nextTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tryToParseNext) userInfo:nil repeats:YES];
            }];
            
        }
    }
}

-(void)initArrayListFromWeb:(NSDictionary*)ret{
    NSString *domContent = [ret objectForKey:@"dom"];
    if (ret&&self.arrayList.count<=0) {
        self.arrayList = [NSMutableArray arrayWithArray:[ret objectForKey:@"retArray"]];
     }
     if ([domContent length]>10&& ![self.goldBridgeNode objectForKey:[domContent md5]]) {
        [self.goldBridgeNode setObject:@"1" forKey:[domContent md5]];
        self.imageBlock(domContent, self.index,self.arrayList.count);
    }
}

- (void)tryToParseNext{
    [self.nextTimer invalidate];self.nextTimer = nil;
    if (  self.arrayList.count>0 && ++self.index<self.arrayList.count) {
        [self startUpdateUrl:[self.arrayList objectAtIndex:self.index] type:1];
    }
    if (self.index>=self.arrayList.count) {
        [self.birggegNode stop];;
    }
}
@end
