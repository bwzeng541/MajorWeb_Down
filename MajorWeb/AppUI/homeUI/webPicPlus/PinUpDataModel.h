//
//  PinUpDataModel.h
//  WatchApp
//
//  Created by zengbiwang on 2018/7/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicUpPlusDef.h"

@interface PinUpDataModel : NSObject
@property(nonatomic,assign) BOOL updatePinUpList;
@property(nonatomic,readonly)NSString *reqeustKey;
@property(nonatomic,readonly)NSMutableArray * datasourcePicList;

+(PinUpDataModel*)getPinDataModel;
-(void)httpTheGetCommend:(NSString*)key;
-(void)favTheGetCommend:(NSString*)key;
-(BOOL)favTheBoolCommend:(NSString*)key uuid:(NSString*)uuid;
-(void)favTheDelCommend:(NSString*)key uuid:(NSString*)uuid;
-(void)favTheAddCommend:(NSString*)key object:(id<NSCopying>)object uuid:(NSString*)uuid;
@end
