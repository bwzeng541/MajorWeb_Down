//
//  WebGeneralTools.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/4.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^WebGeneralToolsAddFavoriteBlock)(void);
typedef NSString* (^WebGeneralToolsSubmitBlock)(void);
typedef void (^WebGeneralToolsAddHomeBlock)(void);
typedef void (^WebGeneralToolsGetRedBagBlock)(void);

@interface WebGeneralTools : UIView
@property(copy)WebGeneralToolsAddFavoriteBlock addFavoriteBlock;
@property(copy)WebGeneralToolsSubmitBlock webSubmitBlock;
@property(copy)WebGeneralToolsGetRedBagBlock  getRedBagBlock;
@property(copy)WebGeneralToolsAddHomeBlock   addHomeBlock;
-(id)initWithFrame:(CGRect)frame;
@end
NS_ASSUME_NONNULL_END
