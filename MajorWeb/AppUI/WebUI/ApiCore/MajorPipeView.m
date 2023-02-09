//
//  MajorPipeView.m
//  WatchApp
//
//  Created by zengbiwang on 2017/12/22.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "MajorPipeView.h"
#import "MajorPreview.h"
#import "AppDelegate.h"
#import "SearchWebView.h"
#import "MajorModeDefine.h"
#import "GDTUnifiedBannerView.h"
#import "VipPayPlus.h"
#import "NSObject+UISegment.h"
@interface MajorPipeView()<GDTUnifiedBannerViewDelegate,MajorPreviewDelegate,UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>{
    float cellW,cellH;
    UICollectionView *_collectionView;
    SearchWebView    *_searchWebView;
    int totalTime;
    int currentTime;
    
    UILabel *topDesLabel;
    UILabel *numberLabel;
    UILabel *desDesLabel;
    
    NSInteger successIndex;
    UIView *btnsView;
    UIButton *btn3,*btn5,*btn7,*btn10;
    NSInteger msgIndex;
    float startPos;
    float labelheight;
    BOOL  isUpdateMsg;
    BOOL isFirstAudio;
}
@property (nonatomic, strong) UIView *customview;
@property (nonatomic, strong) UIImageView *imageView;
@property(nonatomic,strong)GDTUnifiedBannerView *carouselBannerView ;
@property(nonatomic,weak)MajorPreview* shortPreViewView;
@property(strong)id tmpPlayerInterface;
@property(strong)UIView *msgView;
@property(strong)NSArray *msgArray;
@property(assign)BOOL isAutoPlayer;
@property(assign)BOOL isFromSS;
@property(strong)UIScrollView *scrollView;
@property(copy)NSArray *apiArray;
@property(strong)NSMutableArray *arrayPreView;
@property(copy)NSString *url;
@property(strong)NSTimer *progressTimer;
@property(copy)NSString *webVideoUrl;
@property(strong)UIView *contentView;
@end
@implementation MajorPipeView
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    self.scrollView = nil;
    self.apiArray = nil;
    self.url = nil;
    self.arrayPreView = nil;
}

-(void)removeFromSuperview{
    [self.carouselBannerView removeFromSuperview];
    self.carouselBannerView = nil;
    [super removeFromSuperview];
}

- (UIButton*)createParamBtn:(SEL)action rect:(CGRect)rect title:(NSString*)title{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = rect;
    return btn;
}

