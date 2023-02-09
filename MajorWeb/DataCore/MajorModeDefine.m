//
//  MajorModeDefine.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorModeDefine.h"

@implementation HomeAdShow


@end
@implementation TjLiance


@end
@implementation newProfessional

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.beginTime = [aDecoder decodeObjectForKey:@"beginTime"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.beginTime forKey:@"beginTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.url forKey:@"url"];
}


@end

@implementation homeFristItem
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

@end

@implementation forceFireTime
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.btime = [aDecoder decodeObjectForKey:@"btime"];
        self.etime = [aDecoder decodeObjectForKey:@"etime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.btime forKey:@"btime"];
    [aCoder encodeObject:self.etime forKey:@"etime"];
}
@end

@implementation SpuerLeaguer
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.btime = [aDecoder decodeObjectForKey:@"btime"];
        self.etime = [aDecoder decodeObjectForKey:@"etime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.btime forKey:@"btime"];
    [aCoder encodeObject:self.etime forKey:@"etime"];
}
@end

@implementation WeiXinBtnInfo
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.beginTime = [aDecoder decodeObjectForKey:@"beginTime"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.beginTime forKey:@"beginTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
}
@end


@implementation notConfig
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.host = [aDecoder decodeObjectForKey:@"host"];
        self.conifg = [aDecoder decodeObjectForKey:@"conifg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.host forKey:@"host"];
    [aCoder encodeObject:self.conifg forKey:@"conifg"];
}
@end

@implementation searchWebInfo
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
}
@end

@implementation ZyMkInfo

@end

@implementation webDataLiveInfo

@end
@implementation manhuaurlInfo
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.key = [aDecoder decodeObjectForKey:@"key"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
}
@end

@implementation huyaNodeInfo
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
}
@end


@implementation morePanel
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.leaguer = [aDecoder decodeObjectForKey:@"SpuerLeaguer"];
        self.apiUrlArray = [aDecoder decodeObjectForKey:@"apiUrlArray"];
        self.apiUrlArrayqq = [aDecoder decodeObjectForKey:@"apiUrlArrayqq"];
        self.apiUrlArraymg = [aDecoder decodeObjectForKey:@"apiUrlArraymg"];
        self.apiUrlArrayaiqy = [aDecoder decodeObjectForKey:@"apiUrlArrayaiqy"];
        self.apiUrlArraysohu = [aDecoder decodeObjectForKey:@"apiUrlArraysohu"];
        self.morePanel = [aDecoder decodeObjectForKey:@"morePanel"];
        self.notConfig = [aDecoder decodeObjectForKey:@"notConfig"];
        self.homeItem = [aDecoder decodeObjectForKey:@"homeItem"];
        self.professional = [aDecoder decodeObjectForKey:@"professional"];
        self.tjLiance = [aDecoder decodeObjectForKey:@"tjLiance"];
        self.forceFireTime = [aDecoder decodeObjectForKey:@"forceFireTime"];
        self.appJumpValue = [aDecoder decodeObjectForKey:@"appJumpValue"];
        self.huyaurl = [aDecoder decodeObjectForKey:@"huyaurl"];
        self.manhuaurl = [aDecoder decodeObjectForKey:@"manhuaurl"];
        self.manhuaParseInfo = [aDecoder decodeObjectForKey:@"manhuaParseInfo"];
        self.webDataLiveInfo = [aDecoder decodeObjectForKey:@"webDataLiveInfo"];
        self.zyMkArray = [aDecoder decodeObjectForKey:@"zyMkArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.leaguer forKey:@"SpuerLeaguer"];
    [aCoder encodeObject:self.manhuaurl forKey:@"manhuaurl"];
    [aCoder encodeObject:self.huyaurl forKey:@"huyaurl"];
    [aCoder encodeObject:self.apiUrlArray forKey:@"apiUrlArray"];
    [aCoder encodeObject:self.apiUrlArrayqq forKey:@"apiUrlArrayqq"];
    [aCoder encodeObject:self.apiUrlArraymg forKey:@"apiUrlArraymg"];
    [aCoder encodeObject:self.apiUrlArrayaiqy forKey:@"apiUrlArrayaiqy"];
    [aCoder encodeObject:self.apiUrlArraysohu forKey:@"apiUrlArraysohu"];
    [aCoder encodeObject:self.morePanel forKey:@"morePanel"];
    [aCoder encodeObject:self.notConfig forKey:@"notConfig"];
    [aCoder encodeObject:self.homeItem forKey:@"homeItem"];
    [aCoder encodeObject:self.forceFireTime forKey:@"forceFireTime"];
    [aCoder encodeObject:self.tjLiance forKey:@"tjLiance"];
    [aCoder encodeObject:self.appJumpValue forKey:@"appJumpValue"];
    [aCoder encodeObject:self.professional forKey:@"professional"];
    [aCoder encodeObject:self.manhuaParseInfo forKey:@"manhuaParseInfo"];
    [aCoder encodeObject:self.webDataLiveInfo forKey:@"webDataLiveInfo"];
    [aCoder encodeObject:self.zyMkArray forKey:@"zyMkArray"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"morePanel" : [morePanelInfo class],@"notConfig":[notConfig class],@"homeItem":[homeFristItem class],@"forceFireTime":[forceFireTime class],@"professional":[newProfessional class],@"apiUrlArray":[searchWebInfo class],@"apiUrlArrayqq":[searchWebInfo class],@"apiUrlArraymg":[searchWebInfo class],@"apiUrlArrayaiqy":[searchWebInfo class],@"apiUrlArraysohu":[searchWebInfo class],@"huyaurl":[huyaNodeInfo class],@"manhuaurl":[manhuaurlInfo class],@"leaguer":[SpuerLeaguer class],@"webDataLiveInfo":[webDataLiveInfo class],@"zyMkArray":[ZyMkInfo class],@"tjLiance":[TjLiance class],@"homeADshow":[HomeAdShow class],@"wxBtnInfo":[WeiXinBtnInfo class]};
}
@end


