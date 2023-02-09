//
//  IJKMediaFrameworkWithSSL.h
//  IJKMediaFrameworkWithSSL
//
//  Created by zhangxinzheng on 27/02/2017.
//  Copyright © 2017 bilibili. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for IJKMediaFrameworkWithSSL.
FOUNDATION_EXPORT double IJKMediaFrameworkWithSSLVersionNumber;

//! Project version string for IJKMediaFrameworkWithSSL.
FOUNDATION_EXPORT const unsigned char IJKMediaFrameworkWithSSLVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <IJKMediaFrameworkWithSSL/PublicHeader.h>

#import <IJKMediaFrameworkWithSSL/IJKMediaPlayback.h>
#import <IJKMediaFrameworkWithSSL/IJKMPMoviePlayerController.h>
#import <IJKMediaFrameworkWithSSL/IJKFFOptions.h>
#import <IJKMediaFrameworkWithSSL/IJKFFMoviePlayerController.h>
#import <IJKMediaFrameworkWithSSL/IJKAVMoviePlayerController.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaModule.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaPlayer.h>
#import <IJKMediaFrameworkWithSSL/IJKNotificationManager.h>
#import <IJKMediaFrameworkWithSSL/IJKKVOController.h>
#import <IJKMediaFrameworkWithSSL/IJKFFMpeg.h>
#import <IJKMediaFrameworkWithSSL/FFmpegCmd.h>
#define IJK_FFMPEG_CMD_START_Notification  jik_ffmpeg_cmd_start_notifi
#define IJK_FFMPEG_CMD_STOP_Notification   jik_ffmpeg_cmd_stop_notifi
#define IJK_FFMPEG_CMD_PROGRESS_Notification   jik_ffmpeg_cmd_progress_notifi
#define IJK_FFMPEG_CMD_GETINFO_Notification   jik_ffmpeg_cmd_getInfo_notifi
#define IJK_FFMPEG_CMD_CONCANTINFO_Notification   jik_ffmpeg_cmd_concantinfo_notifi
#define IJK_FFMPEG_CMD_GETHLSINFO_Notification   jik_ffmpeg_cmd_gethlsinfo_notifi


//hls信息需要的key字段
#define IJK_HLS_VIDEO_URL_KEY  hls_video_url_url//url
#define IJK_HLS_VIDEO_DES_KEY_TYPE_KEY hls_video_des_key_type//加密类型
#define IJK_HLS_VIDEO_DES_KEY_KEY hls_video_des_key//加密密钥
#define IJK_HLS_VIDEO_DES_VI_KEY hls_video_des_vi//加密vi值
#define IJK_HLS_VIDEO_DES_STARTTIME_KEY hls_video_des_startTime//开始时间
#define IJK_HLS_VIDEO_DES_DURATION_KEY hls_video_des_duration//播放时间
#define IJK_HLS_VIDEO_DES_PREVIOUS_DURATION hls_video_des_previous_duration;//
// backward compatible for old names
#define IJKMediaPlaybackIsPreparedToPlayDidChangeNotification IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
#define IJKMoviePlayerLoadStateDidChangeNotification IJKMPMoviePlayerLoadStateDidChangeNotification
#define IJKMoviePlayerPlaybackDidFinishNotification IJKMPMoviePlayerPlaybackDidFinishNotification
#define IJKMoviePlayerPlaybackDidFinishReasonUserInfoKey IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey
#define IJKMoviePlayerPlaybackStateDidChangeNotification IJKMPMoviePlayerPlaybackStateDidChangeNotification
#define IJKMoviePlayerIsAirPlayVideoActiveDidChangeNotification IJKMPMoviePlayerIsAirPlayVideoActiveDidChangeNotification
#define IJKMoviePlayerVideoDecoderOpenNotification IJKMPMoviePlayerVideoDecoderOpenNotification
#define IJKMoviePlayerFirstVideoFrameRenderedNotification IJKMPMoviePlayerFirstVideoFrameRenderedNotification
#define IJKMoviePlayerFirstAudioFrameRenderedNotification IJKMPMoviePlayerFirstAudioFrameRenderedNotification
#define IJKMoviePlayerFirstAudioFrameDecodedNotification IJKMPMoviePlayerFirstAudioFrameDecodedNotification
#define IJKMoviePlayerFirstVideoFrameDecodedNotification IJKMPMoviePlayerFirstVideoFrameDecodedNotification
#define IJKMoviePlayerOpenInputNotification IJKMPMoviePlayerOpenInputNotification
#define IJKMoviePlayerFindStreamInfoNotification IJKMPMoviePlayerFindStreamInfoNotification
#define IJKMoviePlayerComponentOpenNotification IJKMPMoviePlayerComponentOpenNotification
#define IJKMPMoviePlayerAccurateSeekCompleteNotification IJKMPMoviePlayerAccurateSeekCompleteNotification
#define IJKMoviePlayerSeekAudioStartNotification IJKMPMoviePlayerSeekAudioStartNotification
#define IJKMoviePlayerSeekVideoStartNotification IJKMPMoviePlayerSeekVideoStartNotification
