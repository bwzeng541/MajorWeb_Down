//
//  MajorThumbnail.h
//  WatchApp
//
//  Created by zengbiwang on 2017/12/22.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
@class ZFPlayerController;
@protocol MajorThumbnailDelegate<NSObject>
-(void)pipePreFail;
-(void)pipePreSuccess:(BOOL)isFroaceAuto;
-(void)pipePreShortSuccess;
-(void)pipePlayFromWebSuccess:(id)object;
-(BOOL)pipeIsMute;
-(void)pipeClickPlay;
@end
@interface MajorThumbnail : UIView
-(instancetype)initWith:(NSString*)webUrl videoUrl:(NSString*)videoUrl title:(NSString*)title frame:(CGRect)frame isAddWebVideo:(BOOL)isAddWebVideo delegate:(id<MajorThumbnailDelegate>)delegate;
-(id<IJKMediaPlayback>)getPlayInterface;
-(ZFPlayerController*)getZFAVPlayerInterface;
-(void)setPlayInterfaceNil;
-(void)setZFAVPlayerInterfaceNil;
-(void)updateMuteState;
@property (strong,readonly) NSString* videoUrl;
@property (nonatomic,assign)BOOL isShowWeb;
@property (nonatomic,assign)BOOL isPlayAudio;
-(void)play;
-(void)stop;
@end
