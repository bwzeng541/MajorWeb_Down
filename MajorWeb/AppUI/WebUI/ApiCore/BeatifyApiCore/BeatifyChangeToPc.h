//
//  BeatifyChangeToPc.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/29.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeatifyChangeToPc : NSObject
-(void)startWithAsset:(NSString*)url callBack:(void(^)(NSString *realAsset))willCallBack;
-(void)unInitAsset;
@end

NS_ASSUME_NONNULL_END
