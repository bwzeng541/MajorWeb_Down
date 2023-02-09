//
//  ThrowWebController.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "AXWebViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ThrowWebControllerWillRemove)(void);

@interface ThrowWebController : AXWebViewController
@property(copy)ThrowWebControllerWillRemove willRemoveBlock;
@end

NS_ASSUME_NONNULL_END
