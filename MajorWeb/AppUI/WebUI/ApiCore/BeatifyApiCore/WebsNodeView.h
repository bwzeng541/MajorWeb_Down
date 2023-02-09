//
//  WebsNodeView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorPlayerController.h"
NS_ASSUME_NONNULL_BEGIN
@class WebsNodeView;
@protocol WebsNodeViewDelegate <NSObject>
-(void)clickAsset:(WebsNodeView*)value;
-(void)faildAsset:(WebsNodeView*)value;
-(BOOL)isMuteAsset:(WebsNodeView*)value;
@end
@interface WebsNodeView : NSObject
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, retain) id externObject;
@property (nonatomic, retain) id externObjectThrow;
@property (nonatomic, readonly) MajorPlayerController *player;
@property (nonatomic, weak)id<WebsNodeViewDelegate>delegate;
-(void)initNodePlayer:(NSString*)url oldAsset:(NSString*)oldAsset isSeek:(BOOL)isSeek;
-(void)pause;
-(void)play;
-(void)unInit;
-(ZFPlayerController*)testFution;
-(void)setInterfaceNil;
@end

NS_ASSUME_NONNULL_END
