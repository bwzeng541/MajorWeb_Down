
#if DoNotKMPLayerCanShareVideo
#else
#import "GuanliManager1.h"
#import "Z_Node_1.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "FileDonwPlus.h"
#import "MajorSystemConfig.h"
#import "MarjorWebConfig.h"
#import "RecordUrlToUUID.h"
#define ZNodeManagerKeySAVEPATH [NSString stringWithFormat:@"%@/znoe_gogo_Key.info",[NSString stringWithFormat:@"%@/VideoDownCaches",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]]]

@interface GuanliNSDictionary()
@property(retain)NSMutableDictionary *info;
@end
@implementation GuanliNSDictionary :NSObject
-(id)init{
    self = [super init];
    self.info = [NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    [self.info setObject:anObject forKey:aKey];
}

-(id)initWithDictionary:(NSDictionary*)info{
    self = [self init];
    [self.info setDictionary:info];
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.info = [aDecoder decodeObjectForKey:@"info"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.info forKey:@"info"];
}

-(id)objectForKey:(id)key{
    if([key compare:StateUUIDKEY]==NSOrderedSame){
        key = GuanliNodeKey;
    }
    return [self.info objectForKey:key];
}

-(NSDictionary*)getInfo{
    return _info;
}
@end

@interface GuanliManager1()
@property(strong)NSMutableDictionary *z_node_DicNode;
@property(strong)NSMutableDictionary *z_DicNode;
@property(strong)NSMutableArray *zArrayNode;
@property(assign)NSInteger zNodeArrayIndex;
@property(strong)NSString *currentUUID;
@property(strong)NSArray *tmpKeyArray;
@property(strong)NSMutableDictionary *shiBInfo;
@end
@implementation GuanliManager1

+(GuanliManager1*)getInstance{
    static GuanliManager1*g= nil;
    if (!g) {
        g = [[GuanliManager1 alloc]init];
    }
    return g;
}

-(id)init{
    self = [super init];
    self.zArrayNode = [NSMutableArray arrayWithCapacity:10];
    self.z_DicNode = [NSMutableDictionary dictionaryWithCapacity:1];
    self.z_node_DicNode = [NSMutableDictionary dictionaryWithCapacity:1];
    self.zNodeArrayIndex = -1;
    self.shiBInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceMsg2FromApp:) name:@"postMsg2AFromApp" object:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadLocal];
    });
    return self;
}

-(void)reviceMsg2FromApp:(NSNotification*)object{
    NSString *parma0 = [object.object objectForKey:@"parma0"];
    NSString *parma1 = [object.object objectForKey:@"parma1"];
    if (parma1&&parma0) {
        [self addZNode:parma0 parma1:parma1];
    }
}

-(void)loadLocal{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:ZNodeManagerKeySAVEPATH];
    for (int i =0; i < array.count; i++) {
        [self.zArrayNode addObject:[[GuanliNSDictionary alloc] initWithDictionary:[[array objectAtIndex:i]getInfo]]];
    }
    for (int i= 0; i < self.zArrayNode.count; i++) {
        GuanliNSDictionary *info = [self.zArrayNode objectAtIndex:i];
        [self.z_DicNode setObject:[NSDictionary dictionaryWithDictionary:[info getInfo]] forKey:[info objectForKey:GuanliNodeKey]];
    }
}

-(void)addZNode:(NSString*)parma0 parma1:(NSString*)parma1{
    NSString*uuid = [YTKNetworkUtils md5StringFromString:parma0];
    [[RecordUrlToUUID getInstance] addUrl:parma0 uuid:uuid title:parma1];
    if (![self getInfo:uuid])
    {
        GuanliNSDictionary *info = [[GuanliNSDictionary alloc]init];
        [info setObject:[NSString stringWithString:parma0] forKey:GuanliNode2Key];
        [info setObject:[NSString stringWithString:parma1] forKey:GuanliNameKey];
        [info setObject:[NSString stringWithString:uuid] forKey:GuanliNodeKey];
        [self.zArrayNode addObject:info];
        [self.z_DicNode setObject:[NSDictionary dictionaryWithDictionary:[info getInfo]] forKey:uuid];
        [[UIApplication sharedApplication].keyWindow makeToast:@"添加成功,请在管理界面查看" duration:1 position:@"center" ];
        [NSKeyedArchiver archiveRootObject:self.zArrayNode toFile:ZNodeManagerKeySAVEPATH];
        //
        if(self.zNodeArrayIndex==-1 && !GetAppDelegate.isOpen){
            [self startZNode:uuid];
        }
    }
    else{
        [[UIApplication sharedApplication].keyWindow makeToast:@"请勿重复添加" duration:1 position:@"center" ];
    }
}

-(NSDictionary*)getInfo:(NSString*)uuid{
    return [self.z_DicNode objectForKey:uuid];
}

