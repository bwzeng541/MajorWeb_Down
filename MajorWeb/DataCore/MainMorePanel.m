//
//  MainMorePanel.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MainMorePanel.h"
#import "FTWCache.h"
#import "YYModel.h"
#import "NetworkManager.h"
#import "MarjorWebConfig.h"
#import "AppDelegate.h"
#import "TJLiancePlug.h"
#define MorePanelJsonKey @"MorePanelJsonKey"
#define ArraySortJsonKey @"ArraySortJsonKey"

@interface MainMorePanel(){
    BOOL isInitSuccessPanel;
    BOOL isInitSuccessSort;
}
@property(nonatomic,strong)NSArray *validPanelArray;
@property(nonatomic,strong)morePanel *morePanel;
@property(nonatomic,strong)arraySort *arraySort;
@property(nonatomic,strong)NSTimer *checkVaileTimer;
@property(nonatomic,strong) morePanel *moreTotalPanel;
@property(nonatomic,strong) NSURLSessionDataTask * morePanleTask;
@property(nonatomic,strong) NSURLSessionDataTask * arraySortTask;
@end

@implementation MainMorePanel
+(MainMorePanel*)getInstance{
    static MainMorePanel *g = nil;
    if (!g) {
        g = [[MainMorePanel alloc] init];
    }
    return g;
}

-(void)updateValidPanel:(NSArray*)array{
    self.validPanelArray = array;
}

-(void)initAndRequest{
    if (GetAppDelegate.isProxyState) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    NSData *panelData =  [FTWCache objectForKey:MorePanelJsonKey useKey:YES];
    NSData *sortData =  [FTWCache objectForKey:ArraySortJsonKey useKey:YES];
    if(panelData && sortData){
       NSString *panel1 =  [[NSString alloc] initWithData:panelData encoding:NSUTF8StringEncoding];
        NSString *sort1 =  [[NSString alloc] initWithData:sortData encoding:NSUTF8StringEncoding];
        self.moreTotalPanel  = [morePanel yy_modelWithJSON:[panel1 JSONValue]];
        if (self.moreTotalPanel) {
            self.arraySort  = [arraySort yy_modelWithJSON:[sort1 JSONValue]];
            [self initCheckTimer];
        }
    }
    [self requestSouSou];
}

-(void)requestSouSou{
    if (GetAppDelegate.isProxyState) {
        return;
    }
    @weakify(self)
    if (self.moreTotalPanel && isInitSuccessPanel) {
        return;
    }
    
    self.morePanleTask = [[NetworkManager shareInstance]getInfoFromUrl:[NSString stringWithFormat:@"https://maxdownapp.oss-cn-hangzhou.aliyuncs.com/%@",Max_NEW_Config] callback:^(NSDictionary *returnDict) {
        @strongify(self);
        if ([[returnDict objectForKey:@"returnInfo"] boolValue]) {
            NSString *strContent = [FTWCache decryptWithKey:[returnDict objectForKey:@"data"]];
#ifdef DEBUG //xia_max_config1.2_new
           // strContent  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"xia_max_new1.2_online" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
#endif
            self.moreTotalPanel  = [morePanel yy_modelWithJSON:[strContent JSONValue]];
            if (self.moreTotalPanel) {
                [FTWCache setObject:[strContent dataUsingEncoding:NSUTF8StringEncoding] forKey:MorePanelJsonKey useKey:YES];
                [self requestMoviesTypes];
            }
            self->isInitSuccessPanel = true;
        }
        else{
            [self bk_performBlock:^(id obj) {
                [self requestSouSou];
            } afterDelay:2];
        }
        return;
    }];
}


-(void)requestMoviesTypes{
    @weakify(self)
    if (self.arraySort && isInitSuccessSort) {
        return;
    }
    self.arraySortTask = [[NetworkManager shareInstance]getInfoFromUrl:[NSString stringWithFormat:@"https://maxdownapp.oss-cn-hangzhou.aliyuncs.com/%@",Max_JSON_Config] callback:^(NSDictionary *returnDict) {
        @strongify(self);
        if ([[returnDict objectForKey:@"returnInfo"] boolValue]) {
            NSString *strContent = [FTWCache decryptWithKey:[returnDict objectForKey:@"data"]];
            self.arraySort  = [arraySort yy_modelWithJSON:strContent];
            if (self.arraySort) {
                [FTWCache setObject:[strContent dataUsingEncoding:NSUTF8StringEncoding] forKey:ArraySortJsonKey useKey:YES];
                [self updateNewMorePanel:true];
                [self initCheckTimer];
            }
            self->isInitSuccessSort = true;
        }
        else{
            [self bk_performBlock:^(id obj) {
                [self requestMoviesTypes];
            } afterDelay:2];
        }
        return;
    }];
    
}


-(void)applicationWillEnterForeground{
    [self initCheckTimer];
}

