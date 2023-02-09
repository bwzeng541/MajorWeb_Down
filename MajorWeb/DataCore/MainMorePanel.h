//
//  MainMorePanel.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MajorModeDefine.h"
@interface MainMorePanel : NSObject
@property(nonatomic,readonly)morePanel *morePanel;
@property(nonatomic,readonly)arraySort *arraySort;
@property(nonatomic,readonly)NSArray *validPanelArray;
+(MainMorePanel*)getInstance;
-(void)updateValidPanel:(NSArray*)array;
-(void)initAndRequest;

-(NSArray*)getApiArrayFromUrl:(NSString *)url;

@end
