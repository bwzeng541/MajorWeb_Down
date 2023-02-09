//
//  MajorPreview.h
//  WatchApp
//
//  Created by zengbiwang on 2017/12/22.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "ZFPlayerMediaPlayback.h"
@protocol MajorPreviewDelegate<NSObject>
-(void)pipePreFail:(id)v;
-(void)pipePreSuccess:(id)v;
-(void)pipePreShortSuccess:(id)v;
-(void)pipePlayFromWebSuccess:(id)v;
-(void)pipeAutoPlayer:(id)v;
-(BOOL)pipeIsMute:(id)v;
-(void)pipeClickPlay:(id)v;
-(void)pipeRevicePlayUrl:(id)v;
@end
@interface MajorPreview : UIView
@property(assign,nonatomic)BOOL isCanTestVideoPlay;
@property(weak)id<MajorPreviewDelegate>delegate;
-(instancetype)initWithUrl:(NSString*)url html:(NSString*)html frame:(CGRect)frame  isShowWeb:(BOOL)isShowWeb index:(int)index isAddWebVideo:(BOOL)isAddWebVideo isAutoPlayer:(BOOL)isAutoPlayer isMedia:(BOOL)isMedia  showTitle:(NSString*)title ;
-(NSString*)getRealVideoUrl;
-(int)getIndexPos;
-(id<IJKMediaPlayback>)getPlayInterface;
-(id<ZFPlayerMediaPlayback>)getZFAVPlayerInterface;
-(void)delayStart:(NSInteger)pos delay:(NSInteger)delay;
-(void)start;
-(void)stop;
@end