-(CGRect)addBuBannerReturnRect{
//    if (true || [VipPayPlus getInstance].systemConfig.vip) {
//        return CGRectMake(0, MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20), 0, 0);
//    }
    CGSize viewSize = self.bounds.size;
    float startY = MY_SCREEN_HEIGHT-(GetAppDelegate.appStatusBarH-20);
    BOOL isLand = false;
    if (viewSize.width>viewSize.height) {
        startY = MY_SCREEN_WIDTH;
        isLand = true;
    }
    CGRect rect = CGRectMake(0, startY, 0, 0);
    CGFloat bannerHeight = CGRectGetWidth([UIScreen mainScreen].bounds)/375*60;
    CGRect rectContetView = self.contentView.frame;
    rect = CGRectMake((rectContetView.size.width-375)/2, startY-bannerHeight,375, bannerHeight);
    if (isLand) {
        if(IF_IPHONE)
        rect  = CGRectMake(viewSize.width-rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
        else{
            rect  = CGRectMake(viewSize.width-375, rect.origin.y,  375, rect.size.height);
        }
    }
    UIView* toolsView = [[UIView alloc] initWithFrame:rect];
    [self addSubview:toolsView];
    toolsView.backgroundColor = [UIColor blackColor];
    btnsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [toolsView addSubview:btnsView];
     btn3 = [self createParamBtn:@selector(pressParam:) rect:CGRectMake(0, 0, 0, 0) title:@"3"];
    btn3.tag = 3;
    btn5 = [self createParamBtn:@selector(pressParam:) rect:CGRectMake(0, 0, 0, 0) title:@"5"];
    btn5.tag = 5;
    btn7 = [self createParamBtn:@selector(pressParam:) rect:CGRectMake(0, 0, 0, 0) title:@"7"];
    btn7.tag = 7;
    btn10 = [self createParamBtn:@selector(pressParam:) rect:CGRectMake(0, 0, 0, 0) title:@"10"];
    btn10.tag = 10;
    [btnsView addSubview:btn3];
    [btnsView addSubview:btn5];
    [btnsView addSubview:btn7];
    [btnsView addSubview:btn10];
    CGSize btnSize = CGSizeMake(50, btnsView.bounds.size.height);
    [NSObject initii:btnsView contenSize:btnsView.bounds.size vi:btn3 viSize:btnSize vi2:nil index:0 count:4];
    [NSObject initii:btnsView contenSize:btnsView.bounds.size vi:btn5 viSize:btnSize vi2:btn3 index:1 count:4];
    [NSObject initii:btnsView contenSize:btnsView.bounds.size vi:btn7 viSize:btnSize vi2:btn5 index:2 count:4];
    [NSObject initii:btnsView contenSize:btnsView.bounds.size vi:btn10 viSize:btnSize vi2:btn7 index:3 count:4];
    [self updateBntsState];
    if (false &&
        !self.carouselBannerView && [VipPayPlus getInstance].systemConfig.vip != Recharge_User) {
        self.carouselBannerView = [[GDTUnifiedBannerView alloc]
                                   initWithFrame:rect appId:@"1109675609"
                                   placementId:@"8080589358776897"
                                   viewController:GetAppDelegate.window.rootViewController];
        _carouselBannerView.animated =  NO;
        _carouselBannerView.autoSwitchInterval = 30;
        _carouselBannerView.delegate = self;
        self.carouselBannerView.delegate = self;
        [self addSubview:self.carouselBannerView];
        [self.carouselBannerView loadAdAndShow];
    }
    return rect;
}

-(void)updateBntsState{
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn7 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn10 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIButton *btn = [btnsView viewWithTag:[self getSearchformWebPipeView]];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

-(void)pressParam:(UIButton*)sender{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sender.tag] forKey:@"search_form_web_PipeView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateBntsState];
    if (self.closeReOpenBlock){
        self.closeReOpenBlock(self.url);
    }
}

-(instancetype)initWithFrameWithFilmPlayer:(CGRect)frame isFromSS:(BOOL)isFromSS url:(NSString*)url webVideoUrl:(NSString*)webVideoUrl arrayWebUrl:(NSArray*)array isAutoPlayer:(BOOL)isAutoPlayer searchTitle:(NSString*)searchTitle
{
    self = [super initWithFrame:frame];
    self.backgroundColor  = [UIColor blackColor];
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.contentView];
    self.contentView.center = CGPointMake(self.bounds.size.width/2+self.bounds.size.width*0.18, self.contentView.center.y);
    isFirstAudio = true;
    self.apiArray = array;
    self.url = url;
    self.webVideoUrl = webVideoUrl;
    self.isFromSS = isFromSS;
    self.isAutoPlayer = isAutoPlayer;
    self.arrayPreView = [NSMutableArray arrayWithCapacity:1];
    [self initSearchUI:frame searchTitle:searchTitle];
    
    if (self.apiArray.count>0 && self.isFromSS) {
        //        NSDictionary *info = [self.apiArray objectAtIndex:0];
        //        MajorPreview *view = [[MajorPreview alloc]initWithUrl:[info objectForKey:ParsePipeUrl_Key] frame:CGRectMake(0, 0, cellW, cellH) isShowWeb:self.isFromSS index:0 isAddWebVideo:true isAutoPlayer:false isMedia:[[info objectForKey:ParsePipeMedia_Key]boolValue]];
        //        view.delegate = self;
        //        [self.arrayPreView addObject:view];
    }
    for (int i = 0; i < self.apiArray.count; i++) {
        NSDictionary *info = [self.apiArray objectAtIndex:i];
        MajorPreview *view = [[MajorPreview alloc]initWithUrl:[info objectForKey:ParsePipeUrl_Key] html:[info objectForKey:ParsePipeHtml_Key] frame:CGRectMake(0, 0, cellW, cellH) isShowWeb:self.isFromSS index:i isAddWebVideo:false isAutoPlayer:self.isAutoPlayer isMedia:[[info objectForKey:ParsePipeMedia_Key]boolValue] showTitle:[info objectForKey:ParsePipeTitle_Key]];
        view.delegate = self;
        view.tag = i;
        [self.arrayPreView addObject:view];
    }
    if (self.webVideoUrl) {
        MajorPreview *view = [[MajorPreview alloc]initWithUrl:self.webVideoUrl html:nil frame:CGRectMake(0, 0, cellW, cellH) isShowWeb:self.isFromSS index:self.arrayPreView.count isAddWebVideo:true isAutoPlayer:false isMedia:true showTitle:@""];
        view.delegate = self;
        if(self.arrayPreView.count==0)
            [self.arrayPreView addObject:view];
        else{
            [self.arrayPreView insertObject:view atIndex:1];
        }
    }
    _collectionView.contentOffset = CGPointMake(0, 0);
    return self;
}

