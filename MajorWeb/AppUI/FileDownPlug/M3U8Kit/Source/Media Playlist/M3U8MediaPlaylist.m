//
//  M3U8MediaPlaylist.m
//  M3U8Kit
//
//  Created by Sun Jin on 3/26/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import "M3U8MediaPlaylist.h"
#import "NSString+m3u8.h"
#import "M3U8TagsAndAttributes.h"
#import "NSURL+easy.h"
#import "EXTM3U.h"
#import "FileDonwPlus.h"
#import "NSString+ZZExtension.h"
@interface M3U8MediaPlaylist()

@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSURL *originalURL;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) M3U8SegmentInfoList *segmentList;
@property (nonatomic,copy)NSString *m3u8Dir;
@property (nonatomic,assign)int serviceProt;
@property (nonatomic,copy)NSString *videoID;

@end

@implementation M3U8MediaPlaylist

- (instancetype)initWithContent:(NSString *)string type:(M3U8MediaPlaylistType)type baseURL:(NSURL *)baseURL localDir:(NSString*)m3u8Dir port:(int)servicePort videoID:(NSString*)videoID{
    if (NO == [string isMediaPlaylist]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.originalText = string;
        self.baseURL = baseURL;
        self.type = type;
        self.videoID = videoID;
        self.m3u8Dir = m3u8Dir;
        self.serviceProt = servicePort;
        [self parseMediaPlaylist];
    }
    return self;
}

- (instancetype)initWithContentOfURL:(NSURL *)URL type:(M3U8MediaPlaylistType)type localDir:(NSString*)m3u8Dir port:(int)servicePort videoID:(NSString*)videoID error:(NSError **)error {
    if (nil == URL) {
        return nil;
    }
    self.originalURL = URL;
    
    NSString *string = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
    
    return [self initWithContent:string type:type baseURL:URL.realBaseURL localDir:m3u8Dir port:servicePort videoID:videoID];
}

- (NSArray *)allSegmentURLs {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.segmentList.count; i ++) {
        M3U8SegmentInfo *info = [self.segmentList segmentInfoAtIndex:i];
        if (info.mediaURL.absoluteString.length > 0) {
            if (NO == [array containsObject:info.mediaURL]) {
                [array addObject:info.mediaURL];
            }
        }
    }
    return [array copy];
}

- (void)parseMediaPlaylist {
    
    self.segmentList = [[M3U8SegmentInfoList alloc] init];
    
    NSRange segmentRange = [self.originalText rangeOfString:M3U8_EXTINF];
    NSString *remainingSegments = self.originalText;
    
    EXTM3U *variant = [[EXTM3U alloc] initWithString:remainingSegments localDir:self.m3u8Dir videoID:self.videoID port:self.serviceProt ];
    NSMutableString *strLocal = [NSMutableString stringWithCapacity:2048];
    NSMutableArray  *arryCacheUrl = [NSMutableArray arrayWithCapacity:1000];
    if (variant && !variant.isMaster)
    {
        [strLocal appendFormat:@"#EXTM3U\n#EXT-X-VERSION:%d\n#EXT-X-MEDIA-SEQUENCE:%d\n",variant.version.version,variant.mediaSequence.number];
        if (variant.key && (variant.key.Method == AES128) && variant.key.URI) {
            [strLocal appendString:@"#EXT-X-KEY:METHOD=AES-128,URI="];
            NSString *strLocalKeyPath = [NSString stringWithFormat:@"\"http://localhost:%d/%@/%@/%@\"",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,self.videoID, @"main.key"];
            [strLocal appendString:strLocalKeyPath];
            if (variant.key.IV) {
                [strLocal appendFormat:@",IV=%@\n",variant.key.IV];
            }
            else{
                [strLocal appendString:@"\n"];
            }
            
            NSString *url = [self meadiUrl:variant.key.URI];
            NSString *local = [NSString stringWithFormat:@"%@/%@/%@",M3U8DOWNROOTPATH,self.videoID,@"main.key"];
            [arryCacheUrl addObject:@{M3U8_Url_Key:url,M3U8_Local_Key:local}];
        }
        // Let's try and change the key so it points to a local server
        // Let's try and change the media file urls to absolute server urls
        for (int i = 0;i<variant.media.count;i++)
        {
            EXTINF *info = [variant.media objectAtIndex:i];
            if (info.key && (info.key.Method == AES128) && info.key.URI) {
                [strLocal appendString:@"#EXT-X-KEY:METHOD=AES-128,URI="];
                NSString *strLocalKeyPath = [NSString stringWithFormat:@"\"http://localhost:%d/%@/%@/%@.key\"",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,self.videoID,[NSString stringWithFormat:@"%d",i+1]];
                [strLocal appendString:strLocalKeyPath];
                if (variant.key.IV) {
                    [strLocal appendFormat:@",IV=%@\n",variant.key.IV];
                }
                else{
                    [strLocal appendString:@"\n"];
                }
                NSString *url = [self meadiUrl:info.key.URI];
                NSString *local = [NSString stringWithFormat:@"%@/%@/%d.key",M3U8DOWNROOTPATH,self.videoID,i+1];
                [arryCacheUrl addObject:@{M3U8_Url_Key:url,M3U8_Local_Key:local}];
            }
            NSString *strLocalfilePath = [NSString stringWithFormat:@"http://localhost:%d/%@/%@/%d%@",LOCAHOSET_SERVICE_PORT,M3U8_DIR_NAME,self.videoID, i+1,@".ts"];
            [strLocal appendFormat:@"#EXTINF:%f,\n%@\n",info.duration,strLocalfilePath];

            NSString *url = [self meadiUrl:info.title];
            NSString *local = [NSString stringWithFormat:@"%@/%@/%d%@",M3U8DOWNROOTPATH,self.videoID,i+1,@".ts"];
            [arryCacheUrl addObject:@{M3U8_Url_Key:url,M3U8_Local_Key:local}];
        }
        [strLocal appendString:@"#EXT-X-ENDLIST"];
    }
    self.localText = strLocal;
    self.cacheArray = [NSArray arrayWithArray:arryCacheUrl];
}

-(NSString*)meadiUrl:(NSString*)str{
    NSCharacterSet *setString = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
    　str = [str stringByTrimmingCharactersInSet:setString];
    NSURL *url = [NSURL URLWithString:str];
    if (url.scheme) {
        return str;
    }
    return [[NSURL URLWithString:url.absoluteString relativeToURL:[self baseURL]] absoluteString];
}
@end
