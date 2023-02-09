//
//  WebDesListView.m
//  WatchApp
//
//  Created by zengbiwang on 2017/4/17.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "WebDesListView.h"
#import "AppDelegate.h"
#import "WebDesLineView.h"
#import "ReactiveCocoa.h"
#import "MajorPlayVideoHistory.h"
#import  "YTKNetworkPrivate.h"
#import "VideoPlayerManager.h"
#import "VideoPlayerManager+Down.h"
#define  gogogogogwhwhwh @weakify(self) \
self.afterBlock = dispatch_block_create(0, ^{ \
    @strongify(self) \
    self.isCanFireAutoFadeOut = true; \
}); \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3)), dispatch_get_main_queue(),self.afterBlock);

@interface WebDesListView ()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>
{
    float cellW,cellH;
    UIButton *btnEdit;
    CGSize btnSize;
    BOOL btnEditState;
    NSInteger countCulm;
    BOOL isInitSuccess;
}
@property(nonatomic,assign)BOOL decelerate;
@property(nonatomic,weak)NSIndexPath *didIndexPath;
@property(nonatomic,assign)BOOL isCanFireAutoFadeOut;
@property(nonatomic,assign)BOOL isSousouType;
@property(nonatomic,assign)float viewOffset;
@property(nonatomic,strong)WebDesLineView *WebDesLineView;
@property(nonatomic,copy)NSString*videoTitle;
@property(nonatomic,copy)NSArray *lineArray;
@property(nonatomic,strong)UIButton *btnClose;
@property(nonatomic,strong)UIView *backMaskView;
@property(nonatomic,strong)UILabel *topLabel;
@property(nonatomic,copy)NSArray *players;
@property(nonatomic,assign)  NSInteger currentIndex;
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,copy)WebDesListViewCloseBlock closeBlock;
@property(nonatomic,copy)WebDesListViewSelectBlock selectBlock;
@property(nonatomic,copy)WebDesListViewUpdateLineBlock updateLineBlock;
@property (nonatomic, strong) dispatch_block_t afterBlock;
@end
@implementation WebDesListView

- (void)cancelAfterBlock {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}

-(void)updateSelectState{
    [self updateSelectIndex:self.currentIndex];
}

-(void)updateSelectIndex:(NSInteger)index{
    if (index>=self.players.count) {
        index = self.players.count-1;
    }
    self.currentIndex = index;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayUpdate) object:nil];
    [self performSelector:@selector(delayUpdate) withObject:nil afterDelay:0.1];
}


-(void)delayUpdate{
    NSLog(@"%s",__FUNCTION__);
    [self.collectionView reloadData];
    if (!self.superview || !CGAffineTransformIsIdentity(self.superview.transform)) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self bk_performBlock:^(id obj) {
        if (weakSelf.collectionView.frame.size.height<100) {
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
        }
        else{
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredVertically) animated:NO];
        }
    } afterDelay:0.1];
}

-(instancetype)initWith:(CGRect)frame viewOffset:(float)viewOffsetH block: (WebDesListViewCloseBlock)block selectBlock:(WebDesListViewSelectBlock)selctblock updateLine:(WebDesListViewUpdateLineBlock)updateLine nCount:(NSArray*)array isSousouType:(BOOL)isSousouType{
    self.isSousouType = isSousouType;
    self.viewOffset = viewOffsetH;
    self = [super initWithFrame:frame];
    self.closeBlock = block;
    self.selectBlock = selctblock;
    self.updateLineBlock = updateLine;
    self.players = array;
    countCulm = 0;
    self.backgroundColor = [UIColor blueColor];
    return self;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    self.lineArray = nil;self.players=nil;
    RemoveViewAndSetNil(self.btnClose);
    RemoveViewAndSetNil(self.backMaskView);
    RemoveViewAndSetNil(self.topLabel);
    RemoveViewAndSetNil(self.collectionView);
}
-(void)removeFromSuperview{
    [self cancelAfterBlock];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayUpdate) object:nil];
    self.closeBlock = nil;
    self.selectBlock =  nil;
    self.updateLineBlock = nil;self.selectUrlBlock = nil;
    [super removeFromSuperview];
}

-(void)updateCulm:(NSInteger)customCulm{
    countCulm = customCulm;
}

-(void)updateLineData:(NSArray*)array{
    self.players = array;
    [self.collectionView reloadData];
}

-(void)initUI:(NSArray*)lineArray title:(NSString*)title
{
    self.lineArray = lineArray;
    self.videoTitle = title;
    [self.WebDesLineView initPipeData:lineArray];
    [self.collectionView reloadData];
}

