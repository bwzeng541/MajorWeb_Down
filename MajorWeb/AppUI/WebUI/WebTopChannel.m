
#import "WebTopChannel.h"
#import "ReactiveCocoa.h"
#import "MajorModeDefine.h"
#import "MoreSelectWeb.h"
#import "VipPayPlus.h"
#define SouSouUIImageViewTag 10
#define SouSouUILabelViewTag 11


@interface WebTopChannel()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSInteger selectIndex ;
}
@property(nonatomic,strong)UIButton *adBlockbtn;
@property(nonatomic,strong)MoreSelectWeb *webSelectWeb;
@property(nonatomic,strong)NSArray *urlNativeArray;
@property(nonatomic,strong)UIButton *showListBtn;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,assign)UICollectionViewScrollDirection direction;
@end
@implementation WebTopChannel

-(void)dealloc{
    self.urlNativeArray = nil;
    self.collectionView = nil;
    self.showListBtn = nil;
    NSLog(@"%s",__FUNCTION__);
}

-(void)removeFromSuperview{
    self.clickBlock = nil;
    self.feeBackBlock = nil;
    self.moreBlock = nil;
    [super removeFromSuperview];
}

-(void)addAdBlockUI:(BOOL)isAdd{
    if (self.urlNativeArray.count>0) {
        if (isAdd && !self.adBlockbtn) {
            self.adBlockbtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:self.adBlockbtn];
            CGSize size = self.bounds.size;
            float h = size.height*0.8;
            [self.adBlockbtn setFrame:CGRectMake(0,(size.height-h)/2,174/30.0*size.height*0.8,h)];
            [self.adBlockbtn setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/tijiao") forState:UIControlStateNormal];
            [self.adBlockbtn addTarget:self action:@selector(showFeeBlockAlter) forControlEvents:  UIControlEventTouchUpInside];
        }
        else if(!isAdd){
            RemoveViewAndSetNil(self.adBlockbtn);
        }
    }
    else{
        if (isAdd) {
            self.hidden =  NO;
        }
        else{
            self.hidden =  YES;
        }
    }
}

-(id)initWithAdBlockView:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBCOLOR(0, 0, 0);
    //174X30;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float h = frame.size.height*0.8;
    [btn setFrame:CGRectMake(0,(frame.size.height-h)/2,174/30.0*frame.size.height*0.8,h)];
    [btn setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/tijiao") forState:UIControlStateNormal];
    [self addSubview:btn];
    UILabel *des = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x+btn.frame.size.width, 0, frame.size.width-(btn.frame.origin.x+btn.frame.size.width), frame.size.height)];
    des.text = @"提交后，我们将尽快屏蔽此网站广告";
    des.textColor = [UIColor whiteColor];
    [self addSubview:des];
    des.adjustsFontSizeToFitWidth = YES;
    __weak __typeof(self)weakSelf = self;
    [btn bk_addEventHandler:^(id sender) {
        [weakSelf showFeeBlockAlter];
    } forControlEvents:UIControlEventTouchUpInside];
    return self;
}

-(void)showFeeBlockAlter{
    if(self.feeBackBlock){
        [[VipPayPlus getInstance] showWithUrlAndFeeAlter:self.feeBackBlock()];
    }
}

//film_sousuo_btn.png
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    selectIndex = -1;
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(@"Brower.bundle/nav_b")];
    backImageView.frame = self.bounds;
    [self addSubview:backImageView];
    [self createDirectionCollection:UICollectionViewScrollDirectionHorizontal];
    self.showListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.showListBtn];
    UIImage *image = [UIImage imageNamed:@"Brower.bundle/more_list.png"];
    [self.showListBtn setImage:image forState:UIControlStateNormal];
    [self.showListBtn addTarget:self action:@selector(showList:) forControlEvents:  UIControlEventTouchUpInside];
    //184X72
    [self addJustCollectionFrame];
    return self;
}

-(void)createDirectionCollection:(UICollectionViewScrollDirection)direction{
    RemoveViewAndSetNil(self.collectionView);
    self.direction = direction;
    UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:fallLayout];
    fallLayout.scrollDirection = direction;
    fallLayout.minimumInteritemSpacing =1;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    [self.collectionView setCollectionViewLayout:fallLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"WebTopChannel"];
    [self addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

-(void)addJustCollectionFrame{
    float btnH = self.bounds.size.height*0.8;
    float btnW = btnH/(66.0/129.0);
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.top.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self).mas_offset(-btnW-5);
    }];
    //btn 129X66
    [self.showListBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(btnH);
        make.width.mas_equalTo(btnW);
    }];
}

-(void)hiddenMore{
    self.showListBtn.hidden  = YES;
}

-(void)updateVertical{
    [self createDirectionCollection:(UICollectionViewScrollDirectionVertical)];
}

