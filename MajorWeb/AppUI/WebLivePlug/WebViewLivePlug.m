//
//  WebViewLivePlug.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/15.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "WebViewLivePlug.h"
#import "WebTopChannel.h"
#import "MainMorePanel.h"
#import "WebLiveNodeInfo.h"
#import "MBProgressHUD.h"
#import "WebLiveVaildUrlParse.h"
#import "ApiCoreManager.h"
#import "VideoPlayerManager.h"
#import "MajorZyPlug.h"
#import "AppDelegate.h"
#import "WebLiveFilterManager.h"
static NSMutableDictionary *webViewDataInfo = NULL;
@interface WebViewLivePlug()<WebTopChannelDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    float cellw,cellh;
    float  stautsBarH ;
}
@property(nonatomic,strong)UIButton *btnBack;
@property(nonatomic,strong)UIButton *btnShouca;
@property(nonatomic,strong)UIButton *btnEdit;
@property(nonatomic,strong)UIButton *btnFaviev;
@property(nonatomic,assign)BOOL isEdit;
@property(nonatomic,strong)WebTopChannel *webChannelView;
@property(nonatomic,strong)WebLiveNodeInfo *webNodeInfo;
@property(nonatomic,strong)MBProgressHUD *hubView;
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonnull,copy)NSString *currentTitle;
@property(nonnull,copy)NSString *currentUrl;
@end

@implementation WebViewLivePlug

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    [self removeWaitView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

-(void)addWaitView{
    if (!self.hubView) {
        self.hubView = [[MBProgressHUD alloc] initWithView:self];
        [self.hubView showAnimated:YES];
        self.hubView.removeFromSuperViewOnHide = YES;
        [self.collectionView addSubview:self.hubView];
        self.hubView.userInteractionEnabled = YES;
    }
}

-(void)removeWaitView{
    [self.hubView hideAnimated:NO];
    self.hubView=nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!webViewDataInfo) {
        webViewDataInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    initYYCache(@"WebLivePlugCaches");
    stautsBarH = GetAppDelegate.appStatusBarH;
     UIView *topW = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, stautsBarH)];
    [self addSubview:topW];
    topW.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor blackColor];
    
    self.btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBack setImage:UIImageFromNSBundlePngPath(@"CartoonAsset.bundle/c") forState:UIControlStateNormal];
    [self addSubview:self.btnBack];
    self.btnBack.frame = CGRectMake(0, stautsBarH+10, 20, 20);
    [self.btnBack addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWebLiveVaildDesUrl:) name:@"UpdateWebLiveVaildDesUrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickVideoPlayerManagerCloseEvent:) name:ClickVideoPlayerManagerCloseEvent object:nil];
    //shoucang_t
    //136X53
    self.btnShouca = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnShouca setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/shoucang_t") forState:UIControlStateNormal];
    self.btnShouca.frame = CGRectMake(0,MY_SCREEN_HEIGHT- (stautsBarH-20)-27, 68, 27);
    [self addSubview:self.btnShouca];
    [self.btnShouca addTarget:self action:@selector(showFavrion:) forControlEvents: UIControlEventTouchUpInside];
    [self addBtns];
    //filter
    {/*
        UIButton *btnShouca = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnShouca setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/shoucang_t") forState:UIControlStateNormal];
        btnShouca.frame = CGRectMake(MY_SCREEN_WIDTH/2,MY_SCREEN_HEIGHT- (stautsBarH-20)-27, 68, 27);
        [self addSubview:btnShouca];
        [btnShouca addTarget:self action:@selector(startFilter:) forControlEvents: UIControlEventTouchUpInside];
        */
    }//end
    return self;
}

-(void)startFilter:(UIButton*)sender{
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:1];
    [webViewDataInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, WebLiveNodeInfo* obj, BOOL * _Nonnull stop) {
        [arrayTmp addObjectsFromArray: obj.dataNodeArray];
    }];
    [[WebLiveFilterManager getFilterManager] startRun:arrayTmp];
}

-(void)clickVideoPlayerManagerCloseEvent:(NSNotification*)object
{
    self.btnFaviev.hidden =YES;
}

-(void)showFavrion:(UIButton*)sender{
    NSArray *arrayKey =  getCartoonFavouriteKey();
    NSMutableArray *arrayTmp = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < arrayKey.count; i++) {
        NSArray *array = getCartList([[arrayKey objectAtIndex:i] objectForKey:@"key"]);
        if (array.count>0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:array.firstObject];
            [dic setObject:[[arrayKey objectAtIndex:i]objectForKey:@"key"] forKey:@"key"];
            [arrayTmp addObject:dic];
        }
    }
    self.arrayData = arrayTmp;
    [self.collectionView reloadData];
    [self.webChannelView updateSelect:-1];
    self.isEdit = false;
    self.btnEdit.hidden = NO;
    self.btnFaviev.hidden = YES;
}

-(void)updateWebLiveVaildDesUrl:(NSNotification*)object{
    id value = object.object;
    self.btnFaviev.hidden = NO;
    [[VideoPlayerManager getVideoPlayInstance] playWithPlayerInterface:value title:self.currentTitle saveInfo:nil isMustSeekBegin:false];
}

