//
//  PhotosAddCtrl.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PhotosAddCtrlDelegate <NSObject>
-(void)photos_add_ctrl_will_remove;
@end
@interface PhotosAddCtrl : UIViewController
@property(weak,nonatomic)id<PhotosAddCtrlDelegate>delegate;
-(id)initWithNibName:(NSString *)nibNameOrNil  dirKey:(NSString*)dirKey;
-(void)initUI;
@end

NS_ASSUME_NONNULL_END
