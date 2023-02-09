//
//  ModifyDetailsCtrl.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ModifyDetailsCtrlDelegate <NSObject>
-(void)willSyncData:(BOOL)isSync newData:(id)data;
-(void)willRmoveCtrl;
@end
@interface ModifyDetailsCtrl : UIViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(id)data url:(NSString*)url title:(NSString*)title;
@property(weak,nonatomic)id<ModifyDetailsCtrlDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
