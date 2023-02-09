//
//  PicUpIconsView.h
//  WatchApp
//
//  Created by zengbiwang on 2018/7/4.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicUpIconsView : UIView
@property(nonatomic,weak)UIViewController *parentCtrl;
@property(nonatomic,assign)BOOL isShowAd;
-(instancetype)initWithFrame:(CGRect)frame withData:(NSArray*)array  info:(NSDictionary*)info key:(NSString*)key;
@end