-(void)addJustFrame:(CGSize)viewSize{
    if (isInitSuccess || viewSize.height<20) {
        return;
    }
    isInitSuccess = true;
    cellW = 30;cellH = 30;
    float fontSize = 14;
    if (countCulm>0) {
        cellW = (self.bounds.size.width - 30) /countCulm;
        btnSize = CGSizeMake(120*0.7, 30*0.7);
        fontSize = 12;
    }
    else{
        cellW = (self.bounds.size.width - 20) /6.0;
    }
     if (IF_IPHONE && GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscape) {
        cellW = (self.bounds.size.width - 20) /4;
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    if(GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskPortrait){
        self.backgroundColor = UIColorFromRGBA(0, 0, 0);
       btnEdit.hidden = _btnClose.hidden = NO;
    }
    else{
       btnEdit.hidden = _btnClose.hidden = YES;
    }
    if(IF_IPAD){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    cellH = cellW;
    if (GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscape||
        GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscapeRight) {
        self.topLabel.hidden = self.btnClose.hidden = YES;
        _collectionView.frame = self.bounds;
        UICollectionViewFlowLayout *v = (UICollectionViewFlowLayout*)_collectionView.collectionViewLayout;
        v.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        cellH = IF_IPAD?50:40; cellW = 70;
    }
    else if(GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskPortrait){
        self.topLabel.hidden = self.btnClose.hidden = NO;
        self.backMaskView.hidden = self.topLabel.hidden = self.btnClose.hidden = NO;
        _collectionView.frame = CGRectMake(4, self.viewOffset+27, self.bounds.size.width-8, self.bounds.size.height-self.viewOffset-27);
    }
    CGPoint offsetPoit = self.collectionView.contentOffset;
    [self.collectionView reloadData];
    self.collectionView.contentOffset = offsetPoit;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self addJustFrame:frame.size];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self addJustFrame:self.bounds.size];
}

-(UIView*)getCollectionView{
    return _collectionView;
}

-(UICollectionView*)collectionView
{
    if (!_collectionView) {
        CGSize viewSize = self.bounds.size;
        //按比例diaozh
        btnSize = CGSizeMake(120, 30);
        cellW = 30;cellH = 30;
        float fontSize = 14;
        if (countCulm>0) {
            cellW = (self.bounds.size.width - 30) /countCulm;
            btnSize = CGSizeMake(120*0.7, 30*0.7);
            fontSize = 12;
        }
        else{
            cellW = (self.bounds.size.width - 20) /6.0;
        }
        cellH = IF_IPAD?40:cellW;
        self.btnClose = [UIButton buttonWithType:UIButtonTypeCustom];//164X55
        _btnClose.frame = CGRectMake((viewSize.width-82), 0, 82, 27);
        [_btnClose setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/tv_menu_closeList") forState:UIControlStateNormal];
         [self addSubview:_btnClose];
        
        [_btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.top.equalTo(self).mas_offset(40);
            make.width.mas_equalTo(82);
            make.height.mas_equalTo(27);
        }];
        
        [_btnClose addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
        _backMaskView = [[UIView alloc] init];
        [self insertSubview:_backMaskView belowSubview:_btnClose];
        _backMaskView.backgroundColor = RGBCOLOR(80, 80, 80);
        [_backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self);
            make.top.equalTo(self->_btnClose.mas_top);
            make.bottom.equalTo(self);
        }];
        
        _topLabel = [[UILabel alloc] init];
        _topLabel.textAlignment = NSTextAlignmentLeft;
        _topLabel.textColor = RGBCOLOR(191, 191, 191);
        [self addSubview:_topLabel];
        [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self->_btnClose.mas_left);
            make.top.equalTo(self).mas_offset(self.viewOffset);
            make.left.mas_equalTo(self.mas_left);
            make.height.mas_equalTo(self->_btnClose.mas_height);
        }];
        if(IF_IPAD){
            _topLabel.font = [UIFont systemFontOfSize:20];
        }
        else {
            _topLabel.font = [UIFont systemFontOfSize:14];
        }
        _topLabel.text = @"  ★★★↓请选择列表进行视频播放";
        
        __weak typeof(self) weakSelf = self;
        _WebDesLineView = [[WebDesLineView alloc]init];
        _WebDesLineView.lineNoPipeBlock = ^(NSInteger lineNo) {//更新线路
            [weakSelf updateLine:lineNo];
        };
        [self addSubview:_WebDesLineView];
        if (self.isSousouType) {
            _WebDesLineView.hidden = YES;
            _WebDesLineView.alpha = 0;
        }
        [_WebDesLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self->_btnClose.mas_left).mas_offset(-5);
            make.centerY.equalTo(self->_btnClose);
            if (IF_IPAD) {
                make.height.mas_equalTo(28);
            }
            else{
                make.height.mas_equalTo(20);
            }
        }];
        [self.WebDesLineView initPipeData:self.lineArray];

        UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGRect rect = CGRectMake(0, self.viewOffset+45, viewSize.width, viewSize.height);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:carouseLayout];
        [self addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FilmPlayerCell"];
        
        btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnEdit setTitle:@"批量下载"  forState:UIControlStateNormal];
        btnEdit.titleLabel.font = [UIFont systemFontOfSize:12];
        [btnEdit setBackgroundColor:RGBCOLOR(7, 156, 0)];
        [self addSubview:btnEdit];
        [btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self->_btnClose.mas_left).mas_offset(-20);
            make.centerY.equalTo(self->_btnClose);
            make.width.mas_equalTo(self->btnSize.width*0.8);
            make.height.mas_equalTo(self->btnSize.height*0.8);
        }];
        
        [btnEdit addTarget:self action:@selector(addVideoInfo:) forControlEvents:UIControlEventTouchUpInside];

