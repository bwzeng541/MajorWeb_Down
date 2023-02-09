//
//  QRRankDataManager.h
//  QRTools
//
//  Created by zengbiwang on 2020/7/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRRankItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRRankDataManager : NSObject
+(QRRankDataManager*)shareInstance;
-(void)sumibitRankData:(NSString*)text title:(NSString*)webTitle type:(QRRankDataType)dataType isDel:(BOOL)isDel uuid:(NSString*)uuid;
-(QRRankObject*)getQrRankObject:(QRRankDataType)dataType;
-(void)reqeustRankData:(QRRankDataType)dataType number:(NSInteger)requestNumber requestBlock:(void (^)(QRRankObject *object,BOOL isFaild))requestBlock;
-(void)clearReqeust;
@end

NS_ASSUME_NONNULL_END
