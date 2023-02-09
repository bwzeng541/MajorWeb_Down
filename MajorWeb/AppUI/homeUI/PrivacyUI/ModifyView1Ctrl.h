//
//  ModifyView1Ctrl.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ModifyView1CtrlDelegate <NSObject>
-(void)willRemoveCtrlAndMustSyncData;
@end
@interface ModifyView1Ctrl : UIViewController
@property(weak,nonatomic)id<ModifyView1CtrlDelegate>delegate;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil arrayData:(NSArray*)array showName:(NSString*)showName  url:(NSString*)url title:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
