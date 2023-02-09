//
//  QRWebBlockManager.h
//  QRTools
//
//  Created by bxing zeng on 2020/5/11.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

extern NSString *qrJsWebKey ;
extern NSString *qrJsWebAssetKey ;
@interface QRWebBlockManager : NSObject
 
+(QRWebBlockManager*)shareInstance;
 
-(NSString*)getQrJsStringFromKey:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