-(void)initSearchUI:(CGRect)frame searchTitle:(NSString*)searchTitle{
    self.msgArray = @[@" ...",@" ...",@" ...",@" ...",@" ...",@" ...",@"...."];
    labelheight = 30;
    float startX = 0;
    if (IF_IPHONE) {
        if (self.isFromSS) {
            cellW = self.frame.size.width;
            if (self.bounds.size.width>self.bounds.size.height) {
              cellH =  self.frame.size.height;
            }
            else{
              cellH = cellW*0.6;
            }
        }
        else{
            cellW = (self.frame.size.width-startX*2)/2.0;
            cellH = 80;
        }
    }
    else{
        startX = self.bounds.size.width*0;
        labelheight = 40;
        startX = startX*2;
        cellW = (frame.size.width-startX*2);
       // cellW = self.frame.size.width*;
        cellH = self.frame.size.height*0.56;
    }
    startPos = (frame.size.height-self.msgArray.count*labelheight)/2;
     UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(startX, 0, self.bounds.size.width-startX*2, self.bounds.size.height-0) collectionViewLayout:carouseLayout];
    [self.contentView addSubview:_collectionView];
    _collectionView.pagingEnabled = NO;
    _collectionView.bounces = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ParsePipeCell"];
    
    totalTime = 10+2;
    topDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, frame.size.width, 30)];
    topDesLabel.text =[NSString stringWithFormat:@"%@",searchTitle];
    topDesLabel.textAlignment = NSTextAlignmentCenter;
    topDesLabel.textColor = [UIColor greenColor];
    topDesLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    topDesLabel.adjustsFontSizeToFitWidth = YES;
    topDesLabel.backgroundColor = [UIColor blackColor];
    [self addSubview:topDesLabel];
    
    CGRect rect = [self addBuBannerReturnRect];
    
    UILabel * tishiLable = [[UILabel alloc]initWithFrame:CGRectMake(_collectionView.frame.origin.x,rect.origin.y-20 , _collectionView.frame.size.width, 20)];
    tishiLable.text =@"如果搜索失败，请设置下面参数(数字越大，成功率越高，手机慢，请选择大数字)";
    tishiLable.backgroundColor= [UIColor redColor];
    tishiLable.textAlignment = NSTextAlignmentRight;
    tishiLable.textColor = [UIColor whiteColor];
    if (IF_IPHONE) {
        tishiLable.font = [UIFont systemFontOfSize:12];
    }
    else
        tishiLable.font = [UIFont systemFontOfSize:20];
    [self.contentView addSubview:tishiLable];
    
    numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, frame.size.width, 20)];
    numberLabel.text =@"0.0%";
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:numberLabel];numberLabel.hidden=YES;
    numberLabel.alpha = topDesLabel.alpha=1;
    //104X113
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    if (IF_IPHONE) {
        btnClose.frame = CGRectMake(0, 0, 52, 56);
    }
    else{
        btnClose.frame = CGRectMake(0, 0, 52*2, 56*2);
    }
    [btnClose setImage:UIImageFromNSBundlePngPath(@"tv_listClose") forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];
    _collectionView.hidden = NO;
    
    btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = self.bounds;
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:btnClose belowSubview:_contentView];
    
    if (!_searchWebView) {
        _searchWebView = [[SearchWebView alloc] initWithFrame:self.bounds url:[NSString stringWithFormat:@"http://www.sogou.com/sogou?query=%@",[searchTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [self insertSubview:_searchWebView  belowSubview:btnClose];
    }
    //65X434
    float hh = 434,ww = 65;
    if (IF_IPHONE) {
        hh/=2;ww/=2;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-ww*1.5, (self.bounds.size.height-hh)/2, ww, hh)];
    imageView.image = UIImageFromNSBundlePngPath(@"major_sxgd");
    [self addSubview:imageView];
}

-(instancetype)initWithLiveFrame:(CGRect)frame webaArray:(NSArray*)webArray url:(NSString*)url titleArray:(NSArray*)array searchTitle:(NSString*)searchTitle{
    self = [super initWithFrame:frame];
    NSMutableArray *realArrayData = [NSMutableArray arrayWithCapacity:array.count];
    for(int i = 0;i<webArray.count;i++){
        NSNumber *ret = [NSNumber numberWithBool:false];
        [realArrayData addObject:@{ParsePipeUrl_Key:url,ParsePipeHtml_Key :[webArray objectAtIndex:i],ParsePipeMedia_Key:ret,ParsePipeTitle_Key:[array objectAtIndex:i]}];
    }
    
    return [self initWithFrameWithFilmPlayer:frame isFromSS:YES url:url webVideoUrl:nil arrayWebUrl:realArrayData isAutoPlayer:false searchTitle:searchTitle];
}

-(instancetype)initWithFrame:(CGRect)frame isFromSS:(BOOL)isFromSS arrayApi:(NSArray*)arrayApi url:(NSString*)url webVideoUrl:(NSString*)webVideoUrl searchTitle:(NSString*)searchTitle{
    NSMutableArray *arrayWebUrl = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < arrayApi.count; i++) {
        searchWebInfo *info = [arrayApi objectAtIndex:i];
        [arrayWebUrl addObject:[NSString stringWithFormat:@"%@%@",info.url,url]];
    }
    NSMutableArray *realArrayData = [NSMutableArray arrayWithCapacity:arrayWebUrl.count];
    for(int i = 0;i<arrayWebUrl.count;i++){
        NSNumber *ret = [NSNumber numberWithBool:false];
        searchWebInfo *info = [arrayApi objectAtIndex:i];
        [realArrayData addObject:@{ParsePipeUrl_Key:[arrayWebUrl objectAtIndex:i],ParsePipeMedia_Key:ret,ParsePipeTitle_Key:info.title}];
    }
    searchTitle = @"请选择，时间长，播放流畅的视频";
    return [self initWithFrameWithFilmPlayer:frame isFromSS:isFromSS url:url webVideoUrl:webVideoUrl arrayWebUrl:realArrayData isAutoPlayer:false searchTitle:searchTitle];
}

