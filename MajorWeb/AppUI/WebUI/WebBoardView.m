//
//  WebBoardView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/25.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "WebBoardView.h"
#import "YSCKitMacro.h"
#import "AppDelegate.h"
#import "MajorModeDefine.h"
#import "ContentWebView.h"
#import "MarjorWebConfig.h"
#import "ReactiveCocoa.h"
#define ContentObject   @"ContentObjectKey"
#define ZhanWeiObject   @"ZhanWeiObjectKey"
#define ConetentCanAdd   @"ConetentCanAdd"


@interface ZhanWeiObjectView:UIView

@end
@implementation ZhanWeiObjectView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
-(id)init{
    self = [super init];
    return self;
}

-(void)removeFromSuperview{
    [self updateContent:false];
    [super removeFromSuperview];
}
-(void)updateContent:(BOOL)isShow{
    NSArray*array= [self subviews];
    for (int i = 0; i < array.count; i++) {
       UIView *object =  [array objectAtIndex:i];
        if ([object isKindOfClass:[ContentWebView class]]) {
            [(ContentWebView*)object showSnapshot:isShow];
            break;
        }
    }
}
@end

@interface UIImageViewDel:UIImageView
@property(nonatomic,assign)NSInteger delIndex;
@end

@implementation UIImageViewDel
-(instancetype)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    return self;
}
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    [super removeFromSuperview];
}
@end
@interface WebBoardView()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>{
    float cellW,cellH;
    BOOL isFullView;
    float labelh;
    UIView *bigMaskView;
    BOOL isCanShowSnapshot;
}
@property(nonatomic,strong)UIButton *addBtnWeb;
@property(nonatomic,strong)UIImageView *backImageView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UIView *maskView;
@property(nonatomic,assign)CGSize viewSize;
@property(nonatomic,weak)UIView *popWeb;
@property(nonatomic,strong)NSMutableArray *childrenArray;
@property(nonatomic,strong)UICollectionView *collectionView;
@end
@implementation WebBoardView

-(id)init{
    self = [super init];
    self.viewSize = CGSizeMake(MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(autoRemoveWeb:) name:@"AutoRemoveWeb" object:nil];
    return self;
}

-(void)autoRemoveWeb:(NSNotification*)object{
    [self delView:nil delIndex:self.childrenArray.count-1];
}

-(void)updateIsSize:(CGSize)size{
    isCanShowSnapshot = true;
    self.viewSize = size;
    self.bounds = CGRectMake(0, 0, size.width, size.height);
    [self updateConetentSize];
}

-(void)loadSnycMarkFromLocal:(NSArray*)array{
    isCanShowSnapshot = true;
    [self createCollectView];
    if (!self.childrenArray) {
        self.childrenArray = [NSMutableArray arrayWithCapacity:1];
    }
    [self.childrenArray removeAllObjects];
    for (int i = 0; i < array.count; i++) {
        [self.childrenArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[array objectAtIndex:i],ContentObject,[[ZhanWeiObjectView alloc]init],ZhanWeiObject,[NSNumber numberWithBool:true],ConetentCanAdd, nil]];
        [self addWebToMaskView:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    self.collectionView.hidden = self.hidden = NO;
}

-(void)addWebToMaskView:(NSIndexPath*)indexPath{
        UIView *v = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ContentObject];
        UIView *maskView = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ZhanWeiObject];
    maskView.frame = CGRectMake(0, 0, cellW, cellH);
        if (true) {
            v.userInteractionEnabled = NO;
            if (isFullView) {
                if ([[[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ConetentCanAdd] boolValue]) {
                    [self addWebOnMaskView:maskView webView:v];
                }
            }
            else{
                v.transform = CGAffineTransformMakeScale(cellW/MY_SCREEN_WIDTH, (cellH)/MY_SCREEN_HEIGHT);
                v.frame = CGRectMake(0, 0, cellW,cellH);
                [maskView addSubview:v];
            }
        }
}

