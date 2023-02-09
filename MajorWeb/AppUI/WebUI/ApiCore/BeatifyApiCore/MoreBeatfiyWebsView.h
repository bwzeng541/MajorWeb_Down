//
//  MoreBeatfiyWebsView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/7/31.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeatifyWebView.h"
NS_ASSUME_NONNULL_BEGIN

@interface MoreBeatfiyWebsView : UIView
-(void)updateTitle:(NSString*)title;
-(instancetype)initWithFrame:(CGRect)frame array:(NSArray*)array isDefautAsset:(BOOL)isDefautAsset  title:(NSString*)title url:(NSString*)url webNode:(id)webNode callBack:(void(^)(void))willCallBack isSeek:(BOOL)isSeek;
@end

NS_ASSUME_NONNULL_END
