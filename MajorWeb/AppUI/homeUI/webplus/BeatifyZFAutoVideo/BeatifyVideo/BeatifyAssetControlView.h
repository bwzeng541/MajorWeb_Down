
#import <UIKit/UIKit.h>
#import "ZFPlayerControlView.h"


@interface BeatifyAssetControlView : ZFPlayerControlView <ZFPlayerMediaControl>

- (void)removeFixBtn;

- (void)cancelAllPerformSelector;

- (void)sharePlay;

- (void)throwHiddenCallBack:(BOOL)withAnimated;

- (void)reSetTopCtrlView;

- (void)resetControlView;

- (void)hideFixCtrl;

- (void)showCoverViewWithUrl:(NSString *)coverUrl;

- (void)addShareBtn;
@end
