//
//  DNLAController.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/2/19.
//  Copyright © 2019 cxh. All rights reserved.
//
#define QRUserLBLelinkKit 0
#import <Foundation/Foundation.h>
#if (QRUserLBLelinkKit==1)
#import <LBLelinkKit/LBLelinkKit.h>
#endif
NS_ASSUME_NONNULL_BEGIN

@interface DNLAController : NSObject
+(DNLAController*)getInstance;
@property(nonatomic,readonly)NSArray *lelinkServices;
#if (QRUserLBLelinkKit==1)
@property(nonatomic,readonly)LBLelinkPlayStatus playStatus;
#endif
@property(nonatomic,readonly)float currentTime;

-(void)showSelectDevice:(void (^)(NSInteger index ))selectDevice;

-(void)sdkAuthRequest;
-(void)playWithUrl:(NSString*)url time:(float)time header:(NSDictionary*)header isLocal:(BOOL)isLocal deviceIndex:(NSInteger)deviceIndex;
-(void)playWithPhotoUrl:(NSString*)url  isPic:(BOOL)isPic deviceIndex:(NSInteger)deviceIndex;
-(void)disConnect;
-(void)startSearchDevice:(void (^)(void))searchBlock;
@end

NS_ASSUME_NONNULL_END
