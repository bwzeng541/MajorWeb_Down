//
//  SavePhotoInfo.h
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SavePhotoInfo : NSObject
@property(nonatomic,strong)NSString *uuid;
@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSString *iconfileName;
@property(nonatomic,strong)NSString *dirName;
@end

NS_ASSUME_NONNULL_END
