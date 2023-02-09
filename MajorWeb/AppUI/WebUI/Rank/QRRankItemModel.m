//
//  QRRankItemModel.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRRankItemModel.h"
#import "AFNetworking.h"
#import "YYModel.h"
@implementation QRRankItemModel
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.uuid = [aDecoder decodeInt64ForKey:@"uuid"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.click_no = [aDecoder decodeInt64ForKey:@"click_no"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInt64:self.uuid forKey:@"uuid"];
    [aCoder encodeInt64:self.click_no forKey:@"click_no"];
}
- (id)copyWithZone:(nullable NSZone *)zone{
    QRRankItemModel *object = [[QRRankItemModel alloc] init];
    object.uuid = self.uuid;
    object.name = self.name;
    object.nickname = self.nickname;
    object.click_no = self.click_no;
    return object;
 }

+ (NSDictionary *) modelCustomPropertyMapper {
    return @{@"uuid" : @"id"
             };
}

@end

@implementation QRRankRequestModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [QRRankItemModel class]};
}

- (id)copyWithZone:(nullable NSZone *)zone{
    QRRankRequestModel *object = [[QRRankRequestModel alloc] init];
    object.data = self.data;
    object.code = self.code;
    object.total = self.total;
    return object;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.data = [aDecoder decodeObjectForKey:@"data"];
        self.code = [aDecoder decodeInt64ForKey:@"code"];
        self.total = [aDecoder decodeInt64ForKey:@"total"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeInt64:self.code forKey:@"code"];
    [aCoder encodeInt64:self.total forKey:@"total"];
}


@end
 
#define RequestPageSize 30
@interface    QRRankObject()
@property(strong,nonatomic)QRRankRequestModel *dataMode;
@property(assign,nonatomic)QRRankDataType dataType;
@property(nonatomic,strong)AFURLSessionManager *reqeustManager;
@property(copy,nonatomic)NSString*reqeustUrl;
@property(nonatomic,assign)BOOL isFinish;
@property(nonatomic,assign)NSInteger  pageNo;
@property(weak)id<QRRankObjectDelegate>delegate;
@end

@implementation QRRankObject
-(instancetype)initWithUrl:(NSString*)url request:(QRRankDataType)dataType delegate:(id<QRRankObjectDelegate>)delegate{
    self = [super init];
    if (!self.reqeustManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.reqeustManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    self.pageNo=1;
    self.delegate = delegate;
    self.reqeustUrl = url;
    self.dataType = dataType;
    return self;
}

-(void)reqeuestData:(NSInteger)requestNumber{
    if (self.isFinish) {
         if ([self.delegate respondsToSelector:@selector(reqeustFinish:isSuccess:)]) {
               [self.delegate reqeustFinish:self isSuccess:true];
        }
       return;
    }
    NSInteger number = requestNumber<=0?RequestPageSize:requestNumber;
    NSString *vv = [NSString stringWithFormat:@"%@?pageNo=%ld&pageSize=%d",self.reqeustUrl,self.pageNo,number];
    NSMutableURLRequest * request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:vv parameters:nil error:nil];
      request.timeoutInterval=2;
      NSURLSessionDataTask *dataTask = [self.reqeustManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    if (error) {
                        [self parseData:nil];
              } else {
                 QRRankRequestModel *v = [QRRankRequestModel yy_modelWithJSON:responseObject];
                  [self parseData:v];
               }
      }];
      [dataTask resume];
}

-(void)parseData:(QRRankRequestModel *)v{
    if (!self.dataMode) {
        self.dataMode = [[QRRankRequestModel alloc] init];
        self.dataMode.data = [NSMutableArray arrayWithCapacity:10];
    }
    BOOL isSuccess = false;
    if (v) {
        if (v.code==200) {
            self.pageNo++;
            [self.dataMode.data addObjectsFromArray:v.data];
            self.dataMode.total = v.total;
            if (self.dataMode.data.count>=v.total) {
                self.isFinish = true;
            }
             isSuccess = true;
          }
          else{
              
          }
    }
    if ([self.delegate respondsToSelector:@selector(reqeustFinish:isSuccess:)]) {
        [self.delegate reqeustFinish:self isSuccess:isSuccess];
    }
}
@end
