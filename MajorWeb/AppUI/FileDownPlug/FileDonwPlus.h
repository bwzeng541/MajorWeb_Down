
//
//  FileDonwPlus.h
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/15.
//  Copyright © 2018 cxh. All rights reserved.
//

//公共头文件
#ifndef FileDonwPlus_h
#define FileDonwPlus_h
#import "RecordUrlToUUID.h"

#define UnKnownDespc_fileDown @"未知错误,下载失败,请点“开始”从新下载,如果不能下载,请点,重新下载"
//最大并行下载数量
#define MaxDownParallelNumber 5

//是否并行下载
#define CanDownMutileFileOneTime 1
//是否需要合成一个单文件
#define TsFilesCanConCatMovFile 1

#define AsciiToString(x) [NSString stringWithCString:x encoding:NSUTF8StringEncoding]

#define GuanliNodeKey @"GuanliNodeKey"

#define GuanliNameKey @"GuanliNameKey"
#define GuanliNode2Key @"GuanliNode2Key"
#define GuanliUUIDNodeKey @"GuanliUUIDNodeKey"
#define state1_info_key @"state1_info_key"
#define state2_info_key @"state2_info_key"
#define state3_info_key @"state3_info_key"
#define state4_info_key @"state4_info_key"
#define state5_info_key @"state5_info_key"
#define state6_info_key @"state6_info_key"
#define state7_info_key @"state7_info_key"
#define StateUUIDKEY @"StateUUIDKEY"

#define VIDEOCACHESROOTPATH [NSString stringWithFormat:@"%@/VideoDownCaches",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]]

//单文件宏

#define ALONECAHESDOWNITMEINFOSAVEPATH [NSString stringWithFormat:@"%@/downAlone_Cache.info",VIDEOCACHESROOTPATH]

#define ALONEDOWNITMEINFOSAVEPATH [NSString stringWithFormat:@"%@/downAlone.info",VIDEOCACHESROOTPATH]

#define ALONE_DIR_NAME @"aloneVideoPath"

#define ALONESERVICEROOTPATH [NSString stringWithFormat:@"%@/alone",VIDEOCACHESROOTPATH]

#define ALONEDOWNROOTPATH [NSString stringWithFormat:@"%@/alone/%@",VIDEOCACHESROOTPATH,ALONE_DIR_NAME]



//通知ui -- notifit

#define ALONE_FILE_URL   @"ALONE_FILE_URL"
#define ALONE_DOWN_FINIHES @"ALONE_DOWN_FINIHES"
#define ALONE_ALLDOWN_URL @"ALONE_ALLDOWN_URL"
#define ALONE_VIDEOPATH  @"ALONE_VIDEOPATH"
#define ALONE_LOCAL_ALONEFILE @"ALONE_LOCAL_ALONEFILE"
#define ALONE_VIDEO_SHOW_NAME @"ALONE_VIDEO_SHOW_NAME"

#define ALONEVIEWSTATECHANGE  @"ALONEVIEWSTATECHANGE"

typedef enum {
    alone_down_unknow,
    alone_Waiting_down,
    alone_Start_down,
    alone_downing,
    alone_del,
    alone_down_finishes,
    alone_down_error,
}aloneDownSate;


//多文件头
#define M3U8CAHESDOWNITMEINFOSAVEPATH [NSString stringWithFormat:@"%@/downM3u8_Cache.info",VIDEOCACHESROOTPATH]

#define M3U8DOWNITMEINFOSAVEPATH [NSString stringWithFormat:@"%@/downM3u8.info",VIDEOCACHESROOTPATH]

#define M3U8_Url_Key @"m3u8_url_key"
#define M3U8_Local_Key @"m3u8_local_key"
#define M3U8_StartTime_Key @"m3u8_startTime_key"
#define M3U8_endTime_Key @"m3u8_endTime_key"
#define M3U8_PreviousTime_Key @"m3u8_PreviousTime_key"
#define M3U8_DurationTime_Key @"m3u8_DurationTime_key"
#define M3U8_Cipher_Key @"m3u8_Cipher_key"
#define M3U8_Cipher_vi_Key @"m3u8_Cipher_vi_key"
#define M3U8_Encryption_type_Key @"m3u8_Encryption_type_key"

#define M3U8_DIR_NAME @"videopath"
//http工作目录

#define HTTPSERVICEROOTPATH [NSString stringWithFormat:@"%@/Web",VIDEOCACHESROOTPATH]
//  路径格式http://localhost:41345/videopath/156630/1.ts  //156630是唯一id
#define M3U8DOWNROOTPATH [NSString stringWithFormat:@"%@/Web/%@",VIDEOCACHESROOTPATH,M3U8_DIR_NAME]

#define M3U8_DOWNITEM_TAG  @"M3U8_DOWNITEM_TAG"
#define M3U8_DICITEM_TAG   @"M3U8_DICITEM_TAG"


#define M3U8_FILE_URL   @"M3U8_FILE_URL"
#define M3U8_DOWN_FINIHES @"M3U8_DOWN_FINIHES"
#define M3U8_ALLDOWN_URL @"M3U8_ALLDOWN_URL"
#define M3U8_VIDEOPATH  @"M3U8_VIDEOPATH"
#define M3U8_LOCAL_M3U8FILE @"M3U8_LOCAL_M3U8FILE"
#define M3U8_VIDEO_FILE_NAME @"M3U8_VIDEO_FILE_NAME"


#define FINISHES_M3U8_ITEM_DOWN @"finishesM3u8Down"


//通知ui -- notifit
#define UPPROGROESSM3U8  @"upProgroessM3u8"
#define DOWNFINISHESM3U8 @"downFinishesM3u8"
#define DOWNFAILDM3U8    @"downFaildM3u8"
#define DOWNSTARTM3U8    @"downStartM3u8"
#define DOWNPREINGM3U8   @"downPreingM3u8"
#define DOWNPAUSEM3U8   @"downPauseM3u8"

#define M3U8VIEWSTATECHANGE  @"M3U8VIEWSTATECHANGE"

typedef enum {
    m3u8_down_unknow,
    m3u8_Waiting_down,
    m3u8_Start_down,
    m3u8_downing,
    m3u8_del,
    m3u8_down_finishes,
    m3u8_down_error,
}m3u8DownSate;


/*
 M3U8DOWNITMEINFOSAVEPATH 下载数据项结构如下
 字典结构:dicDownItem ,键值为唯一id
 
 value == 字典结构
 allDownURl->nsarray->downUrl|saveName;
 videoPath ->nsstring(m3u8视频id):保存路径:M3U8DOWNROOTPATH/vodeoPath/id/saveName
 loaclM3u8File ：本地播放需要的m3u8名字:->保存路径M3U8DOWNROOTPATH/vodeoPath/id.m3u8文件
 
 
 */
#endif /* FileDonwPlus_h */
