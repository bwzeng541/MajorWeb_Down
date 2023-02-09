//
//  SSExpressNativeManager.h
//  WatchApp
//
//  Created by zengbiwang on 2018/6/26.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SSExpressNativeManagerInterstitialClose)(BOOL isClose);

typedef void (^SSExpressNativeManagerFilmPlayerClose)(BOOL isClose);

@interface SSExpressNativeManager : NSObject
+(SSExpressNativeManager*)getInstance;
@property(copy)SSExpressNativeManagerFilmPlayerClose filmPlayerIntsertitialBlock;
@property(copy)SSExpressNativeManagerInterstitialClose intsertitialBlock;
@property(assign,readonly)BOOL isRenderSuccess;
-(BOOL)isCanChangeID;
-(NSArray*)getExpressNotSupreView:(NSInteger)maxCount;
-(BOOL)isShowExpressInterstitial:(UIViewController*)ctrl showPartView:(UIView*)shawPartView;
-(void)removeExpressFromArray:(NSArray*)array;
-(void)loadNativeExpressAd;
-(BOOL)isCanAddCustomUI;
-(void)closeInterstitial;
@end
