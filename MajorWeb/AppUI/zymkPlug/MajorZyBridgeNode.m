//
//  MajorZyBridgeNode.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/22.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZyBridgeNode.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "ZyBrigdgeNode.h"
@interface MajorZyBridgeNode()<ZyBrigdgeNodeDelegate>
@property(strong,nonatomic)NSMutableDictionary *goldBridgeNode;
@property(strong,nonatomic)NSMutableArray *arrayList;
@property(assign,nonatomic)NSInteger index;
@property(strong,nonatomic)ZyBrigdgeNode *birggegNode;
@property(copy,nonatomic)void(^totalBlock)(NSInteger totalNo);
@property(copy,nonatomic)void(^imageBlock)(NSString*imageDom,NSInteger index,NSInteger total);
@end
@implementation MajorZyBridgeNode

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)startWithUrl:(NSString*)webUrl totalBlock:(void(^)(NSInteger totalNo))totalBlock  imageBlock:(void(^)(NSString*imageDom,NSInteger index,NSInteger total))imageBlock{
    if (!self.goldBridgeNode) {
       self.goldBridgeNode = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    self.index = 0;
    self.totalBlock = totalBlock;
    self.imageBlock = imageBlock;
     self.arrayList = [NSMutableArray arrayWithCapacity:100];
    [self startUpdateUrl:webUrl type:0];
}

-(void)stop{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tryToParseNext) object:nil];
    [self.birggegNode stop];
    self.birggegNode = nil;
    self.totalBlock = nil;
    self.imageBlock = nil;
}

-(void)startUpdateUrl:(NSString *)url type:(NSInteger)type{
    if(!self.birggegNode){
        self.birggegNode = [[ZyBrigdgeNode alloc] init];
        self.birggegNode.delegate = self;
    }
    [self.birggegNode startUrl:url type:type];
}

-(void)updateListArray:(NSArray*)array{
    if (self.arrayList.count<=0) {
        self.arrayList = [NSMutableArray arrayWithArray:array];
    }
}

-(void)updateDomContent:(NSString*)domContent url:(NSString*)url{
    if ([domContent length]>10&& ![self.goldBridgeNode objectForKey:[url md5]]) {
        [self.goldBridgeNode setObject:@"1" forKey:[url md5]];
        self.imageBlock(domContent, self.index,self.arrayList.count);
        [self.birggegNode stopLoading];
        [self performSelector:@selector(tryToParseNext) withObject:nil afterDelay:1];
    }
}

-(void)initArrayListFromWeb:(NSDictionary*)ret{
    NSString *domContent = [ret objectForKey:@"dom"];
    if (ret&&self.arrayList.count<=0) {
        self.arrayList = [NSMutableArray arrayWithArray:[ret objectForKey:@"retArray"]];
     }
     if ([domContent length]>10&& ![self.goldBridgeNode objectForKey:[domContent md5]]) {
        [self.goldBridgeNode setObject:@"1" forKey:[domContent md5]];
        self.imageBlock(domContent, self.index,self.arrayList.count);
    }
}

- (void)tryToParseNext{
    if (  self.arrayList.count>0 && ++self.index<self.arrayList.count) {
        [self startUpdateUrl:[self.arrayList objectAtIndex:self.index] type:1];
    }
    if (self.index>=self.arrayList.count) {
        [self.birggegNode stop];;
    }
}
@end
