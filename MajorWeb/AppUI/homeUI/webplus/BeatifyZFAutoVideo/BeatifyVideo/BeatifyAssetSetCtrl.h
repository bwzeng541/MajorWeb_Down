#import <UIKit/UIKit.h>
#import "ZFPlayerMediaPlayback.h"
NS_ASSUME_NONNULL_BEGIN
@class ZFPlayerController;
@protocol   BeatifyAssetSetCtrlDelagate
-(BOOL)isClickValid;
@end
@interface BeatifyAssetSetCtrl : UIViewController
@property(weak,nonatomic)id<BeatifyAssetSetCtrlDelagate>delegate;
@property(weak,nonatomic)ZFPlayerController *player;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil player:(id<ZFPlayerMediaPlayback>)player;
-(IBAction)pressFullMain:(id)sender;
-(IBAction)press100Main:(id)sender;
-(IBAction)press75Main:(id)sender;
-(IBAction)press50Main:(id)sender;
-(IBAction)pressSpeen0_75:(id)sender;
-(IBAction)pressSpeen1_0:(id)sender;
-(IBAction)pressSpeen1_25:(id)sender;
-(IBAction)pressSpeen1_5:(id)sender;
-(IBAction)pressSpeen2_0:(id)sender;
@end

NS_ASSUME_NONNULL_END
