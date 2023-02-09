//
//  FileArInfo.h
//  WatchApp
//
//  Created by zengbiwang on 2017/12/21.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "YTKNetwork.h"

@interface FileArInfo : YTKRequest
@property(readonly,nonatomic)NSString *localfile;
- (id)initWithFile:(NSString *)url local:(NSString*)local isCanResumable:(BOOL)isCanResumable forceDelTmpData:(BOOL)forceDelTmpData vi:(NSData*)vi key:(NSData*)keyData type:(NSNumber*)type refer:(NSString*)refer;
@end