//加载一个选择所有网页的数据列表
-(void)showList:(UIButton*)sender{
    if (!self.webSelectWeb) {
        __weak __typeof(self)weakSelf = self;
        self.webSelectWeb = [[MoreSelectWeb alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT)
                                                     selectBlock:^(id  _Nonnull panel) {
                                                         [weakSelf clickFromMoreSelect:panel];
                                                     }];
        [self.superview addSubview:self.webSelectWeb];
        if (self.moreBlock) {
            self.moreBlock();
        }
    }
}

-(void)clickFromMoreSelect:(NSArray*)array{
    if (array.count>0) {
        [self updateTopArray:array];
        [self updateSelect:0];
        [self loadSouSouItem:0];
    }
    RemoveViewAndSetNil(self.webSelectWeb);
}


-(void)clickAddWeb:(UIButton*)sender{
    
}


-(void)updateTopArray:(NSArray*)topArray{
    self.urlNativeArray = topArray;
    [self.collectionView reloadData];
}

-(void)updateSelect:(NSInteger)index{
    if (index<self.urlNativeArray.count)
    {
        selectIndex = index;
        [self.collectionView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    else{
        selectIndex = -1;
        [self.collectionView reloadData];
    }
}


-(void)loadSouSouItem:(NSInteger)index{
    if (index<[self.urlNativeArray count] && self.clickBlock) {
        self.clickBlock([self.urlNativeArray objectAtIndex:0]);
    }
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.clickBlock) {
        WebConfigItem *clickItem =  [self.urlNativeArray objectAtIndex:indexPath.row];
        BOOL isCanClick = false;
        isCanClick = true;
        if ( isCanClick) {
            self.clickBlock(clickItem);
            if (selectIndex>=0  && selectIndex<self.urlNativeArray.count)
            {
                UICollectionViewCell *cellView = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]];
                UILabel *label = [cellView viewWithTag:SouSouUILabelViewTag];
                if ([self.delegate respondsToSelector:@selector(unSelectColor)]) {
                    label.textColor = [self.delegate unSelectColor];
                }
                else {
                    label.textColor = [UIColor whiteColor];
                }
            }
            selectIndex = indexPath.row;
            UICollectionViewCell *cellView = [collectionView cellForItemAtIndexPath:indexPath];
            UILabel *label = [cellView viewWithTag:SouSouUILabelViewTag];
            if ([self.delegate respondsToSelector:@selector(selectColor)]) {
                label.textColor = [self.delegate selectColor];
            }
            else{
                label.textColor = RGBCOLOR(0, 250, 180);
            }
            if ([self.delegate respondsToSelector:@selector(selectFontSize)]) {
                label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[self.delegate selectFontSize]];
            }
            else{
                label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
            }
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cellView = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = [cellView viewWithTag:SouSouUILabelViewTag];
    if ([self.delegate respondsToSelector:@selector(unSelectColor)]) {
        label.textColor = [self.delegate unSelectColor];
    }
    else {
        label.textColor = [UIColor whiteColor];
    }
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.urlNativeArray count];
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"WebTopChannel";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
     [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [cell.contentView viewWithTag:SouSouUILabelViewTag];
    if (!label) {
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        [cell.contentView addSubview:label];
        label.tag = SouSouUILabelViewTag;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(cell.contentView);
        }];
    }
    if (selectIndex>=0 && selectIndex==indexPath.row && selectIndex<self.urlNativeArray.count) {
        if ([self.delegate respondsToSelector:@selector(selectColor)]) {
            label.textColor = [self.delegate selectColor];
        }
        else{
            label.textColor = RGBCOLOR(0, 250, 180);
        }
        if ([self.delegate respondsToSelector:@selector(selectFontSize)]) {
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[self.delegate selectFontSize]];
        }
        else{
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(unSelectFontSize)]) {
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[self.delegate unSelectFontSize]];
        }
        else{
            label.font = [UIFont systemFontOfSize:12];
        }
        if ([self.delegate respondsToSelector:@selector(unSelectColor)]) {
            label.textColor = [self.delegate unSelectColor];
        }
        else {
            label.textColor = [UIColor whiteColor];
        }
    }
     label.textAlignment = NSTextAlignmentCenter;
    WebConfigItem *sousouItem = [self.urlNativeArray objectAtIndex:indexPath.row];
    label.text = sousouItem.name;
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    WebConfigItem *sousouItem = [self.urlNativeArray objectAtIndex:indexPath.row];
    NSString *text = sousouItem.name;
    CGSize size = [text boundingRectWithSize:CGSizeMake(200,  200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font} context:nil].size;
    return CGSizeMake(size.width+30, (_direction == UICollectionViewScrollDirectionHorizontal)?self.bounds.size.height:30);
    
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

@end
