//
//  QRRankDataManager.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRRankDataManager.h"
#import "AFNetworking.h"
@interface QRRankDataManager()<QRRankObjectDelegate>
@property(nonatomic,strong)AFURLSessionManager *sumbitManager;
@property(nonatomic,strong)NSMutableDictionary *qrReqeustInfo;
@property(nonatomic, copy) void (^requestBlock)(QRRankObject *object,BOOL isFaild);

 @end

@implementation QRRankDataManager
+(QRRankDataManager*)shareInstance{
     static QRRankDataManager *g = nil;
    if (!g) {
        g = [[QRRankDataManager alloc] init];
    }
    return g;
}

-(id)init{
    self = [super init];
    if (!self.sumbitManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.sumbitManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    self.qrReqeustInfo = [NSMutableDictionary dictionary];
    QRRankObject *v1 =[[QRRankObject alloc]initWithUrl:[self buildObject:QRRank_Url_Type] request:QRRank_Url_Type delegate:self];
    QRRankObject *v2 =[[QRRankObject alloc]initWithUrl:[self buildObject:QRRank_Host_Type] request:QRRank_Host_Type delegate:self];
    QRRankObject *v3 =[[QRRankObject alloc]initWithUrl:[self buildObject:QRRank_Search_Type] request:QRRank_Search_Type delegate:self];
    QRRankObject *v4 =[[QRRankObject alloc]initWithUrl:[self buildObject:QRRank_Get_Recommends_Type] request:QRRank_Get_Recommends_Type delegate:self];
    QRRankObject *v5 =[[QRRankObject alloc]initWithUrl:[self buildObject:QRRank_Get_Ads_Type] request:QRRank_Get_Ads_Type delegate:self];
    [self.qrReqeustInfo setObject:v1 forKey:[NSString stringWithFormat:@"%d",QRRank_Url_Type]];
    [self.qrReqeustInfo setObject:v2 forKey:[NSString stringWithFormat:@"%d",QRRank_Host_Type]];
    [self.qrReqeustInfo setObject:v3 forKey:[NSString stringWithFormat:@"%d",QRRank_Search_Type]];
    [self.qrReqeustInfo setObject:v4 forKey:[NSString stringWithFormat:@"%d",QRRank_Get_Recommends_Type]];
    [self.qrReqeustInfo setObject:v5 forKey:[NSString stringWithFormat:@"%d",QRRank_Get_Ads_Type]];

    return self;
}

-(NSString*)buildObject:(QRRankDataType)dataType{
    NSString *url = nil;
         if (dataType== QRRank_Url_Type) {
             url = @"http://47.101.154.106:19801/record/uris/top";
         }
         else if(dataType== QRRank_Host_Type){
             url = @"http://47.101.154.106:19801/record/domains/top";
         }
         else if(dataType==QRRank_Search_Type){
             url = @"http://47.101.154.106:19801/record/searchs/top";
         }
         else if(dataType==QRRank_Get_Recommends_Type){
            url = @"http://47.101.154.106:19801/record/recommends/top";
         }
         else if(dataType==QRRank_Get_Ads_Type){
             url = @"http://47.101.154.106:19801/record/ads/top";
         }
    return url;
}

-(void)reqeustFinish:(QRRankObject*)object isSuccess:(BOOL)isSuccess{
    if (self.requestBlock) {
        self.requestBlock(object,isSuccess);
    }
}

-(void)clearReqeust{
    self.requestBlock = nil;
}

-(QRRankObject*)getQrRankObject:(QRRankDataType)dataType{
    return  [self.qrReqeustInfo objectForKey:[NSString stringWithFormat:@"%d",dataType]];
}

-(void)reqeustRankData:(QRRankDataType)dataType number:(NSInteger)requestNumber requestBlock:(void (^)(QRRankObject *object,BOOL isFaild))requestBlock{
    self.requestBlock = requestBlock;
    [[self.qrReqeustInfo objectForKey:[NSString stringWithFormat:@"%d",dataType]] reqeuestData:requestNumber];
}

-(void)sumibitRankData:(NSString*)text title:(NSString*)webTitle type:(QRRankDataType)dataType isDel:(BOOL)isDel uuid:(NSString*)uuid{
    NSString *url = nil;
    NSString *nameparame = nil;
    if (dataType==QRRank_Host_Type||dataType==QRRank_Url_Type) {
        url = @"http://47.101.154.106:19801/record/uris";
        if (dataType==QRRank_Host_Type) {
            nameparame = @"domain_nickname";
        }
        else {
            nameparame = @"nickname";
        }
        if(dataType==QRRank_Host_Type && isDel){
            url = @"http://47.101.154.106:19801/record/domains";
        }
    }
    else if(dataType==QRRank_Search_Type){
        url = @"http://47.101.154.106:19801/record/searchs";
    }
    else if(dataType==QRRank_Post_Recommends_Type || dataType==QRRank_Get_Recommends_Type){
          url = @"http://47.101.154.106:19801/record/recommends";
            nameparame = @"nickname";
    }
    else if(dataType==QRRank_Post_Ads_Type || dataType == QRRank_Get_Ads_Type){
        url = @"http://47.101.154.106:19801/record/ads";
        nameparame = @"nickname";
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"name"]=text;
    if (isDel) {
        parameters[@"del"]=@"del";
        parameters[@"id"] = uuid;
    }
    else{
        if (nameparame) {
            webTitle = webTitle?webTitle:@"";
            parameters[nameparame]=webTitle;
        }
    }
    NSMutableURLRequest * request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    request.timeoutInterval=2;
    NSURLSessionDataTask *dataTask = [self.sumbitManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                 #ifdef DEBUG
                  if (error) {
                   printf("Error: %s\n", [[error description] UTF8String]);
            } else {
                printf("%s %s\n", [[response description] UTF8String], [[responseObject description] UTF8String]);
            }
            #endif
    }];
    [dataTask resume];
}
@end
