//
//  QRSearchManager.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRSearchManager.h"
#import "QRSearchNode.h"
#import <UIKit/UIKit.h>
@interface QRSearchManager()<QRSearchNodeDelegate>
@property(nonatomic,weak)UIView *parentView;
@property(nonatomic, strong)NSMutableArray *searchArray;
@property(nonatomic, copy) void (^reArrayBlock)(NSArray *array,BOOL isAdd,BOOL isFinisd);
@end

@implementation QRSearchManager
+(QRSearchManager*)shareInstance{
    static QRSearchManager *g = nil;
    if (!g) {
        g = [[QRSearchManager alloc] init];
    }
    return g;
}

-(QRSearchNode*)buildSearchNode:(NSString*)context url:(NSString*)url type:(NSString*)type{
    QRSearchNode *v = [[QRSearchNode alloc] initWithParam:@{QRSearch_Type_Key:type,QRSearch_Url_Key:url,QRSearch_Word_Key:context} parentView:self.parentView];
    v.delegate = self;
    return v;
}

-(void)startSearch:(NSString*)context parentView:(UIView*)parentView retArray:(void (^)(NSArray *array,BOOL isAdd,BOOL isFinisd))reArrayBlock{
    self.reArrayBlock = reArrayBlock;
    self.parentView = parentView;
    if (!self.searchArray) {
        self.searchArray = [NSMutableArray arrayWithCapacity:10];
    }
    //电影
    [self.searchArray addObject:[self buildSearchNode:context url:@"https://www.shenma4480.com/search/-------------/?wd=" type:@"GET"]];
    [self.searchArray addObject:[self buildSearchNode:context url:@"https://www.tcmove.com/search/-------------.html?wd=" type:@"GET"]];
    //美
    [self.searchArray addObject:[self buildSearchNode:context url:@"https://www.waijutv.com/index.php/vod/search/?wd=" type:@"GET"]];
    //韩
    [self.searchArray addObject:[self buildSearchNode:context url:@"http://www.laohanzong.com/search/-------------.html?wd=" type:@"GET"]];
    //动画
    [self.searchArray addObject:[self buildSearchNode:context url:@"https://www.agefans.tv/search?query=" type:@"GET"]];
    //日剧
    [self.searchArray addObject:[self buildSearchNode:context url:@"http://www.zxfun.net/?s=" type:@"GET"]];
    [self.searchArray makeObjectsPerformSelector:@selector(start)];
}

-(void)stopSearch{
    [self.searchArray makeObjectsPerformSelector:@selector(stop)];
    self.searchArray = nil;
    self.reArrayBlock = nil;
}

-(void)qrSearchRevice:(NSArray*)array object:(nonnull id)object{
    [object stop];
    [self.searchArray removeObject:object];
    if (self.reArrayBlock) {
        self.reArrayBlock(array, YES,self.searchArray.count==0?true:false);
    }
}
@end
