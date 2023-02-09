//
//  BeatifySearchView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BeatifySearchViewDelegate <NSObject>
@optional
-(void)beatifySearchClick:(NSString*)url;
-(void)beatifySearchBack;
-(void)beatifySearchHome;
-(void)beatifySearchSet;
-(void)beatifySearchNavigation;

@end
@interface BeatifySearchView : UIView
@property(weak)id<BeatifySearchViewDelegate>delegate;
-(void)initWebs:(BOOL)addTj;
-(void)startSearch:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
