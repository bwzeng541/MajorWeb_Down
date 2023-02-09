//
//  BeatifyWebPicsView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/31.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeatifyWebPicsView : UIView
-(void)loadPicFromWebs:(NSDictionary*)retInfo;
//-(void)initUI:(void(^)(void))backBlock imageBlock:(void(^)(UIImage*image))imageBlock;
-(void)initUI2:(void(^)(void))backBlock imageBlock:(void(^)(UIImage*image))imageBlock clickBlock:(void(^)(NSString*url))clickBlock title:(NSString*)title webUrl:(NSString*)webUrl firstLoadFinish:(void(^)(void))firstLoadBlock;
@end

NS_ASSUME_NONNULL_END
