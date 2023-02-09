//
//  GGSearchSuggestView.h
//  GGBrower
//
//  Created by zengbiwang on 2019/12/16.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GGSearchSuggestViewDelegate <NSObject>
-(void)ggWebSearchSuggestViewClick:(NSString*)word  ;
-(void)ggWebSearchSuggestUpdateFrameClick:(float)height  ;
@end
@interface GGSearchSuggestView : UIView
@property(weak)id<GGSearchSuggestViewDelegate>delegate;
-(void)updateWords:(NSArray*)array;
@end

NS_ASSUME_NONNULL_END
