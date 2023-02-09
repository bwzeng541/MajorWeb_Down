//
//  RemoveApiManager.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/28.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoveApiView : UIView
-(id)initWithApi:(NSString*)searchApi searchVideoUrl:(NSString*)searchVideoUrl;
-(void)stop;
-(void)start;
@end

NS_ASSUME_NONNULL_END
