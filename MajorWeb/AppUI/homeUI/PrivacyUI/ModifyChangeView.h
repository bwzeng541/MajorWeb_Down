//
//  ModifyView1Ctrl.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ModifyChangeViewDelegate <NSObject>
-(void)willModfiyChangeView;
-(void)willModifyCtrl;
@end
@interface ModifyChangeView : UIViewController
@property(weak,nonatomic)id<ModifyChangeViewDelegate>delegate;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  ;
@end

NS_ASSUME_NONNULL_END