-(void)close:(UIButton*)sender
{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

-(void)pipePreFail:(id)v{
    //不需要删除
    return;
    [self.arrayPreView removeObject:v];
    [_collectionView reloadData];
    if (self.arrayPreView.count==0 && self.allFaildBlock) {
        self.allFaildBlock();
    }
}

-(void)pipeClickPlay:(id)v{
    [self playFromPreView:v];
}

-(void)pipeRevicePlayUrl:(id)v{
    NSString *realVideo = [v getRealVideoUrl];
    if (realVideo) {//接收到视频地址数据，丢给播放器处理
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RevicePipePlayUrl" object:realVideo];
    }
}

-(BOOL)pipeIsMute:(id)v{
    if (isFirstAudio) {
        isFirstAudio = false;
        return false;
    }
    return true;
}

-(void)pipePlayFromWebSuccess:(id)v{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.arrayPreView];
    for (int i = 0; i < tmpArray.count; i++)
    {
        if ([tmpArray objectAtIndex:i] != v) {
            [self.arrayPreView removeObject:[tmpArray objectAtIndex:i]];
        }
    }
    [_collectionView reloadData];
}


-(void)pipeAutoPlayer:(id)v{//自动点击播放,需要播放倒计时，保存preView数据
    if (isUpdateMsg) {
        return;
    }
    isUpdateMsg = true;
    for (int i = 0; i < self.arrayPreView.count; i++){
       MajorPreview*tmp = (MajorPreview*)[self.arrayPreView objectAtIndex:i];
        if ([tmp isKindOfClass:[MajorPreview class]] && (tmp!=v)) {
            [tmp stop];
        }
    }
    self.tmpPlayerInterface = v;
    //不直接播放，需要执行网updatemsg
    if (!self.isFromSS) {
        [self playFromPreView:v];
    }
    else{
        [self updateMsgBySelf];
    }
}

