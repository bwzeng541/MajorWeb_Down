//
//  SSDjsView.h
//  WatchApp
//
//  Created by zengbiwang on 2018/7/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SSDjsViewAuToRemove)(void);
@interface SSDjsView : UIView
@property(copy)SSDjsViewAuToRemove autoRemove;
@end
