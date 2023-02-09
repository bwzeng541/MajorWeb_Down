//
//  MajorPrivacyHome.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/8.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MajorPrivacyHomeDelegate <NSObject>
-(void)major_privacy_end_remove;
@end
@interface MajorPrivacyHome : UIView
@property(weak)id<MajorPrivacyHomeDelegate>delegate;
-(void)initUI;
-(void)changeContent:(UIButton*)sender;
-(void)addUrlTitle:(NSString *)url title:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