#if DoNotKMPLayerCanShareVideo
#else
        
        if (true) {//会员以及打开
            btnEdit.alpha = 1;
        }
        else{
//            __weak typeof(self) weakSelf = self;
//            [RACObserve(GetAppDelegate, btnEditHidden) subscribeNext:^(id x) {
//                if (GetAppDelegate.btnEditHidden)//强制弹出对话，走下载流程
//                {
//                    [weakSelf reSetBtnEditState:true];
//                }
//            }];
//            if([[WelfareManager getInstance] isAppAssess])//没有评论就显示该按钮
//                btnEdit.alpha = 0;
//            else
//                btnEdit.alpha = 1;
//            if (GetAppDelegate.btnEditHidden) {
//                btnEdit.alpha = 0;
//            }
        }
#endif
    }
    return _collectionView;
}

-(void)addVideoInfo:(UIButton*)sender
{
    btnEditState = !btnEditState;
    [self.collectionView reloadData];
    if(!btnEditState){
        [btnEdit setTitle:@"批量下载"  forState:UIControlStateNormal];
    }
    else
    {
        [btnEdit setTitle:@"退出" forState:UIControlStateNormal];
    }
}

-(void)reSetBtnEditState:(BOOL)isSuccess{
  
}


-(void)updateLine:(NSInteger)index{
    if (self.updateLineBlock) {
        self.updateLineBlock(index);
    }
}

-(void)close{
    if (self.closeBlock) {
        self.closeBlock(self);
    }
    else{
        self.hidden = YES;
    }
}

-(NSMutableAttributedString*)getAttributedFromText:(NSString*)str isSelected:(BOOL)isSelected{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    UIFont *defaultfont = nil,*numberFont = nil;
    float fontSize = 15;
    if (countCulm>0) {
        fontSize = 16;
    }
    else{
        fontSize = 15;
    }
    if (IF_IPAD) {
        if (countCulm>0) {
            fontSize *= 2;
        }
        else{
            fontSize *= 1;
        }
    }
    defaultfont = [UIFont systemFontOfSize:fontSize*0.6];
    numberFont = [UIFont systemFontOfSize:fontSize];
    [attrStr addAttribute:NSFontAttributeName
                        value:defaultfont
                        range:NSMakeRange(0, [str length])];
    if (isSelected) {
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:RGBCOLOR(0, 192, 255)
                        range:NSMakeRange(0, [str length])];
    }
    else{
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGBA(85, 85, 85)
                        range:NSMakeRange(0, [str length])];
    }
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:NULL];
        [scanner scanCharactersFromSet:delimiterSet intoString:&pairString];
        if (pairString) {
            NSRange range = [str rangeOfString:pairString];//数字
            [attrStr addAttribute:NSFontAttributeName value:numberFont range:range];
            if (!isSelected) {
                [attrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(198, 198, 198) range:range];
            }
        }
    }
    return attrStr;
}

-(void)didClickIndexPath:(NSIndexPath*)indexPath{
#if DoNotKMPLayerCanShareVideo
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayUpdate) object:nil];
    id value = [self.players objectAtIndex:indexPath.row];
    NSString *url = [value objectForKey:@"url"];
    if (self.selectUrlBlock) {
        self.selectUrlBlock(url);
    }
    else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PostGlobalWebUrl" object:url];
    }
    [[MajorPlayVideoHistory getInstance] addVideoInfo:url];
    [self updateSelectIndex:indexPath.row];
    [[[UIApplication sharedApplication] keyWindow] makeToast:@"正在加载，如果没播放，请刷新网页" duration:2 position:@"center"];
