//
//  QrVideoNodeView.h
//  QRTools
//
//  Created by bxing zeng on 2020/5/7.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PCUserAgent @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36"

NS_ASSUME_NONNULL_BEGIN
@protocol QrVideoNodeViewDelegate <NSObject>
-(void)selectQrVideoNode;
-(BOOL)reviceAndCheckIsVaild:(id)v object:(nonnull id)object isFaild:(BOOL)isFaild;
-(void)recviceQrVideoState:(id)v;
-(BOOL)recviceCheckNumber:(id)v;
-(BOOL)recviceAndCheckIsMutilFront;
-(void)recviceQrVideoStateFaild:(id)v object:(nonnull id)object;
@end
@interface QrVideoNodeView : UIView
@property (weak)id<QrVideoNodeViewDelegate>delegate;
@property (readonly, nonatomic)NSString *uuid;
@property (strong, nonatomic) IBOutlet UIView *describeView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *resolvLabel;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *webOrVideoView;
@property (strong, nonatomic) IBOutlet UIButton *btnQrScan;
@property (strong, nonatomic) IBOutlet UIButton *btnBigQrScan;
@property (strong, nonatomic) IBOutlet UILabel *desLabel;
#ifdef DEBUG
@property (readonly,nonatomic) NSString *reqeutUrl;
#endif
-(void)loadUrl:(NSString*)url title:(NSString*)title delay:(float)delay;
-(void)clearNodeAsset;
-(void)removeNotClear;
@end

NS_ASSUME_NONNULL_END