-(void)updateConetentSize{
    [self.addBtnWeb removeFromSuperview];
    self.addBtnWeb = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    [self.bottomView removeFromSuperview];
    self.bottomView = nil;
    if (self.viewSize.height>300) {//全屏
        isFullView = true;
    }
    else{
        isFullView = false;
    }
    [self createCollectView];
    for (int i =0; i < self.childrenArray.count; i++) {
        UIView *v = [[self.childrenArray objectAtIndex:i] objectForKey:ContentObject];
        [v removeFromSuperview];
        [self addWebToMaskView:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.collectionView reloadData];
}

-(void)createCollectView{
    if (_collectionView) {
        return;
    }
    labelh = 50;
    float offsetY = 68;
    if (IF_IPHONE) {
        offsetY/=2;
        labelh/=2;
    }
    float offsetFixY = GetAppDelegate.appStatusBarH-20;
    self.backgroundColor = [UIColor blackColor];
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 40, self.viewSize.width, self.viewSize.height-offsetY) collectionViewLayout:carouseLayout];
    [self addSubview:_collectionView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    carouseLayout.minimumLineSpacing = 12;
    carouseLayout.minimumInteritemSpacing = 2;
    _collectionView.backgroundColor = [UIColor clearColor];
    if(isFullView)
    {
        self.backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppMain.bundle/webboard_bj.jpg"]];
        [self insertSubview:self.backImageView belowSubview:_collectionView];
        self.backImageView.frame = self.bounds;
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        cellW = (MY_SCREEN_WIDTH*0.9 -10)/2.0;
        cellH = MY_SCREEN_HEIGHT/MY_SCREEN_WIDTH * cellW+labelh;
        _collectionView.frame = CGRectMake(MY_SCREEN_WIDTH*((1-0.9)/2), 40, MY_SCREEN_WIDTH*0.9, self.viewSize.height-offsetY-20-offsetFixY);
    }
    else{
        self.backgroundColor = [UIColor clearColor];
        _collectionView.frame = self.bounds;
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        cellH = self.viewSize.height;
        cellW = MY_SCREEN_WIDTH/MY_SCREEN_HEIGHT * cellH;
    }
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CommondCell"];
  
    if(isFullView){
        float btnw=120,btnh=40,centenW=171,centenH=86;
        float fontSize = 28;
        if (IF_IPHONE) {
            btnh/=2;btnw/=2;
            fontSize/=2;
            centenW/=2;centenH/=2;
        }
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MY_SCREEN_HEIGHT-offsetY-offsetFixY, MY_SCREEN_WIDTH, offsetY)];
        self.bottomView.backgroundColor = RGB(83, 83, 83);
        [self addSubview:self.bottomView];
        
       UIButton * btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDel setFrame:CGRectMake(((MY_SCREEN_WIDTH-centenW)/2-btnw)/2, (offsetY-btnh)/2, btnw, btnh)];
        [btnDel setTitle:@"删除所有" forState:UIControlStateNormal];
        [btnDel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDel.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [btnDel addTarget:self action:@selector(removeAllWeb:) forControlEvents:UIControlEventTouchUpInside];
         [self.bottomView addSubview:btnDel];
        
        UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnBack.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        float startx = MY_SCREEN_WIDTH/2+centenW/2;
        [btnBack setFrame:CGRectMake(startx+((MY_SCREEN_WIDTH-startx)-btnw)/2, (offsetY-btnh)/2, btnw, btnh)];
        [btnBack setTitle:@"返回" forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(backWeb:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:btnBack];
        
        self.addBtnWeb = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addBtnWeb.frame = CGRectMake((MY_SCREEN_WIDTH-centenW)/2, MY_SCREEN_HEIGHT-centenH-offsetFixY, centenW, centenH);
        [self.addBtnWeb setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/web_add_flag") forState:UIControlStateNormal];
        [self addSubview:self.addBtnWeb];
        [self.addBtnWeb addTarget:self action:@selector(addNewWeb:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)removeAllWeb:(UIButton*)sender
{
    if (self.clearAllBlock) {
        self.clearAllBlock();
    }
    [self.childrenArray removeAllObjects];
    [self.collectionView reloadData];
}

-(void)backWeb:(UIButton*)sender{
    if (self.maskView || self.childrenArray.count==0) {
        if(self.childrenArray.count==0)
        self.backHomeBlock();
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    [self performSelector:@selector(delayShow) withObject:nil afterDelay:0.1];
}

-(void)addNewWeb:(id)sender{
    [MarjorWebConfig getInstance].webItemArray = nil;
    WebConfigItem *item = [[WebConfigItem alloc] init];
    item.url = @"https://cpu.baidu.com/1022/ac797dc4/i?scid=15951";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)addOneWeb:(UIView*)webViwe
{
    isCanShowSnapshot = true;
    [self createCollectView];
    if (!self.childrenArray) {
        self.childrenArray = [NSMutableArray arrayWithCapacity:1];
    }
    [bigMaskView removeFromSuperview];
    bigMaskView = nil;
    [webViwe removeFromSuperview];
    webViwe.userInteractionEnabled = false;
    if ([self.childrenArray indexOfObject:webViwe]==NSNotFound) {
      NSDictionary*info =  [NSDictionary dictionaryWithObjectsAndKeys:webViwe,ContentObject,[[ZhanWeiObjectView alloc]init],ZhanWeiObject,[NSNumber numberWithBool:!isFullView],ConetentCanAdd, nil];
        if (self.childrenArray.count==0) {
            [self.childrenArray addObject:info];
        }
        else{
            [self.childrenArray insertObject:info atIndex:0];
        }
        [self addWebToMaskView:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self reloadLastItem];
        if (isFullView) {
            bigMaskView = [[UIView alloc] init];
            [bigMaskView addSubview:webViwe];
            [KEY_WINDOW addSubview:bigMaskView];
            [bigMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(KEY_WINDOW);
            }];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            [self performSelector:@selector(delayAction:) withObject:webViwe afterDelay:0.2];
        }

    }
   self.collectionView.hidden = self.hidden = NO;
}

-(void)delayAction:(UIView*)webView{
   UICollectionViewCell *cellView = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIView *ss = [[cellView.contentView subviews] firstObject];
    ss.clipsToBounds  = YES;
    CGRect cellInCollection = [self.collectionView convertRect:ss.frame fromView:self.collectionView];
    CGRect cellInSuperview = [_collectionView convertRect:cellInCollection toView:self];
    CGPoint pointMove = CGPointMake(CGRectGetMidX(cellInSuperview)-MY_SCREEN_WIDTH/2, CGRectGetMidY(cellInSuperview)-MY_SCREEN_HEIGHT/2+labelh/2);
    [UIView animateWithDuration:0.25 animations:^{
    self->bigMaskView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(self->cellW/MY_SCREEN_WIDTH, (self->cellH-self->labelh)/MY_SCREEN_HEIGHT),CGAffineTransformMakeTranslation(pointMove.x, pointMove.y));
    }completion:^(BOOL finished) {
        [webView removeFromSuperview];
       // [self addWebOnMaskView:ss webView:webView];
        [self->bigMaskView removeFromSuperview];self->bigMaskView =nil;
        [self addWebToMaskView:[NSIndexPath indexPathForRow:0 inSection:0]];
    }];
   NSMutableDictionary *info =  [NSMutableDictionary dictionaryWithDictionary:[self.childrenArray objectAtIndex:0]];
    [info setObject:[NSNumber numberWithBool:true] forKey:ConetentCanAdd];
    [self.childrenArray replaceObjectAtIndex:0 withObject:info];
}

-(void)addWebOnMaskView:(UIView*)parentView webView:(UIView*)webView{
     webView.transform = CGAffineTransformMakeScale(cellW/MY_SCREEN_WIDTH, (cellH-labelh)/MY_SCREEN_HEIGHT);
    webView.frame = CGRectMake(0, labelh, cellW, cellH-labelh);
    [parentView addSubview:webView];
}

-(void)updateChlidWeb:(NSArray*)array popWeb:(UIView*)webView{
    self.popWeb = webView;
    isCanShowSnapshot = true;
    [self.childrenArray removeAllObjects];
    for (int i = 0; i < array.count; i++) {
        [self.childrenArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[array objectAtIndex:i],ContentObject,[[ZhanWeiObjectView alloc]init],ZhanWeiObject,[NSNumber numberWithBool:true],ConetentCanAdd, nil]];
        [self addWebToMaskView:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self createCollectView];
    [self.collectionView reloadData];
    if (self.maskView) {
        return;
    }
    self.collectionView.hidden = self.hidden = NO;
    if (webView) {
        UICollectionViewScrollPosition pos = UICollectionViewScrollPositionRight;
        if (isFullView) {
            pos = UICollectionViewScrollPositionBottom;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:pos animated:NO];
        [self performSelector:@selector(delayShow) withObject:nil afterDelay:0.1];
    }
}

-(void)delayShow {
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0  inSection:0]];
}

-(void)reloadLastItem{
    [self.collectionView reloadData];
    if (self.childrenArray.count>0) {
       
    }
}

-(void)delView:(UIView*)uiview delIndex:(NSInteger)delIndex{
    if (self.delWebViewBlock) {
        self.delWebViewBlock([[self.childrenArray objectAtIndex:delIndex]objectForKey:ContentObject ]);
    }
    [self.childrenArray removeObjectAtIndex:delIndex];
    [self reloadLastItem];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellW, cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return [self.childrenArray count];
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIView *maskView = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ZhanWeiObject];
    [cell.contentView addSubview:maskView];
    UIView *v = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ContentObject];
    if (!isCanShowSnapshot) {
        [(ContentWebView*)v showSnapshot:false];
    }
    else{
        [(ContentWebView*)v showSnapshot:isCanShowSnapshot];
    }
    float w = 51,h=64,imageW = 59,imageH=35;
    float sizeFont = 28;
    if (IF_IPHONE) {
        w/=2;h/=2;
        sizeFont/=2;
        imageW/=2;
        imageH/=2;
    }
    if (!isFullView) {
        sizeFont/=2;
        if (IF_IPAD) {
            w /=2.0;
            h/=2.0;
        }
    }
    __block UIImageViewDel *delImage = [[UIImageViewDel alloc]initWithImage:[UIImage imageNamed:@"Brower.bundle/bq_del"]];
    delImage.delIndex = indexPath.row;
    [cell.contentView addSubview:delImage];
    [delImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(w);
        make.height.mas_equalTo(h);
        if (!self->isFullView) {
            make.top.right.equalTo(cell.contentView);
        }
        else{
            make.right.equalTo(cell.contentView);
            make.top.equalTo(cell.contentView).mas_offset(self->labelh);
        }
    }];
    delImage.userInteractionEnabled = YES;
    __weak typeof(self) weakSelf = self;
    [delImage bk_whenTapped:^{
        [weakSelf delView:nil delIndex:delImage.delIndex];
    }];
    NSString *title = ((ContentWebView*)v).title;
    if ([title length]>0) {
        float y = 0;
        if(!isFullView){
            y = (cellH-labelh)/2;
            imageW = 0;
        }
        //59X35
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageW+5,y, cellW-imageW-10, labelh)];
        label.text = title;
        [cell.contentView addSubview:label];
        label.font = [UIFont systemFontOfSize:sizeFont];
        if(isFullView){
            label.textAlignment = NSTextAlignmentLeft;
            label.backgroundColor = [UIColor clearColor];}
        else{
            label.backgroundColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
        }
        label.textColor = [UIColor whiteColor];
    }
    if (isFullView) {
        UIImageView *imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageW, imageH)];
        imageIcon.image = [UIImage imageNamed:@"AppMain.bundle/max_t.png"];
        [cell.contentView addSubview:imageIcon];
    }
    
   // UIView *v = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ContentObject];
  //  [(ContentWebView*)v showSnapshot:isCanShowSnapshot];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellIdentifier = @"CommondCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *arraySubView = [cell.contentView subviews];
    [arraySubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    UIView *maskView = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ZhanWeiObject];
