//
//  QRRankItemModel.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

 
@interface QRRankItemModel : NSObject<NSCoding,NSCopying>
@property (assign,   nonatomic) NSInteger uuid;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *nickname;
@property (assign, nonatomic) NSInteger click_no;
@end

@interface QRRankRequestModel : NSObject<NSCoding,NSCopying>
@property (assign,   nonatomic) NSInteger code;
@property (strong, nonatomic) NSMutableArray *data;
@property (assign,nonatomic)NSInteger total;
@end

typedef enum QRRankDataType{
    QRRank_Host_Type,
    QRRank_Url_Type,
    QRRank_Search_Type,
    QRRank_Post_Recommends_Type,
    QRRank_Get_Recommends_Type,
    QRRank_Post_Ads_Type,
    QRRank_Get_Ads_Type,
}QRRankDataType;

@class QRRankObject;
@protocol QRRankObjectDelegate <NSObject>
-(void)reqeustFinish:(QRRankObject*)object isSuccess:(BOOL)isSuccess;
@end
@interface  QRRankObject:NSObject
@property(readonly,nonatomic)QRRankRequestModel *dataMode;
@property(readonly,nonatomic)QRRankDataType dataType;
@property(readonly,nonatomic)BOOL isFinish;
-(instancetype)initWithUrl:(NSString*)url request:(QRRankDataType)dataType delegate:(id<QRRankObjectDelegate>)delegate;
-(void)reqeuestData:(NSInteger)requestNumber;
@end
NS_ASSUME_NONNULL_END
