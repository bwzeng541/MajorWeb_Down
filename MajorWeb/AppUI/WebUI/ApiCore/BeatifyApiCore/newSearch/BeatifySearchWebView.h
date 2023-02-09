//
//  BeatifySearchWebView.h
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/31.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BeatifySearchWebView : BeatifyWebView
-(void)loadUrlFromParam:(NSDictionary*)info;
@end

NS_ASSUME_NONNULL_END