-(NSArray*)getNodeArray{
    NSMutableArray *retNew = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *tmpBatchArray = [NSMutableArray arrayWithArray:self.zArrayNode];
    for (int i = 0;i<self.tmpKeyArray.count;i++) {//查找
        NSString*key = [self.tmpKeyArray objectAtIndex:i];
        for (int j = 0; j < tmpBatchArray.count; j++) {
            if ([[[tmpBatchArray objectAtIndex:j]objectForKey:GuanliNodeKey] compare:key]==NSOrderedSame) {
                [retNew addObject:[tmpBatchArray objectAtIndex:j]];
                [tmpBatchArray removeObjectAtIndex:j];
                break;
            }
        }
    }
    return retNew;
}

-(NSNumber*)isZNodeInQueque:(NSString*)uuid{
    if ([self.z_DicNode objectForKey:uuid]) {
        return [NSNumber numberWithBool:true];
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf21];
    [info setObject:@[uuid] forKey:@"param4"];
    BOOL b1 = [[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue];
    info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf23];
    [info setObject:@[uuid] forKey:@"param4"];
    BOOL b2 = [[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue];
    return  [NSNumber numberWithBool:b1 || b2];
}

-(NSArray*)getNodeKeyArray{
    NSArray *arrayKey =  [[AppWtManager getInstanceAndInit] getWtCallBack:DOWNAPICONFIG.msgappf4];//可能有重复值，
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < self.zArrayNode.count; i++) {
        NSString*key = [[self.zArrayNode objectAtIndex:i] objectForKey:GuanliNodeKey];
        BOOL isFind = false;
        for (int j = 0; j < arrayKey.count; j++) {
            if ([[arrayKey objectAtIndex:j] compare:key]==NSOrderedSame) {
                isFind = true;
                break;
            }
        }
        if (isFind) {
            continue;
        }
        [array addObject:key];
    }
    self.tmpKeyArray =array ;
    return [NSArray arrayWithArray:array];
}

-(NSNumber*)isNodeInArray:(NSString*)uuid{
    if (![self.z_node_DicNode objectForKey:uuid]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf5];
        [info setObject:@[uuid] forKey:@"param4"];
        return [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    }
    return [NSNumber numberWithBool:true];
}

-(void)fixbugSetUUIDNIL{
    self.currentUUID = nil;
    for(int i = 0;i<self.tmpKeyArray.count;i++){
        [[NSNotificationCenter defaultCenter] postNotificationName:[self.tmpKeyArray objectAtIndex:i] object:@{state3_info_key:[NSNumber numberWithBool:true]}];
    }
}

-(void)startZNode:(NSString*)uuid{//wifi状态判断
    if([MajorSystemConfig getInstance].isWifiState == AFNetworkReachabilityStatusReachableViaWWAN && ![MarjorWebConfig getInstance].isAllows4GDownMode){//非wifi状态，禁止4g下载
        return;
    }
    NSMutableDictionary*  info = nil;
    NSDictionary *uuidInfo = [self.z_DicNode objectForKey:uuid];
    if (false) //(CanDownMutileFileOneTime == 0)
    {
        if (uuidInfo) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:DOWNAPICONFIG.msgappf6];
        }
        [self stopZNode:self.currentUUID];
    }
    self.currentUUID = uuid;
    self.zNodeArrayIndex = [self findVideoUUID:uuid];
    NSString *uuidrr = [uuidInfo objectForKey:GuanliUUIDNodeKey];
    if (uuidrr) {
        info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf5];
        [info setObject:@[uuid] forKey:@"param4"];
        if (![[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue]) {
            info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf7];
            [info setObject:[NSArray arrayWithObjects:[uuidInfo objectForKey:GuanliNameKey],uuidrr,uuid, nil] forKey:@"param4"];
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];
        }
        info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf8];
        [info setObject:@[uuid] forKey:@"param4"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];
    }
    else
    {
        Z_Node_1 *batch = [[Z_Node_1 alloc]initWithParam0:[uuidInfo objectForKey:GuanliNode2Key] pamar1:[uuidInfo objectForKey:GuanliNameKey] pamar2:uuid];
        [self.z_node_DicNode setObject:batch forKey:uuid];
        batch.block = ^(NSString *pamar0, NSString *pamar1, NSString *pamar2,NSString*title) {
            if (pamar0 && pamar1 && pamar2) {
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf5];
                [info setObject:@[pamar1] forKey:@"param4"];
                if (![[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue]) {
                    info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf7];
                    [info setObject:@[pamar2,pamar0,pamar1] forKey:@"param4"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];
                }
                [self delWebNodeBatch:pamar1];
            }
            else{
                [[NSNotificationCenter defaultCenter]postNotificationName:[@"webGetVideFaild_" stringByAppendingFormat:@"%@",uuid] object:@"webGetVideFaild"];
            }
        };
        [batch start];
        [[NSNotificationCenter defaultCenter] postNotificationName:uuid object:@{state1_info_key:[NSNumber numberWithBool:true]}];
    }
}

