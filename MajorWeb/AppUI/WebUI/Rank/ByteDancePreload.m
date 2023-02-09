
#import "ByteDancePreload.h"
#import <AdSupport/AdSupport.h>
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "VipPayPlus.h"
@interface ByteDancePreload()<BURewardedVideoAdDelegate>
@property(copy,nonatomic)void(^successVideoAdBlock)(id adObject);
@property(strong,nonatomic)BURewardedVideoAd *rewardedVideoAd;
@property(strong,nonatomic)NSTimer *checkChangeTimer;
@property(assign,nonatomic)BOOL isCanSetPlus;
@end

@implementation ByteDancePreload
-(void)dealloc{
#ifdef DEBUG
    printf("%s\n",__FUNCTION__);
#endif
}
-(void)start:(void (^)(id _Nonnull))successVideoAdBlock{
    if (!self.rewardedVideoAd && [VipPayPlus getInstance].systemConfig.vip!=Recharge_User) {
        self.successVideoAdBlock = successVideoAdBlock;
        self.isCanSetPlus  =true;
        [self loadAdReqeust];
    }
}

-(void)loadAdReqeust{
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *adID = @"910645640";
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:adID rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

-(void)stop{
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
    if (self.rewardedVideoAd) {
         self.rewardedVideoAd.delegate = NULL;
        self.rewardedVideoAd = NULL;
        self.isCanSetPlus  = false;
    }
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    #ifdef DEBUG
    NSLog(@"VideoPreLoad Success");
    #endif
    if (self.successVideoAdBlock && self.isCanSetPlus) {
        self.successVideoAdBlock(self.rewardedVideoAd);
    }
    self.rewardedVideoAd.delegate = NULL;
    self.rewardedVideoAd = NULL;
    [self.checkChangeTimer invalidate];
    self.checkChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1200 target:self selector:@selector(changeAdVideo) userInfo:nil repeats:YES];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    [self.checkChangeTimer invalidate];self.checkChangeTimer = nil;
    self.checkChangeTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(changeAdVideo) userInfo:nil repeats:YES];
 }

-(void)changeAdVideo
{
    if (self.isCanSetPlus) {
        self.rewardedVideoAd.delegate = NULL;
        self.rewardedVideoAd = NULL;
        [self loadAdReqeust];
    }
}

@end
