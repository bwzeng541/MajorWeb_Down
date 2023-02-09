//
//  Majo.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/12.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MajorRecordContentView : UIView
@property(assign,readonly)CGRect imageRect;
-(void)initVideoInfo:(NSString*)titleName url:(NSString*)url time:(NSString*)time base64Png:(NSString*)base64Png fontScale:(float)fontScale number:(NSInteger)line;
@end