-(void)updateMsgBySelf{
    if (msgIndex+1<self.msgArray.count && ![self viewWithTag:msgIndex+1000+1]) {
        [self updateShowMsg:++msgIndex];
        [self performSelector:@selector(updateMsgBySelf) withObject:nil afterDelay:(arc4random()%10+1)/10.0];
    }
    else{
        [self playFromPreView:self.tmpPlayerInterface];
    }
}

-(void)playFromPreView:(MajorPreview*)preView{
    NSString *realVideo = [preView getRealVideoUrl];
    NSMutableArray *arrayTmpVideoUrl = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < self.arrayPreView.count; i++) {
        NSString *videoUrl = [[self.arrayPreView objectAtIndex:i] getRealVideoUrl];
        if(videoUrl)[arrayTmpVideoUrl addObject:videoUrl];
    }
    if (realVideo && self.selectBlock) {
        id playInterface  = [preView getZFAVPlayerInterface];
        int inspos = [preView getIndexPos];
        self.selectBlock(realVideo,_url,inspos,playInterface,arrayTmpVideoUrl);
    }
}

-(void)delayPlayShortSuccess{
    if (!self.isFromSS && self.rLoadBlock) {
        self.rLoadBlock();
        return;
    }
    if (self.shortPreViewView)
    {
        if (self.webVideoUrl && self.selectBlock) {
            self.selectBlock(self.webVideoUrl, _url, 0, nil,nil);
        }
        else
        {
            [self playFromPreView:self.shortPreViewView];
        }
    }
}

//短视频的处理
-(void)pipePreShortSuccess:(id)v{
    self.shortPreViewView = v;
    [self pipePreSuccess:v];
}

//针对网页，不需要排序
-(void)pipePreSuccess:(id)v{
   // numberLabel.text = @"时间长的视频，是完整视频";
   // topDesLabel.text =@"请选择一个播放";
    if ( self.isFromSS && self.arrayPreView.count>1 && [self.arrayPreView containsObject:v]) {
        [self.arrayPreView removeObject:v];
        if (self.arrayPreView.count>successIndex) {
            [self.arrayPreView insertObject:v atIndex:successIndex];
        }
        else{
            [self.arrayPreView insertObject:v atIndex:0];
        }
        [_collectionView reloadData];
        successIndex++;
    }
    if(self.isAutoPlayer){
        
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"WebLiveFilterManagerSuccess" object:topDesLabel.text];
}

-(void)updateShowMsg:(NSInteger)progress{
    return;
    if (!self.msgView) {
        self.msgView = [[UIView alloc]initWithFrame:self.bounds];
        [self insertSubview:self.msgView belowSubview:numberLabel];
    }
    msgIndex = progress;
    if (self.isFromSS && msgIndex<self.msgArray.count && ![self viewWithTag:msgIndex+1000]) {
        UILabel *label = [[UILabel alloc] init];
        label.tag = msgIndex+1000;
        label.text = [self.msgArray objectAtIndex:msgIndex];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        label.frame = CGRectMake(0,startPos + msgIndex*(labelheight+4), self.bounds.size.width, labelheight);
    }
}