-(void)initCheckTimer{
    [self.checkVaileTimer invalidate];
    [self checkMoreVaild];
    self.checkVaileTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkMoreVaild) userInfo:nil repeats:YES];
}

-(void)checkMoreVaild{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateNewMorePanel:false];
    });
}

-(NSArray*)getApiArrayFromUrl:(NSString *)url{
    NSURL *urltmp = [NSURL URLWithString:url];
    NSString *host = urltmp.host;
    if ([host rangeOfString:@"qq.com"].location!=NSNotFound) {
        return self.morePanel.apiUrlArrayqq;
    }
    else if ([host rangeOfString:@"tv.sohu.com"].location!=NSNotFound) {
        return self.morePanel.apiUrlArraysohu;
    }
    else if ([host rangeOfString:@"mgtv.com"].location!=NSNotFound) {
        return self.morePanel.apiUrlArraymg;
    }
    else if ([host rangeOfString:@"iqiyi.com"].location!=NSNotFound) {
        return self.morePanel.apiUrlArrayaiqy;
    }
    else{
        return self.morePanel.apiUrlArray;
    }
}


-(void)updateNewMorePanel:(float)focreUpdate{
    BOOL isUpdate = false;
    morePanel *tmp = [[morePanel alloc] init];
    tmp.apiUrlArray = self.moreTotalPanel.apiUrlArray;
    tmp.fulld = self.moreTotalPanel.fulld;
    tmp.fullr = self.moreTotalPanel.fullr;
    tmp.apiUrlArrayqq = self.moreTotalPanel.apiUrlArrayqq;
    tmp.apiUrlArrayaiqy = self.moreTotalPanel.apiUrlArrayaiqy;
    tmp.apiUrlArraysohu = self.moreTotalPanel.apiUrlArraysohu;
    tmp.apiUrlArraymg = self.moreTotalPanel.apiUrlArraymg;
    tmp.huyaurl = self.moreTotalPanel.huyaurl;
    tmp.manhuaurl = self.moreTotalPanel.manhuaurl;
    tmp.zyMkArray = self.moreTotalPanel.zyMkArray;
    tmp.manhuaParseInfo = self.moreTotalPanel.manhuaParseInfo;
    tmp.notConfig = self.moreTotalPanel.notConfig;
    tmp.appJumpValue = self.moreTotalPanel.appJumpValue;
    tmp.maskBtn = self.moreTotalPanel.maskBtn;
    tmp.homeItem = self.moreTotalPanel.homeItem;
    tmp.forceFireTime = self.moreTotalPanel.forceFireTime;
    tmp.shareurl = self.moreTotalPanel.shareurl;
    tmp.professional = self.moreTotalPanel.professional;
    tmp.leaguer = self.moreTotalPanel.leaguer;
    tmp.wxBtnInfo = self.moreTotalPanel.wxBtnInfo;
    tmp.tjLiance = self.moreTotalPanel.tjLiance;
    tmp.homeADshow = self.moreTotalPanel.homeADshow;
    tmp.RewardStep = self.moreTotalPanel.RewardStep;
    tmp.webDataLiveInfo = self.moreTotalPanel.webDataLiveInfo;
    tmp.toolsurl = self.moreTotalPanel.toolsurl;
    dispatch_async(dispatch_get_main_queue(), ^{
#ifndef DEBUG
        GetAppDelegate.appJumpValue = [tmp.appJumpValue integerValue];
#else
        GetAppDelegate.appJumpValue = 2;
#endif
    });
    //printf("GetAppDelegate.appJumpValue = %d\n",GetAppDelegate.appJumpValue);
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:10];
    for (int i =0; i < self.moreTotalPanel.morePanel.count; i++) {
        morePanelInfo *panelInfo =  [self.moreTotalPanel.morePanel objectAtIndex:i];
        NSString *btime = panelInfo.beginTime;
        NSString *etime = panelInfo.endTime;
        BOOL isVaild = false;
        if (btime && etime) {
            isVaild = [MarjorWebConfig isValid:btime a2:etime];
        }
        else{
            isVaild = true;
        }
        BOOL isFind = false;
        for (int j = 0; j < self.morePanel.morePanel.count; j++) {
            morePanelInfo *save = [self.morePanel.morePanel objectAtIndex:j];
            if ([save.type compare:panelInfo.type]==NSOrderedSame) {
                isFind = true;
                break;
            }
        }
        if (isVaild && !isFind) {
            isUpdate = true;
        }
        if (!isVaild && isFind){
            isUpdate = true;
        }
        if (isVaild) {
            [tmpArray addObject:panelInfo];
        }
    }
    tmp.morePanel = [NSArray arrayWithArray:tmpArray];
    if (isUpdate || focreUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.morePanel = tmp;
            id  vv = self.arraySort;
            self.arraySort = vv;
            [[TJLiancePlug autoInitPlug] autoInit];
        });
    }
}
@end
