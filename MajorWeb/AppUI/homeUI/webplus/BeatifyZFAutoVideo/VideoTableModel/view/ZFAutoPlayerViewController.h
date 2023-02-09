

#import <UIKit/UIKit.h>

@protocol ZFAutoPlayerViewControllerDelegate <NSObject>
-(void)zfautoPlayerWillRemove:(UIImage*)image;
@end
@interface ZFAutoPlayerViewController : UIViewController
+(BOOL)isFull;
+(BOOL)isInitUI;
+(void)showAdVideoAndExitFull;
+(void)exitAdVideoAndEnterFull;
+(void)updatePlayAlpha:(float)alpha;
+(void)tryToPause;
+(void)tryToPlay;
@property(weak)id<ZFAutoPlayerViewControllerDelegate>delegate;
-(instancetype)init;
-(void)initUI;
-(void)unInit;
-(void)didEnterForeground;
@end
