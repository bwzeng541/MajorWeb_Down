//
//  IJKMsgDef.h
//  IJKMediaPlayer
//
//  Created by zengbiwang on 2017/12/18.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#ifndef IJKMsgDef_h
#define IJKMsgDef_h
#import <Foundation/Foundation.h>


#ifdef __cplusplus
#define IJK_FFMPEG_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define IJK_FFMPEG_EXTERN extern __attribute__((visibility ("default")))
#endif
IJK_FFMPEG_EXTERN NSString *const jik_ffmpeg_cmd_start_notifi;
IJK_FFMPEG_EXTERN NSString *const jik_ffmpeg_cmd_stop_notifi;
IJK_FFMPEG_EXTERN NSString *const jik_ffmpeg_cmd_progress_notifi;
IJK_FFMPEG_EXTERN NSString *const jik_ffmpeg_cmd_getInfo_notifi;
IJK_FFMPEG_EXTERN NSString *const jik_ffmpeg_cmd_concantinfo_notifi;
IJK_FFMPEG_EXTERN NSString *const jik_ffmpeg_cmd_gethlsinfo_notifi;
IJK_FFMPEG_EXTERN NSString *const hls_video_url_key;
IJK_FFMPEG_EXTERN NSString *const hls_video_des_key_type_key;
IJK_FFMPEG_EXTERN NSString *const hls_video_des_key_key;
IJK_FFMPEG_EXTERN NSString *const hls_video_des_vi_key;
IJK_FFMPEG_EXTERN NSString *const hls_video_des_startTime;
IJK_FFMPEG_EXTERN NSString *const hls_video_des_duration;
IJK_FFMPEG_EXTERN NSString *const hls_video_des_previous_duration;
IJK_FFMPEG_EXTERN NSString *const hls_video_Encryption_key_url;
enum KeyType {
    KEY_NONE,
    KEY_AES_128,
    KEY_SAMPLE_AES
};
//hls信息需要的key字段

#endif /* IJKMsgDef_h */
