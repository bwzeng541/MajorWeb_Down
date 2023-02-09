//
//  MajorPipeView.h
//  WatchApp
//
//  Created by zengbiwang on 2017/12/22.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
//url地址
#define ParsePipeTitle_Key @"ParsePipeTitle_Key"
#define ParsePipeUrl_Key @"ParsePipeUrl_Key"
#define ParsePipeHtml_Key @"ParsePipeHtml_Key"
//0表示不直接播放，1是视频地址
#define ParsePipeMedia_Key @"ParsePipeMedia_Key"
typedef void (^MajorPipeViewSelectBlock)(NSString*videoUrl,NSString*htmlUrl,int seletIndex, id playerInterface ,NSArray *videoUrlArray);
typedef void (^MajorPipeViewAllFaildBlock)();
typedef void (^MajorPipeViewCloseBlock)();
typedef void (^MajorPipeViewCloseAndReOpenBlock)(NSString*url);
typedef void (^MajorPipeViewRLoadBlock)();

@interface MajorPipeView : UIView
@property(readonly,nonatomic)UIView *collectionView;
@property(readonly,nonatomic)UIView *contentView;
@property(copy)MajorPipeViewSelectBlock selectBlock;
@property(copy)MajorPipeViewCloseBlock  closeBlock;
@property(copy)MajorPipeViewAllFaildBlock allFaildBlock;
@property(copy)MajorPipeViewRLoadBlock rLoadBlock;
@property(copy)MajorPipeViewCloseAndReOpenBlock closeReOpenBlock;

-(instancetype)initWithFrame:(CGRect)frame isFromSS:(BOOL)isFromSS arrayApi:(NSArray*)arrayApi url:(NSString*)url webVideoUrl:(NSString*)webVideoUrl searchTitle:(NSString*)searchTitle;

-(instancetype)initWithFrameWithFilmPlayer:(CGRect)frame isFromSS:(BOOL)isFromSS  url:(NSString*)url webVideoUrl:(NSString*)webVideoUrl arrayWebUrl:(NSArray*)array isAutoPlayer:(BOOL)isAutoPlayer searchTitle:(NSString*)searchTitle;

-(instancetype)initWithLiveFrame:(CGRect)frame webaArray:(NSArray*)webArray  url:(NSString*)url titleArray:(NSArray*)array searchTitle:(NSString*)searchTitle;

-(void)addExtrentBtn:(UIButton*)btn;
-(void)start:(NSString*)desMsg;
-(void)stop;
-(void)updateNotCreateThumbnail;
@end
