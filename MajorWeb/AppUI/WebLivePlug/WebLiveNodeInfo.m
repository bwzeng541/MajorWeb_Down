//
//  WebLiveNodeInfo.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebLiveNodeInfo.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "WebLiveParseManager.h"
#import "WebLivePlug.h"
@interface WebLiveNodeInfo ()
@property(nonatomic,copy)NSString *title;
@property(nonatomic,strong)NSArray *array;
@property(nonatomic,copy)NSString *uuid;
@property(nonatomic,assign)NSInteger startPos;
@property(nonatomic,assign)NSInteger endPos;
@property(nonatomic,assign)BOOL isDataChange;
@property(nonatomic,strong)NSMutableArray *dataNodeArray;
@end
@implementation WebLiveNodeInfo

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)initWithWebsArray:(NSArray*)websArray title:(NSString*)title{
    self = [super init];
    self.title = title;
    self.array = websArray;
    self.endPos = websArray.count;
    self.dataNodeArray = [NSMutableArray arrayWithCapacity:10];
    self.uuid = [[title stringByAppendingString:@"WebLiveNodeInfo_key"] md5];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLiveNodeSuccess:) name:WebLiveNofitiSuccessMsg(self.uuid) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLiveNodeFaild:) name:WebLiveNofitifaildMsg(self.uuid) object:nil];
    return self;
}

-(void)updateLiveNodeFaild:(NSNotification*)object{
    self.startPos =  [object.object intValue];
}

-(void)updateLiveNodeSuccess:(NSNotification*)object{
    self.startPos =  [[object.object objectForKey:@"index"] intValue]+1;
    [self.dataNodeArray addObjectsFromArray:[object.object objectForKey:@"retKey"]];
    self.isDataChange = !self.isDataChange;
}

-(void)startParse{
    if (self.endPos==self.startPos) {
        self.isDataChange = !self.isDataChange;
    }
    else{
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for  (NSInteger i = self.startPos; i < self.endPos; i++) {
            [array addObject:[self.array objectAtIndex:i]];
        }
        [[WebLiveParseManager getInstance] addParseWeb:array key:self.uuid];
    }
}

-(void)stopParse{
    [[WebLiveParseManager getInstance] stopCurrentParse];
    [[WebLiveParseManager getInstance] deleteWeb:self.uuid];
}


@end
