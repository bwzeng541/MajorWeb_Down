#import "ZFPlayerController.h"
typedef void (^ThrowAssetControllerClose)(void);
typedef void (^ThrowAssetControllerSmall)(void);
typedef void (^ThrowAssetControllerBackPlay)(void);
typedef void (^ThrowAssetControllerShare)(void);
typedef void (^ThrowAssetControllerVideoDown)(void);
typedef void (^ThrowAssetControllerLink)(void);

@interface ThrowAssetController : ZFPlayerController
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;
@property(copy)ThrowAssetControllerClose closePlay;
@property(copy)ThrowAssetControllerSmall smallPlay;
@property(copy)ThrowAssetControllerBackPlay backPlay;
@property(copy)ThrowAssetControllerShare sharePlay;
@property(copy)ThrowAssetControllerVideoDown videoDownPlay;
@property(copy)ThrowAssetControllerLink videoLink;

-(void)webPushLand;
@end
