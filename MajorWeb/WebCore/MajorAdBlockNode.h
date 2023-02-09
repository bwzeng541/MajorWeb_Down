//
//  MajorAdBlockNode.h
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/4.
//  Copyright © 2019 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MajorAdBlockNodeDelegate <NSObject>
-(void)major_adBlock_result:(NSString*)indentifier ruleList:(WKContentRuleList*)ruleList;
@end
@interface MajorAdBlockNode : NSObject
-(void)startCheckAndCompileAdPlug:(NSString*)identifier jsonContent:(NSString*)jsonContent delegate: (id<MajorAdBlockNodeDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