@implementation morePanelInfo

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.des = [aDecoder decodeObjectForKey:@"des"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.beginTime forKey:@"beginTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
}
@end

@implementation arraySort

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.arraySort = [aDecoder decodeObjectForKey:@"arraySort"];
        self.forceOpenThird = [aDecoder decodeObjectForKey:@"forceOpenThird"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.arraySort forKey:@"arraySort"];
    [aCoder encodeObject:self.forceOpenThird forKey:@"forceOpenThird"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"arraySort" : [onePanel class]};
}
@end

@implementation onePanel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.headerName = [aDecoder decodeObjectForKey:@"headerName"];
        self.iconurl = [aDecoder decodeObjectForKey:@"iconurl"];
        self.array = [aDecoder decodeObjectForKey:@"array"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.headerName forKey:@"headerName"];
    [aCoder encodeObject:self.iconurl forKey:@"iconurl"];
    [aCoder encodeObject:self.array forKey:@"array"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"array" : [WebConfigItem class]};
}
@end


@implementation WebConfigItem
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.btnIconUrl = [aDecoder decodeObjectForKey:@"btnIconUrl"];
        self.rule = [aDecoder decodeObjectForKey:@"rule"];
        self.isAuToPlay = [aDecoder decodeBoolForKey:@"isAuToPlay"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.isUseApi = [aDecoder decodeBoolForKey:@"isUseApi"];
        self.beginTime = [aDecoder decodeObjectForKey:@"beginTime"];
        self.isNoPcWeb = [aDecoder decodeBoolForKey:@"isNoPcWeb"];
        self.isGoToWebVideoUrl = [aDecoder decodeBoolForKey:@"isGoToWebVideoUrl"];
        self.isDelAdsJs = [aDecoder decodeBoolForKey:@"isDelAdsJs"];
        self.isCustom = [aDecoder decodeBoolForKey:@"isCustom"];
        self.viewlist = [aDecoder decodeBoolForKey:@"viewlist"];
        self.isVip = [aDecoder decodeBoolForKey:@"isVip"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        self.isAlwaysAds = [aDecoder decodeBoolForKey:@"isAlwaysAds"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.isAlwaysAds forKey:@"isAlwaysAds"];
    [aCoder encodeBool:self.isAuToPlay forKey:@"isAuToPlay"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.btnIconUrl forKey:@"btnIconUrl"];
    [aCoder encodeObject:self.rule forKey:@"rule"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeBool:self.isUseApi forKey:@"isUseApi"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeBool:self.isNoPcWeb forKey:@"isNoPcWeb"];
    [aCoder encodeBool:self.isGoToWebVideoUrl forKey:@"isGoToWebVideoUrl"];
    [aCoder encodeBool:self.isDelAdsJs forKey:@"isDelAdsJs"];
    [aCoder encodeBool:self.isCustom forKey:@"isCustom"];
    [aCoder encodeBool:self.viewlist forKey:@"viewlist"];
    [aCoder encodeBool:self.isVip forKey:@"isVip"];
    [aCoder encodeObject:self.beginTime forKey:@"beginTime"];
}
@end

