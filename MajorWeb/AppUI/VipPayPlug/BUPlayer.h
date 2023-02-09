//
//  BUPlayer.h
//  BUADDemo
//
//  Created by zengbiwang on 2019/10/16.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUPlayer : NSObject

@end

@interface BUPlayer(ee)
+(void)hook;
+(void)reSetMute:(BOOL)f;
+(BOOL)sendToBack;
@end

NS_ASSUME_NONNULL_END