-(void)addBtns
{
    NSArray *array = [MainMorePanel getInstance].morePanel.webDataLiveInfo;
    float startY = stautsBarH+5;
    if (array.count>0) {
        float hh = 25;
        if (IF_IPAD) {
            hh = 40;
        }
        self.webChannelView = [[WebTopChannel alloc] initWithFrame:CGRectMake(0, self.btnBack.frame.origin.y+self.btnBack.frame.size.height+10,170/2.0 ,self.btnShouca.frame.origin.y-(self.btnBack.frame.origin.y+self.btnBack.frame.size.height+20))];
        self.webChannelView.delegate = self;
       // self.webChannelView.center = CGPointMake(self.webChannelView.center.x, self.btnBack.center.y);
        startY = self.webChannelView.frame.origin.y+self.webChannelView.frame.size.height+5;
        [self addSubview:self.webChannelView];
        [self.webChannelView updateTopArray:array];
        __weak __typeof(self)weakSelf = self;
        self.webChannelView.clickBlock = ^(webDataLiveInfo *item) {
            [weakSelf updateNodeInfo:item];
        };
        self.webChannelView.backgroundColor = [UIColor whiteColor];
        self.webChannelView.collectionView.backgroundColor = [UIColor whiteColor];
        [self.webChannelView hiddenMore];
        [self.webChannelView updateVertical];
        [self.webChannelView updateSelect:0];
        [self updateNodeInfo:array.firstObject];
        self.btnBack.center = CGPointMake(self.webChannelView.center.x, self.btnBack.center.y);
        float startY = stautsBarH;
        UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.webChannelView.frame.origin.x+self.webChannelView.frame.size.width, startY, self.bounds.size.width-(self.webChannelView.frame.origin.x+self.webChannelView.frame.size.width), self.bounds.size.height-startY-(stautsBarH-20)) collectionViewLayout:fallLayout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        fallLayout.minimumInteritemSpacing =1;
        [self.collectionView setCollectionViewLayout:fallLayout];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
        [self addSubview:self.collectionView];
        if (IF_IPHONE) {
            cellw = (_collectionView.frame.size.width-30)/1;
            cellh = 50;
        }
        else{
            cellw = (_collectionView.frame.size.width-60)/2;
            cellh = 50;
        }
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnEdit setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/qxshoucang_t") forState:UIControlStateNormal];
        self.btnEdit.frame = self.btnShouca.frame;
        [self addSubview:_btnEdit];
        self.btnEdit.center = CGPointMake(self.collectionView.center.x, self.btnEdit.center.y);
        [self.btnEdit addTarget:self action:@selector(editCell:) forControlEvents:UIControlEventTouchUpInside];
        self.btnEdit.hidden = YES;
        
        self.btnFaviev = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnFaviev setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/shoucang_t1") forState:UIControlStateNormal];
        self.btnFaviev.frame = self.btnShouca.frame;
        [self addSubview:_btnFaviev];
        self.btnFaviev.center = CGPointMake(self.bounds.size.width-_btnFaviev.bounds.size.width/2, self.btnFaviev.center.y);
        [self.btnFaviev addTarget:self action:@selector(showCang:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFaviev.hidden = YES;
    }
}

-(void)showCang:(UIButton*)sender{
    if (self.currentUrl && self.currentTitle) {
        NSArray *array = @[@{@"url":self.currentUrl,@"name":self.currentTitle}];
        syncCartoonList(array, self.currentTitle,MajorDataSource);
        syncCartoonFavourite(self.currentTitle,MajorDataSource);
    }
}

-(void)editCell:(UIButton*)sender{
    self.isEdit = !self.isEdit;
    [self.collectionView reloadData];
}

-(void)updateNodeInfo:(webDataLiveInfo*)item{
    self.btnEdit.hidden = YES;
    if (![VideoPlayerManager getVideoPlayInstance].player.currentPlayerManager || [VideoPlayerManager getVideoPlayInstance].player.currentPlayerManager.playState==ZFPlayerPlayStatePlayStopped) {
        self.btnFaviev.hidden =YES;
    }
    else{
        self.btnFaviev.hidden =NO;
    }
    self.isEdit = false;
    [self addWaitView];
    [self.webNodeInfo stopParse];
    self.arrayData = nil;
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero];
     id v = [webViewDataInfo objectForKey:item.name];
    if (v) {
        self.webNodeInfo = v;
    }
    else{
      self.webNodeInfo =  [[WebLiveNodeInfo alloc] initWithWebsArray:item.array title:item.name];
        [webViewDataInfo setObject:self.webNodeInfo forKey:item.name];
    }
    [self.webNodeInfo startParse];
    @weakify(self)
    [RACObserve(self.webNodeInfo,isDataChange) subscribeNext:^(id x) {
        @strongify(self)
        [self updateData:YES array:self.webNodeInfo.dataNodeArray];
    }];
}

-(void)updateData:(BOOL)isSuccess array:(NSArray*)array{
    [self removeWaitView];
    self.arrayData = [NSMutableArray arrayWithArray:array];
      [self.collectionView reloadData];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellw, cellh);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.arrayData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ContentCollection";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *lable = [[UILabel alloc] init];
    lable.font = [UIFont systemFontOfSize:30];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"name"];
    [cell.contentView addSubview:lable];
    lable.textColor = self.isEdit?[UIColor redColor]:[UIColor blackColor];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isEdit) {
        delCartoonFavouriteKey([[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"key"] );
        [self.arrayData removeObjectAtIndex:indexPath.row];
        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
    else{
        [[VideoPlayerManager getVideoPlayInstance] stop];
        self.btnFaviev.hidden = YES;
        self.currentUrl = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"url"];
        self.currentTitle = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"name"];
        [[WebLiveVaildUrlParse getInstance] startWebChannel:self.currentUrl title:self.currentTitle];
    }
 }

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}

-(UIColor*)selectColor{
    return RGBCOLOR(0, 255, 0);
}

-(UIColor*)unSelectColor{
    return RGBCOLOR(142, 142, 142);
}

-(float)selectFontSize{
    return 16;
}

-(float)unSelectFontSize{
    return 15;
}
@end
