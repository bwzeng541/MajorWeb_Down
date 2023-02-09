//
//  MajorFeedbackKit.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/13.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorFeedbackKit : NSObject
+(MajorFeedbackKit*)getInstance;
-(void)openFeedbackViewController:(UIViewController*)ctrl;
@end