-(void)progressTimer:(NSTimer*)timer{
    float v = 1.0*currentTime++/totalTime;
    if (v<=1.0) {
        v = v>=0.9?0.9:v;
        numberLabel.text = [NSString stringWithFormat:@"%0.0f%%",(v)*100];
        if (v<0.14) {
            [self updateShowMsg:0];
        }
        else if (v>=0.14&&v<0.28){
            [self updateShowMsg:1];
        }
        else if (v>=0.28&&v<0.42){
            [self updateShowMsg:2];
        }
        else if (v>=0.42&&v<0.56){
            [self updateShowMsg:3];
        }
        else if (v>=0.56&&v<0.7){
            [self updateShowMsg:4];
        }
        else if (v>=0.7&&v<0.84){
            [self updateShowMsg:5];
        }
        else if (v>=0.84){
            [self updateShowMsg:6];
        }
    }
    else{
      //  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayPlayShortSuccess) object:nil];
      //  [self performSelector:@selector(delayPlayShortSuccess) withObject:nil afterDelay:4];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

-(NSInteger)getSearchformWebPipeView{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"search_form_web_PipeView"];
    NSInteger n = number?[number integerValue]:(IF_IPAD?5:3);
    return n;
}

-(void)addExtrentBtn:(UIButton*)btn{
    [self addSubview:btn];
}

-(void)start:(NSString*)desMsg
{
    successIndex = 0;
    for (int i = 0; i < self.arrayPreView.count; i++){
       MajorPreview *preView = (MajorPreview*)[self.arrayPreView objectAtIndex:i] ;
        if ([preView isKindOfClass:[MajorPreview class]]) {
            [preView delayStart:i delay:[self getSearchformWebPipeView]];
        }
    }
    if (!desDesLabel) {
        CGRect rect =numberLabel.frame;
        desDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+5, rect.size.width, rect.size.height)];
        desDesLabel.textAlignment = numberLabel.textAlignment;
        desDesLabel.font = numberLabel.font;
        desDesLabel.textColor = RGBCOLOR(154,30,245);
        [self addSubview:desDesLabel];
    }
    desDesLabel.text = desMsg;
    if (!self.progressTimer) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressTimer:) userInfo:nil repeats:YES];
        [self updateShowMsg:0];
    }
}

-(void)stop
{
    successIndex = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayPlayShortSuccess) object:nil];
    self.tmpPlayerInterface = nil;
    [self.progressTimer invalidate];
    RemoveViewAndSetNil(_searchWebView);
    self.progressTimer = nil;
    self.selectBlock = nil;
    self.closeBlock = nil;
    self.closeReOpenBlock = nil;
    self.allFaildBlock = nil;
    for (int i = 0; i < self.arrayPreView.count; i++)
    {
       MajorPreview *preView = (MajorPreview*)[self.arrayPreView objectAtIndex:i];
        if ([preView isKindOfClass:[MajorPreview class]]) {
            [preView stop];
        }
    }
}

-(void)updateNotCreateThumbnail{
    for (int i = 0; i < self.arrayPreView.count; i++)
    {
        MajorPreview *preView = (MajorPreview*)[self.arrayPreView objectAtIndex:i];
        if ([preView isKindOfClass:[MajorPreview class]]) {
            preView.isCanTestVideoPlay = false;
        }
    }
}

#pragma mark--UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize viewSize = self.bounds.size;
    if (viewSize.width>viewSize.height) {
        return CGSizeMake(cellW, viewSize.height);
    }
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.arrayPreView.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ParsePipeCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blackColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:[self.arrayPreView objectAtIndex:indexPath.row]];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    MajorPreview *preView = (MajorPreview*)[self.arrayPreView objectAtIndex:indexPath.row];
//    if ([preView isKindOfClass:[MajorPreview class]]) {
//        [self playFromPreView:preView];
//    }
//    else{//广告
//
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
@end