-(void)reDownAlter:(NSString*)uuid msg:(NSString*)msg{//
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:msg message:nil];
    TYAlertAction *quxiao  = [TYAlertAction actionWithTitle:@"取消"
                                                      style:TYAlertActionStyleCancel
                                                    handler:^(TYAlertAction *action) {
                                                        
                                                    }];
    [alertView addAction:quxiao];
    TYAlertAction *chongxia  = [TYAlertAction actionWithTitle:@"重新下载"
                                                        style:TYAlertActionStyleDefault
                                                      handler:^(TYAlertAction *action) {
                                                          NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf27];
                                                          [info setObject:@[uuid] forKey:@"param4"];
                                                          [[AppWtManager getInstanceAndInit]getWtCallBack:info];
                                                          
                                                      }];
    [alertView addAction:chongxia];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
}

-(int)findVideoUUID:(NSString*)uuid
{
    for (int i= 0; i < self.zArrayNode.count; i++) {
        GuanliNSDictionary *info = [self.zArrayNode objectAtIndex:i];
        if ([uuid compare:[info objectForKey:GuanliNodeKey]]==NSOrderedSame) {
            return i;
        }
    }
    return -1;
}


-(void)notofi_state_error:(NSString*)uuid{
    [self.shiBInfo setObject:@"1" forKey:uuid];
}

//调用下一个
-(void)notofi_state_next:(NSString*)uuid{
    if (self.zArrayNode.count>0) {
        BOOL ret = true;
        int i = 0;
        while (ret && i < self.zArrayNode.count && uuid) {
            self.zNodeArrayIndex = (self.zNodeArrayIndex+1)%self.zArrayNode.count;
            i++;
            GuanliNSDictionary *info = [self.zArrayNode objectAtIndex:self.zNodeArrayIndex];
            NSString *testUUID =  [info objectForKey:GuanliNodeKey] ;
            if ([testUUID compare:uuid]!=NSOrderedSame && ![self.shiBInfo objectForKey:testUUID]) {
                [self startZNode:[info objectForKey:GuanliNodeKey]];
                ret = false;
            }
            else{
                self.zNodeArrayIndex = (self.zNodeArrayIndex+1)%self.zArrayNode.count;
            }
            return;
        }
        self.zNodeArrayIndex = (self.zNodeArrayIndex+1)%self.zArrayNode.count;
        GuanliNSDictionary *info = [self.zArrayNode objectAtIndex:self.zNodeArrayIndex];
        [self startZNode:[info objectForKey:GuanliNodeKey]];

    }
}

-(void)notofi_state_callBack:(NSString*)uuid error:(int)error{
   // if (self.currentUUID && [self.currentUUID compare:uuid]==NSOrderedSame) {//并行下载？
        if (0==error) {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf8];
            [info setObject:@[uuid] forKey:@"param4"];
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:uuid object:@{state6_info_key:[NSNumber numberWithBool:true]}];
        }
   // }
}

-(BOOL)notofi_state_msg:(NSString*)msg uuid:(NSString*)uuid
{
    if ([self findVideoUUID:uuid]>=0) {
        return true;
    }
    return false;
}

-(void)delWebNodeBatch:(NSString*)uuid{
    Z_Node_1 *z_DicNode =  [self.z_node_DicNode objectForKey:uuid];
    [z_DicNode z_node_1_clearAndKill];
    if (uuid) {
        [self.z_node_DicNode removeObjectForKey:uuid];
    }
}

-(void)stopZNode:(NSString*)uuid{
    [self delWebNodeBatch:uuid];
    if(uuid){
        NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf9];
        [info setObject:@[uuid] forKey:@"param4"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:info];
    }
}

-(void)notofi_state_change:(NSString*)uuid{
    [self delWebNodeBatch:uuid];
}

//成功后删除所有该项目的配置文件
-(void)notofi_state_success:(NSString*)uuid{
    [self deletBatch:uuid];
    if(uuid)
    [self.z_DicNode removeObjectForKey:uuid];
    [self notofi_state_change:uuid];
}

-(void)deletZNodeUUID:(NSString*)uuid{
    [self.shiBInfo removeObjectForKey:uuid];
    if (self.zArrayNode.count==0) {
        self.zNodeArrayIndex=-1;
    }
    [self notofi_state_success:uuid];
}

-(void)deletBatch:(NSString*)uuid{
    for (int i= 0; i < self.zArrayNode.count; i++) {
        GuanliNSDictionary *info = [self.zArrayNode objectAtIndex:i];
        if ([uuid compare:[info objectForKey:GuanliNodeKey]]==NSOrderedSame) {
            [self.zArrayNode removeObjectAtIndex:i];
            if (--self.zNodeArrayIndex<0) {//向后退一位，保证执行下一个的时候位置正确
                self.zNodeArrayIndex=0;
            }
            [NSKeyedArchiver archiveRootObject:self.zArrayNode toFile:ZNodeManagerKeySAVEPATH];
            NSLog(@"删除成功uuid=%@",uuid);
            break;
        }
    }
    if (self.zArrayNode.count==0) {
        self.zNodeArrayIndex=-1;
    }
}

@end
#endif
