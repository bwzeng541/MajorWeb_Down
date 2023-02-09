#import "BeatifyAssetSetView.h"
#import "BeatifyAssetSetCtrl.h"
static BeatifyAssetSetView *assetSetView = nil;
static BeatifyAssetSetCtrl *assetSetCtrl = nil;

@interface BeatifyAssetSetView ()<BeatifyAssetSetCtrlDelagate>
@end

@implementation BeatifyAssetSetView

-(void)removeFromSuperview{
    assetSetView = nil;
    assetSetCtrl = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super removeFromSuperview];
}

+(void)showAssetView:(ZFPlayerController*)player{
    if (!assetSetView) {
        float w = MY_SCREEN_WIDTH>MY_SCREEN_HEIGHT?MY_SCREEN_WIDTH:MY_SCREEN_HEIGHT;
        float h = MY_SCREEN_WIDTH<MY_SCREEN_HEIGHT?MY_SCREEN_WIDTH:MY_SCREEN_HEIGHT;
        assetSetView = [[BeatifyAssetSetView alloc] initWithFrame:CGRectMake(0, 0,w , h) player:player];
        [player.currentPlayerManager.view addSubview:assetSetView];
    }
}

+(void)hiddeAssetView{
    RemoveViewAndSetNil(assetSetView);
}

-(BOOL)isClickValid{
    return true;
}

-(id)initWithFrame:(CGRect)frame player:(ZFPlayerController*)player{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0 green:0  blue:0 alpha:0.5];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [btn addTarget:self action:@selector(closeSetView:) forControlEvents:UIControlEventTouchUpInside];
    assetSetCtrl = [[BeatifyAssetSetCtrl alloc] initWithNibName:@"BeatifyAssetSetCtrl" bundle:NULL player:player.currentPlayerManager];
    assetSetCtrl.delegate = self;
    assetSetCtrl.player = player;
    [self addSubview:assetSetCtrl.view];
    [assetSetCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(assetSetCtrl.view.bounds.size.width);
        make.height.mas_equalTo(assetSetCtrl.view.bounds.size.height);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}

-(void)didEnterBackground{
    [BeatifyAssetSetView hiddeAssetView];
}

-(void)closeSetView:(UIButton*)sender{
    [BeatifyAssetSetView hiddeAssetView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
