//
//  M3U8MediaPlaylist.h
//  M3U8Kit
//
//  Created by Sun Jin on 3/26/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentInfoList.h"

typedef enum {
    M3U8MediaPlaylistTypeMedia = 0,     // The main media stream playlist.
    M3U8MediaPlaylistTypeSubtitle = 1,  // EXT-X-SUBTITLES TYPE=SUBTITLES
    M3U8MediaPlaylistTypeAudio = 2,     // EXT-X-MEDIA TYPE=AUDIO
    M3U8MediaPlaylistTypeVideo = 3      // EXT-X-MEDIA TYPE=VIDEO
} M3U8MediaPlaylistType;

@interface M3U8MediaPlaylist : NSObject

@property (nonatomic, strong) NSString *name;

@property (readonly, nonatomic, strong) NSString *version;

@property (readonly, nonatomic, copy) NSString *originalText;
@property (readonly, nonatomic, copy) NSURL *baseURL;

@property (readonly, nonatomic, copy) NSURL *originalURL;

//本地播放需要的参数
@property (nonatomic,copy) NSString *localText;
@property (nonatomic,retain)NSArray *cacheArray;

//end
@property (readonly, nonatomic, strong) M3U8SegmentInfoList *segmentList;

@property (nonatomic) M3U8MediaPlaylistType type;   // -1 by default

- (instancetype)initWithContent:(NSString *)string type:(M3U8MediaPlaylistType)type baseURL:(NSURL *)baseURL localDir:(NSString*)m3u8Dir port:(int)servicePort videoID:(NSString*)videoID;
- (instancetype)initWithContentOfURL:(NSURL *)URL type:(M3U8MediaPlaylistType)type localDir:(NSString*)m3u8Dir port:(int)servicePort videoID:(NSString*)videoID error:(NSError **)error;

- (NSArray *)allSegmentURLs;

@end
