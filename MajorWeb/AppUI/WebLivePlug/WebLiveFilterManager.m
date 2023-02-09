
//
//  WebLiveFilterManager.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/18.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebLiveFilterManager.h"
#import "WebLiveVaildUrlParse.h"
#define WebLiveFilterManagerSuccessPath  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject] stringByAppendingPathComponent:@"WebLiveFilterSuccess.plist"]

#define WebLiveFilterManagerFalidPath  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject] stringByAppendingPathComponent:@"WebLiveFilterFaild.plist"]

@interface WebLiveFilterManager()
@property(nonatomic,strong)NSMutableDictionary *successInfo;
@property(nonatomic,strong)NSMutableDictionary *faildInfo;
@property(nonatomic,strong)NSArray *arrayData;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)NSInteger successCount;
@property(nonatomic,assign)NSInteger falidCount;
@property(nonatomic,strong)NSTimer *chaoshiTimer;
@property(nonatomic,copy)NSString *currentTile;
@end

@implementation WebLiveFilterManager

+(WebLiveFilterManager*)getFilterManager{
    static WebLiveFilterManager *g = NULL;
    if(!g){
        g = [[WebLiveFilterManager alloc] init];
    }
    return g;
}

-(void)startRun:(NSArray*)array{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webLiveFilterManagerFaild:) name:@"WebLiveFilterManagerFaild" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webLiveFilterManagerSuccess:) name:@"WebLiveFilterManagerSuccess" object:nil];
    self.arrayData = array;
    self.successInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    self.faildInfo = [NSMutableDictionary dictionaryWithCapacity:1];

    NSMutableDictionary *info = [[NSString stringWithContentsOfFile:WebLiveFilterManagerSuccessPath encoding:NSUTF8StringEncoding error:nil] JSONValue];
    if (info) {
        [self.successInfo setDictionary:info];
    }
    info = [[NSString stringWithContentsOfFile:WebLiveFilterManagerFalidPath encoding:NSUTF8StringEncoding error:nil] JSONValue];
    if (info) {
        [self.faildInfo setDictionary:info];
    }
    [self startNextObject];
}

-(void)webLiveFilterManagerSuccess:(NSNotification*)object
{
    self.successCount++;
    if(self.currentTile && [object.object isEqualToString:self.currentTile]){
        [self.successInfo setObject:@"0" forKey:self.currentTile];
        GGLog(@"webLiveFilterManagerSuccess titile = %@",self.currentTile);
        [[self.successInfo JSONString] writeToFile:WebLiveFilterManagerSuccessPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else{
        GGLog(@"webLiveFilterManagerSuccess 名字不一样 titile = %@",self.currentTile);
    }
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [[WebLiveVaildUrlParse getInstance] stopVaildParse];
    [self performSelector:@selector(startNextObject) withObject:nil afterDelay:0.5];
}

-(void)webLiveFilterManagerFaild:(NSNotification*)object{
    self.falidCount++;
    if(self.currentTile && [object.object isEqualToString:self.currentTile]){
        [self.faildInfo setObject:@"1" forKey:self.currentTile];
        GGLog(@"webLiveFilterManagerFaild titile = %@",self.currentTile);
        [[self.faildInfo JSONString] writeToFile:WebLiveFilterManagerFalidPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else{
        GGLog(@"webLiveFilterManagerFaild 名字不一样 titile = %@",self.currentTile);
    }
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    [[WebLiveVaildUrlParse getInstance] stopVaildParse];
    [self performSelector:@selector(startNextObject) withObject:nil afterDelay:0.5];
}

-(void)stop{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)chaoshierror:(NSTimer*)timer
{
    if (self.currentTile) {
        self.falidCount++;
        [self.faildInfo setObject:@"1" forKey:self.currentTile];
        GGLog(@"webLiveFilterManagerFaild titile = %@",self.currentTile);
        NSString *strM = [self.faildInfo JSONString];
        [strM writeToFile:WebLiveFilterManagerFalidPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [[WebLiveVaildUrlParse getInstance] stopVaildParse];
        [self performSelector:@selector(startNextObject) withObject:nil afterDelay:0.5];

    }
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
}

-(void)startNextObject{
    [self.chaoshiTimer invalidate];self.chaoshiTimer = nil;
    if(self.index<self.arrayData.count){
        BOOL isFindNext= false;
        NSString *currentUrl = nil;
        NSString *currentName = nil;
        while (self.index<self.arrayData.count) {
            NSDictionary *info =   (NSDictionary*)[self.arrayData objectAtIndex:self.index];
            NSString *name = [info objectForKey:@"name"];
            NSString *url = [info objectForKey:@"url"];
            NSString *valueF = [self.faildInfo objectForKey:name];
            NSString *valueS = [self.successInfo objectForKey:name];
            if (valueF || valueS) {
                if (valueS) {
                    self.successCount++;
                }
                else{
                    self.falidCount++;
                }
                self.index++;
            }
            else{
                isFindNext = true;
                currentUrl = url;
                currentName = name;
                self.currentTile=name;
                self.index++;
                break;
            }
        }
        
        if (isFindNext) {
            GGLog(@"start filter Count= %ld currentIndex = %ld success = %ld faild = %ld",self.arrayData.count,(long)self.index,(long)self.successCount,(long)self.falidCount);
            [[WebLiveVaildUrlParse getInstance] startWebChannel:currentUrl title:currentName];
            self.chaoshiTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(chaoshierror:) userInfo:nil repeats:YES];
        }
        else{
            GGLog(@"end WebLiveFilterManager Count= %ld currentIndex = %ld success = %ld faild = %ld",self.arrayData.count,(long)self.index,(long)self.successCount,(long)self.falidCount);
        }
        
    }
    else{
        GGLog(@"end filter Count= %ld currentIndex = %ld success = %ld faild = %ld",self.arrayData.count,(long)self.index,(long)self.successCount,(long)self.falidCount);
    }

}
@end