//    [cell.contentView addSubview:maskView];
//    UIView *v = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ContentObject];
//    if (!isCanShowSnapshot) {
//        [(ContentWebView*)v showSnapshot:false];
//    }
//    float w = 51,h=64,imageW = 59,imageH=35;
//    float sizeFont = 28;
//    if (IF_IPHONE) {
//        w/=2;h/=2;
//        sizeFont/=2;
//        imageW/=2;
//        imageH/=2;
//    }
//    if (!isFullView) {
//        sizeFont/=2;
//        if (IF_IPAD) {
//            w /=2.0;
//            h/=2.0;
//        }
//    }
//   __block UIImageViewDel *delImage = [[UIImageViewDel alloc]initWithImage:[UIImage imageNamed:@"Brower.bundle/bq_del"]];
//    delImage.delIndex = indexPath.row;
//    [cell.contentView addSubview:delImage];
//    [delImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(w);
//        make.height.mas_equalTo(h);
//        if (!self->isFullView) {
//            make.top.right.equalTo(cell.contentView);
//        }
//        else{
//            make.right.equalTo(cell.contentView);
//            make.top.equalTo(cell.contentView).mas_offset(self->labelh);
//        }
//    }];
//    delImage.userInteractionEnabled = YES;
//    __weak typeof(self) weakSelf = self;
//    [delImage bk_whenTapped:^{
//        [weakSelf delView:nil delIndex:delImage.delIndex];
//    }];
//    NSString *title = ((ContentWebView*)v).title;
//    if ([title length]>0) {
//        float y = 0;
//        if(!isFullView){
//            y = (cellH-labelh)/2;
//            imageW = 0;
//        }
//        //59X35
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageW+5,y, cellW-imageW-10, labelh)];
//        label.text = title;
//        [cell.contentView addSubview:label];
//        label.font = [UIFont systemFontOfSize:sizeFont];
//        if(isFullView){
//            label.textAlignment = NSTextAlignmentLeft;
//            label.backgroundColor = [UIColor clearColor];}
//        else{
//            label.backgroundColor = [UIColor blackColor];
//            label.textAlignment = NSTextAlignmentCenter;
//        }
//        label.textColor = [UIColor whiteColor];
//    }
//    if (isFullView) {
//        UIImageView *imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageW, imageH)];
//        imageIcon.image = [UIImage imageNamed:@"AppMain.bundle/max_t.png"];
//        [cell.contentView addSubview:imageIcon];
//    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIView *objectView = [[self.childrenArray objectAtIndex:indexPath.row] objectForKey:ContentObject];
    UICollectionViewCell *uiView =  ((UIView*)objectView).superview.superview;
    CGRect rectUI = CGRectMake((MY_SCREEN_WIDTH-cellW)/2, (MY_SCREEN_WIDTH-cellH)/2, cellW, cellH);
    BOOL isMoveCenterZero = true;
    if (uiView) {
        isMoveCenterZero = false;
        rectUI = uiView.frame;
    }
    if (self.maskView || self.childrenArray.count==0) {
        return;
    }
    self.maskView = [[UIView alloc] initWithFrame:self.bounds];
    self.maskView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskView];
    
    CGRect cellInCollection = [collectionView convertRect:rectUI fromView:collectionView];
    //获取cell在当前屏幕的位置
    
    CGRect cellInSuperview = [_collectionView convertRect:cellInCollection toView:self];
    __block  UIView* chlidView = objectView;
    chlidView.frame = cellInSuperview;
    [chlidView removeFromSuperview];
    
    [KEY_WINDOW addSubview:chlidView];
    collectionView.hidden = YES;
    self.popWeb = chlidView;
    CGPoint pointMove = CGPointMake(MY_SCREEN_WIDTH/2-chlidView.center.x, MY_SCREEN_HEIGHT/2-chlidView.center.y);
    if (isMoveCenterZero) {
        pointMove = CGPointMake(-MY_SCREEN_WIDTH/4, -MY_SCREEN_HEIGHT/4);
        chlidView.center = CGPointMake(MY_SCREEN_WIDTH/2, MY_SCREEN_HEIGHT/2);
    }
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            if (isMoveCenterZero) {
               //chlidView.frame = [[UIScreen mainScreen]bounds];
                chlidView.transform = CGAffineTransformMakeScale(1, 1);
            }
            else{
                CGAffineTransform movtrasns = CGAffineTransformMakeTranslation(pointMove.x,pointMove.y);
                if (self->isFullView) {
                    movtrasns = CGAffineTransformMakeTranslation(MY_SCREEN_WIDTH/2-chlidView.center.x, MY_SCREEN_HEIGHT/2-(chlidView.center.y-self->labelh));
                }
                chlidView.transform =CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1),movtrasns);
            }

        } completion:^(BOOL finished) {
            if (weakSelf.popWebViewBlock) {
                chlidView.frame = [[UIScreen mainScreen]bounds];
                chlidView.userInteractionEnabled = YES;
                weakSelf.popWebViewBlock(weakSelf.popWeb);
                weakSelf.hidden = YES;
                [weakSelf.childrenArray removeObjectAtIndex:indexPath.row];
                self->isCanShowSnapshot = false;
                [weakSelf.collectionView removeFromSuperview];
                weakSelf.collectionView = nil;
                [weakSelf.maskView removeFromSuperview];
                weakSelf.maskView= nil;
            }
        }];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

-(void)removeAllSnapshot{
    
}
@end
