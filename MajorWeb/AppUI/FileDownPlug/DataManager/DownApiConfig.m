//
//  DownApiConfig.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/7.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "DownApiConfig.h"

@implementation DownApiConfig

+(DownApiConfig*)apiConfig{
    static DownApiConfig*g = NULL;
    if (!g) {
        g = [[DownApiConfig alloc] init];
    }
    return g;
}
-(id)init{
    self = [super init];
    self.msgapp1= @"postMsgFromApp";
    self.msgapp2= @"postMsg2AFromApp";
    self.msgapp3 = @"HuanCunCtrl";
    self.msgapp3Notifi = @"ClickBack";
    self.msgappOverall = @"PostWtNotifi";
    self.msgappf0 = [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2", nil];
    self.msgappf1 = [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"autoExcte",@"param3", nil];
    self.msgappf2 = [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"getStateFromUser:",@"param3",nil];
    self.msgappf3 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"addStateNode:param1:param2:param3:",@"param3", nil];
    self.msgappf4 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"getAllStateKeyArray",@"param3", nil];
    self.msgappf5 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"isNodeInArray:",@"param3", nil];
    self.msgappf6 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"clearAllState",@"param3", nil];
    self.msgappf7 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"addStateFromUser:param2:coutmUUID:",@"param3", nil];
    self.msgappf8 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"setStateFromUser:",@"param3", nil];
    self.msgappf9 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"clearStateFromUser:",@"param3", nil];
    self.msgappf10 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"getAllStateInfo",@"param3", nil];
    self.msgappf11 =  [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"delStateFromUser:",@"param3", nil];
    self.msgappf12 =  [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"isZNodeInQueque:",@"param3", nil];
    self.msgappf13 =  [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"getNodeKeyArray",@"param3", nil];
    self.msgappf14 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"getNodeArray",@"param3", nil];
    self.msgappf15 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"deletZNodeUUID:",@"param3", nil];
    self.msgappf16 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"isNodeInArray:",@"param3", nil];
    self.msgappf17 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"startZNode:",@"param3", nil];
    self.msgappf18 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"fixbugSetUUIDNIL",@"param3", nil];
    self.msgappf19 = [NSDictionary dictionaryWithObjectsAndKeys:@"M3u8ArEngine",@"param1",@"getInstance",@"param2",@"getUUIDNotChangeStateString:",@"param3", nil];
    self.msgappf20 = [NSDictionary dictionaryWithObjectsAndKeys:@"M3u8ArEngine",@"param1",@"getInstance",@"param2",@"getUUIDStateString:",@"param3", nil];
    self.msgappf21 = [NSDictionary dictionaryWithObjectsAndKeys:@"M3u8ArEngine",@"param1",@"getInstance",@"param2",@"isCanSetState:",@"param3", nil];
    self.msgappf22 = [NSDictionary dictionaryWithObjectsAndKeys:@"M3u8ArEngine",@"param1",@"getInstance",@"param2",@"delNewStateNode:",@"param3", nil];
    self.msgappf23 = [NSDictionary dictionaryWithObjectsAndKeys:@"AloneStateEngine",@"param1",@"getInstance",@"param2",@"isCanSetState:",@"param3", nil];
       self.msgappf24 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"stopZNode:",@"param3", nil];
    //重下
    self.msgappf25 = [NSDictionary dictionaryWithObjectsAndKeys:@"M3u8ArEngine",@"param1",@"getInstance",@"param2",@"reDownload:",@"param3", nil];
    self.msgappf26 = [NSDictionary dictionaryWithObjectsAndKeys:@"AloneStateEngine",@"param1",@"getInstance",@"param2",@"reDownload:",@"param3", nil];
   self.msgappf27 = [NSDictionary dictionaryWithObjectsAndKeys:@"AppStateInfoManager",@"param1",@"getInstance",@"param2",@"reDownload:",@"param3", nil];
    self.msgappf28 = [NSDictionary dictionaryWithObjectsAndKeys:@"GuanliManager1",@"param1",@"getInstance",@"param2",@"reDownAlter:msg:",@"param3", nil];

    return self;
}
@end
