//
//  MajorAdBlockNode.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/4.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorAdBlockNode.h"
@interface MajorAdBlockNode()
@property(copy)NSString*identifier;
@property(weak)id<MajorAdBlockNodeDelegate>delegate;
@end
@implementation MajorAdBlockNode

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)startCheckAndCompileAdPlug:(NSString*)identifier jsonContent:(NSString*)jsonContent delegate: (id<MajorAdBlockNodeDelegate>)delegate{
    self.delegate = delegate;
    self.identifier = identifier;
    [WKContentRuleListStore.defaultStore lookUpContentRuleListForIdentifier:identifier completionHandler:^(WKContentRuleList *ret, NSError *error) {
        NSLog(@"..");
        if (!ret) {
            [WKContentRuleListStore.defaultStore compileContentRuleListForIdentifier:identifier encodedContentRuleList:jsonContent completionHandler:^(WKContentRuleList *ruleList, NSError *error) {
                    if (!error) {
                        [self.delegate major_adBlock_result:self.identifier ruleList:ruleList];
                    }
                    else{
                        [self.delegate major_adBlock_result:self.identifier ruleList:nil];
                    }
            }];
        }
        else{
            [self.delegate major_adBlock_result:self.identifier ruleList:ret];
        }
    }];
}
@end