#else
    id value = [self.players objectAtIndex:indexPath.row];
    if (false/*[value isKindOfClass:[PlayersItem class]]*/) {
      /*  PlayersItem *playsItem = value;
        if (btnEditState) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:playsItem.uri,@"parma0",[NSString stringWithFormat:@"%@-%@",self.videoTitle,playsItem.name],@"parma1", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:DOWNAPICONFIG.msgapp2 object:info];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]]];
        }
        else{
            self.selectBlock(indexPath.row);
        }*/
    }
    else{
        if (btnEditState) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[value objectForKey:@"url"],@"parma0",[NSString stringWithFormat:@"%@-%@",self.videoTitle,[value objectForKey:@"title"]],@"parma1", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:DOWNAPICONFIG.msgapp2 object:info];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]]];
        }
        else{
            NSString *webHtml = [value objectForKey:@"url"];
            NSString *title = [value objectForKey:@"title"];
            if (![self testPlayLocal:title parma0:webHtml]) {
                NSString*url =[value objectForKey:@"url"];
                if (self.selectUrlBlock) {
                    self.selectUrlBlock(url);
                }
                else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"PostGlobalWebUrl" object:url];
                }
                [[MajorPlayVideoHistory getInstance] addVideoInfo:url];
                [[[UIApplication sharedApplication] keyWindow] makeToast:@"正在加载，如果没播放，请刷新网页" duration:2 position:@"center"];
            }
            
            [self updateSelectIndex:indexPath.row];
        }
    }
#endif
}

-(BOOL)testPlayLocal:(NSString*)title parma0:(NSString*)parma0{
#if DoNotKMPLayerCanShareVideo
#else
    if (DOWNAPICONFIG.msgappf2) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf2];
        NSString *uuid = [YTKNetworkUtils md5StringFromString:parma0];
        [info setObject:[NSArray arrayWithObject:uuid] forKey:@"param4"];
        NSString *file =[[AppWtManager getInstanceAndInit] getWtCallBack:info];
        if([file length]>4){//调用播放
            if ([file rangeOfString:@"/Web/videopath"].location!=NSNotFound) {
                file = [VideoPlayerManager tryToPathConvert:file uuid:uuid];
                file = [[NSURL fileURLWithPath:file] absoluteString];
            }
            else if ([file rangeOfString:@"/alone/aloneVideoPath"].location!=NSNotFound){
                file = [[NSURL fileURLWithPath:file] absoluteString];
            }
            [[VideoPlayerManager getVideoPlayInstance] playWithUrl:file title:title referer:nil saveInfo:nil replayMode:false  rect:CGRectZero throwUrl:nil isUseIjkPlayer:false];
            return true;
        }
    }
#endif
    return false;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.players.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"FilmPlayerCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.contentView.clipsToBounds = true;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cellW, cellH)];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *url = nil;
    NSString *text = [[self.players objectAtIndex:indexPath.row] objectForKey:@"title"];
    if([text isKindOfClass:[NSNull class]]){
        text = [NSString stringWithFormat:@"第%ld集",indexPath.row];
    }
    url = [[self.players objectAtIndex:indexPath.row] objectForKey:@"url"];
    if (self.currentIndex == indexPath.row) {
        label.attributedText =[self getAttributedFromText:text isSelected:YES];
    }
    else{
        label.attributedText =[self getAttributedFromText:text isSelected:NO];
    }
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor blackColor];
    [cell.contentView addSubview:label];
    BOOL isWatch = [[MajorPlayVideoHistory getInstance] isVideoWatch:url];
    if (isWatch) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, cellH*0.8, cellW, cellH*0.2)];
        [cell.contentView addSubview:label];
        label.backgroundColor = [UIColor blackColor];
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"已观看";
        label.textColor = RGBCOLOR(198, 198, 198);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:9];
    }

    
#if DoNotKMPLayerCanShareVideo
#else
    NSString *uuid = [YTKNetworkUtils md5StringFromString:url];
    NSString *imageName = nil;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf2];
    [info setObject:[NSArray arrayWithObjects:uuid, nil] forKey:@"param4"];
    NSMutableDictionary * info2 = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf12];
    [info2 setObject:@[uuid] forKey:@"param4"];
    if ([[AppWtManager getInstanceAndInit] getWtCallBack:info] ) {
       imageName = @"film_select_finish";
    }
    else if([[[AppWtManager getInstanceAndInit] getWtCallBack:info2] boolValue]){
        imageName = @"film_select_gg";
    }
    if (!imageName && btnEditState) {
        imageName = @"film_select_addin";
    }
    if (imageName) {
        float h = 52.0/198*cellW;
        UIImageView *ggView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellW, h)];
        ggView.image = UIImageFromNSBundlePngPath(imageName);
        [cell.contentView addSubview:ggView];
    }
#endif

    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self didClickIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscape||
        GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscapeRight) {
        return 20;
    }
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscape||
        GetAppDelegate.supportRotationDirection == UIInterfaceOrientationMaskLandscapeRight) {
        return 10;
    }
    return 2;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isCanFireAutoFadeOut = false;
    if (self.decelerate) {
        gogogogogwhwhwh
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isCanFireAutoFadeOut = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.decelerate = decelerate;
    gogogogogwhwhwh
    
}

@end
