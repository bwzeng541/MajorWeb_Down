//
//  QRRecord.h
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/16.
//  Copyright © 2020 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
NS_ASSUME_NONNULL_BEGIN

@interface QRCommon:NSObject
+(NSString *) md5From:(NSString*)str;
+(NSString*)dateFormater:(NSDate*)date;
@end
 
 
@interface QRWordItem:RLMObject
@property(nonatomic,copy)NSString *url;//
@property(nonatomic,copy)NSString *bgUrl;//
@property(nonatomic,copy)NSString *name;//
@end
RLM_ARRAY_TYPE(QRWordItem)

@interface QRSearhWord : RLMObject
@property(nonatomic,copy)NSString *word;//word->uuid
@property(nonatomic,copy)NSString *uuid;//word->uuid
@property RLMArray<QRWordItem> *array;
@property(nonatomic,assign)NSInteger serialNumber;
+(QRSearhWord*)buildQRSearhWord:(NSString*)searchWord ;
@end

 
 
NS_ASSUME_NONNULL_END
