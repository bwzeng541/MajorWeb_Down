//
//  MajorHistoryAndFavoriteAllView.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/7/31.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorHistoryAndFavoriteAllView.h"
#import "Record.h"
#import "WebUrlTailorManager.h"
#import "FileCache.h"
#import "BaseHeaderFlowLayout.h"
#import "MajorHistoryAndFavoriteCell.h"
#import "AppDelegate.h"
#import "MarjorWebConfig.h"
#define HistoryDateArrayKey @"HistoryDateArrayKey"
#define HistoryDateleftDesKey @"HistoryDateleftDesKey"
#define HistoryDateRightDesKey @"HistoryDateRightDesKey"
#define HistoryDateIsHiddenDesKey @"HistoryDateIsHiddenDesKey"

@interface MajorHistoryAndFavoriteAllView()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate,RRSwipeActionDelegate>{
    float _cellW,_cellH;
    BOOL  _isEdit;//删除状态
    BOOL  _isSwipeEdit;
    BOOL  _isTailor;//定制状态
    UIButton *_editBtn,*_tailorBtn,*_backBtn;
    UILabel  *_labledes;
    UIImageView *_imageTailorIcon;
    NSInteger _dateCount;
}
@property(nonatomic,assign)MajorShowAllContentType contentType;
@property(nonatomic,strong)UIImageView *imagehome_bc;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *listArray;
@end

@implementation MajorHistoryAndFavoriteAllView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)initBottom:(NSString *)imageName{
    self.imagehome_bc = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(imageName)];
    [self addSubview:_imagehome_bc];
    [_imagehome_bc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        float s = IF_IPAD?0.8:1;
        make.top.mas_equalTo(self).mas_offset(GetAppDelegate.appStatusBarH-20);
        make.width.mas_equalTo(MY_SCREEN_WIDTH*s);
        make.height.mas_equalTo(s*MY_SCREEN_WIDTH*(226.0/640));
    }];
}

- (void)isOpenSection:(BOOL)show ShowTag:(NSInteger)tag{
    [self.collectionView reloadData];
}

-(instancetype)initWithFrame:(CGRect)frame array:(NSArray*)list type:(MajorShowAllContentType)contentType{
    self = [super initWithFrame:frame];
    self.isUsePopGesture = true;
    _dateCount = 0;
    self.backgroundColor = [UIColor blackColor];
    [self initBottom:@"AppMain.bundle/home_back_sc_li"];
    [self initBottom:@"AppMain.bundle/show_back_top"];
    if (contentType==Major_Favortite_Type) {
        [self initBottom:@"AppMain.bundle/show_sc_top"];
    }
    else if(contentType==Major_History_Type){
        [self initBottom:@"AppMain.bundle/show_li_top"];
    }
    else if(contentType==Major_Video_Type){
        [self initBottom:@"AppMain.bundle/show_video_list"];
    }
    self.contentType = contentType;
    //删除和顶置大小一样
    float btnBackW = 69,btnBackH = 58,btnTaiW = 105,btnTaiH = 36;
    if(IF_IPHONE){
        btnBackW/=1.5;btnBackH/=1.5;btnTaiW/=1.5;btnTaiH/=1.5;
    }
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_backBtn];
    _backBtn.frame = CGRectMake(0, GetAppDelegate.appStatusBarH+20, btnBackW, btnBackH);
    [_backBtn setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_back") forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(self.frame.size.width-btnTaiW, GetAppDelegate.appStatusBarH+20, btnTaiW, btnTaiH) ;
    [_editBtn setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_list_del") forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_editBtn];
    
    
    if (_contentType==Major_Favortite_Type) {
        _tailorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _tailorBtn.frame = CGRectMake(_editBtn.frame.origin.x, _editBtn.frame.origin.y+btnTaiH*1.5, btnTaiW, btnTaiH);
        [_tailorBtn setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_tailorsc") forState:UIControlStateNormal];
        [_tailorBtn addTarget:self action:@selector(tailorClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_tailorBtn];
        
        float fontSzie = 16;
        float ww = 31,hh=27;
        if (IF_IPHONE) {
            ww/=2;hh/=2;
            fontSzie = 10;
        }
        
        _labledes = [[UILabel alloc] init];
        _labledes.textAlignment = NSTextAlignmentCenter;
        _labledes.font = [UIFont systemFontOfSize:fontSzie];
        _labledes.textColor = [UIColor blackColor];
        _labledes.backgroundColor = [UIColor whiteColor];
        _labledes.text = @"选择6个常用的站点";
        [self addSubview:_labledes];
        [_labledes mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            if (IF_IPHONE) {
                make.width.mas_equalTo(100);
            }
            else{
                make.width.mas_equalTo(150);
            }
            make.height.mas_equalTo(hh);
            make.top.equalTo(self.imagehome_bc.mas_bottom).mas_offset(10-hh);
        }];
        
        _imageTailorIcon = [[UIImageView alloc]initWithImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_tailoricon")];
        
        [self addSubview:_imageTailorIcon];
        [_imageTailorIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self->_labledes.mas_left).mas_offset(-5);
            make.width.mas_equalTo(ww);
            make.height.mas_equalTo(hh);
            make.top.equalTo(self->_labledes.mas_top);
        }];
        
        _imageTailorIcon.hidden = _labledes.hidden = YES;
    }
    if (_contentType==Major_History_Type || _contentType==Major_Video_Type) {
        float hh = 36;
        if (IF_IPHONE) {
            hh=50;
        }
        BaseHeaderFlowLayout * carouseLayout = [[BaseHeaderFlowLayout alloc] init];
        carouseLayout.sectionHeadersPinToVisibleBoundsAll = YES;
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
        carouseLayout.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, hh);  //设置headerView大小
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];  //  一定要设置
        self.listArray = [NSMutableArray arrayWithArray:[self getSortArray:list]];
        
       UIButton* _delAll = [UIButton buttonWithType:UIButtonTypeCustom];
        _delAll.frame = CGRectMake(_editBtn.frame.origin.x, _editBtn.frame.origin.y+btnTaiH*1.5, btnTaiW, btnTaiH);
        [_delAll setImage:UIImageFromNSBundlePngPath(@"AppMain.bundle/home_list_delAll") forState:UIControlStateNormal];
        __weak __typeof(self)weakSelf = self;
        [_delAll bk_addEventHandler:^(id sender) {
            [weakSelf showDelAlter];
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_delAll];
    }
    else{
        UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        carouseLayout.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, 5);
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        self.listArray = [NSMutableArray arrayWithArray:list];
    }
    [self.collectionView registerClass:[MajorHistoryAndFavoriteCell class] forCellWithReuseIdentifier:@"ButtonCell"];
    
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.rr_swipeActionDelegate = self;
    self.collectionView.scrollEnabled = YES;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self->_contentType==Major_Video_Type)
        {
            make.centerX.bottom.equalTo(self);
            make.right.equalTo(self.mas_right).mas_offset(-10);
            make.left.equalTo(self.mas_left).mas_offset(10);
            self.collectionView.showsVerticalScrollIndicator = NO;
        }
        else {
            make.centerX.width.bottom.equalTo(self);
        }
        if (self->_contentType==Major_Favortite_Type) {
            make.top.equalTo(self->_imageTailorIcon.mas_bottom).mas_offset(0);
        }
        else{
            make.top.equalTo(self.imagehome_bc.mas_bottom);
        }
    }];
    if (self->_contentType==Major_Video_Type) {
        UIView *backW = [[UIView alloc] init];
        [self insertSubview:backW belowSubview:self.collectionView];
        backW.backgroundColor = [UIColor whiteColor];
        [backW mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.width.bottom.equalTo(self);
            make.top.equalTo(self.imagehome_bc.mas_bottom);
        }];
    }
    float w = [[UIScreen mainScreen]bounds].size.width;
    if (self->_contentType==Major_Video_Type)
    {
        w = w- 40;
    }
    else{
        w = w- 20;
    }
    float number = 1;
    _cellW = w /number;
    _cellH = 30;
    if (Major_Video_Type==_contentType) {
        number = IF_IPAD?3:2;
        _cellW = w /number;
        _cellH = _cellW * 0.56*1.6;//16:9
    }
    _isEdit = false;
    [self.collectionView reloadData];
    return self;
}

-(void)showDelAlter{
    __weak __typeof(self)weakSelf = self;
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否删除所有数据?" message:nil];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                                   
                                               }];
    [alertView addAction:v];
    v  = [TYAlertAction actionWithTitle:@"删除"
                                  style:TYAlertActionStyleDefault
                                handler:^(TYAlertAction *action) {
                                    [weakSelf delAll];
                                 }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}

-(void)delAll{
    if (self.contentType==Major_History_Type) {
        [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABLE_HISRECORD];
        [[MarjorWebConfig getInstance] removeSearchHots];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
        [self.listArray removeAllObjects];
        [self.collectionView reloadData];
    }
    else if (self.contentType==Major_Video_Type){
        [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY];
        GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
        GetAppDelegate.isVideoHistoryUpdate = !GetAppDelegate.isVideoHistoryUpdate;
        [self.listArray removeAllObjects];
        [self.collectionView reloadData];
    }
}

-(void)tailorClick:(UIButton*)sender{
    _isTailor = !_isTailor;
    _imageTailorIcon.hidden = _labledes.hidden = !_isTailor;
    if (_isTailor) {
        [_tailorBtn setImage: UIImageFromNSBundlePngPath(@"AppMain.bundle/home_tailorsc_c") forState:UIControlStateNormal];
        _editBtn.hidden = YES;
    }
    else{
        _editBtn.hidden = NO;
        [_tailorBtn setImage: UIImageFromNSBundlePngPath(@"AppMain.bundle/home_tailorsc") forState:UIControlStateNormal];
    }
}

-(void)updateSectionState:(NSInteger)index{
    NSMutableDictionary *info = [self.listArray objectAtIndex:index];
    BOOL retNew = ![[info objectForKey:HistoryDateIsHiddenDesKey] boolValue];
    [info setObject:[NSNumber numberWithBool:retNew] forKey:HistoryDateIsHiddenDesKey];
    [self.collectionView reloadData];
}

-(void)delRecordFrom:(NSIndexPath*)indexPath{
    if (_contentType==Major_Favortite_Type) {
        [self.listArray removeObjectAtIndex:indexPath.row];
    }
    else if(_contentType==Major_History_Type || _contentType==Major_Video_Type){
        [[[self.listArray objectAtIndex:indexPath.section] objectForKey:HistoryDateArrayKey] removeObjectAtIndex:indexPath.row];
    }
}

-(Record*)getRecordFrom:(NSIndexPath *)indexPath
{
    Record *record = nil;
    if (_contentType==Major_Favortite_Type) {
        record = [self.listArray objectAtIndex:indexPath.row];
    }
    else{
        record = [[[self.listArray objectAtIndex:indexPath.section] objectForKey:HistoryDateArrayKey] objectAtIndex:indexPath.row];
    }
    return record;
}

-(void)editClick:(UIButton*)sender
{
    _isTailor = false;
    _imageTailorIcon.hidden = _labledes.hidden = !_isTailor;
    _isEdit = !_isEdit;
    _tailorBtn.hidden = _isEdit;
    [self.collectionView reloadData];
}

-(void)backClick:(UIButton*)sender{
    if (self.backBlock) {
        self.backBlock();
    }
}

-(NSMutableAttributedString*)getAttributedFromText:(NSString*)str fontSize:(float)fontSize{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    UIFont *defaultfont = nil;
    NSLog(@"str = %@",str);
    defaultfont = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize] ;
    [attrStr addAttribute:NSFontAttributeName
                    value:defaultfont
                    range:NSMakeRange(0, [str length])];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:DKColorPickerWithKey(NEWSTITLE)([DKNightVersionManager sharedManager].themeVersion)
                    range:NSMakeRange(0, [str length])];
    
    NSRange range1 = [str rangeOfString:@"《"];
    NSRange range2 = [str rangeOfString:@"》"];
    if (range1.location!=NSNotFound && range2.location!=NSNotFound && range2.location>range1.location) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(0, 0, 255) range:NSMakeRange(range1.location, range2.location-range1.location)];
    }
    return attrStr;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_contentType==Major_Favortite_Type) {
        return 1;
    }
    else{
        return [self.listArray count];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_cellW, _cellH+5);
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    [[headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_contentType==Major_Favortite_Type) {
        return headerView;
    }
    
    NSDictionary *info = [self.listArray objectAtIndex:indexPath.section];
    float sizeFont = 22;
    if (IF_IPHONE) {
        sizeFont = 16;
    }
    if (self->_contentType==Major_Video_Type) {
        sizeFont *= (IF_IPAD?0.9:1.7);
    }
    UILabel *labelLeft = [[UILabel alloc] initWithFrame:headerView.bounds];
    labelLeft.text = [info objectForKey:HistoryDateleftDesKey];
    [headerView addSubview:labelLeft];
    labelLeft.textAlignment = NSTextAlignmentLeft;
    labelLeft.font = [UIFont systemFontOfSize:sizeFont];
    labelLeft.textColor = [UIColor blackColor];
    
    UILabel *labelRight = [[UILabel alloc] initWithFrame:headerView.bounds];
    labelRight.text = [info objectForKey:HistoryDateRightDesKey];
    labelRight.tag = indexPath.section;
    labelRight.userInteractionEnabled =YES;
    __weak __typeof(self)weakSelf = self;
    [labelRight bk_whenTapped:^{
        [weakSelf updateSectionState:labelRight.tag];
    }];
    [headerView addSubview:labelRight];
    labelRight.textAlignment = NSTextAlignmentRight;
    labelRight.font = [UIFont systemFontOfSize:sizeFont];
    labelRight.textColor = [UIColor blackColor];
    headerView.backgroundColor = RGBCOLOR(203, 203, 203);
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_contentType==Major_Favortite_Type){
        return [self.listArray count];
    }
    else{
        NSDictionary*info = [self.listArray objectAtIndex:section];
        if ([[info objectForKey:HistoryDateIsHiddenDesKey]boolValue]) {
            return 0;
        }
        return [[info objectForKey:HistoryDateArrayKey] count];
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellIdentifier = @"ButtonCell";
    if(_contentType==Major_History_Type){
        CellIdentifier = @"ButtonCell";
    }
    MajorHistoryAndFavoriteCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *imageName = @"AppMain.bundle/home_ls";
    if (_contentType==Major_Favortite_Type) {
        imageName = @"AppMain.bundle/home_favorite";
    }
    BOOL isTaile = false;
    Record *record = [self getRecordFrom:indexPath];
    if (_contentType==Major_Favortite_Type) {
        isTaile = [WebUrlTailorManager isWebUrlTailor:record.titleName url:record.titleUrl];
        if (isTaile) {
            imageName= @"AppMain.bundle/home_tailoricon";
        }
    }
    if (_isEdit) {
        imageName= @"AppMain.bundle/home_cell_del";
    }
    float ww = 33;
    float fontSize = 16;
    if (IF_IPHONE) {
        ww/=2;
        fontSize = 12*AppScaleIphoneH;
    }
    
    if (_contentType!=Major_Video_Type) {
        UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0,(_cellH-ww)/2, ww, ww)];
        imageView.image = [UIImage imageNamed:imageName];
        [cell.contentView addSubview:imageView];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+3, 0, _cellW-(imageView.frame.origin.x+imageView.frame.size.width+3), _cellH)];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.dk_textColorPicker = DKColorPickerWithKey(NEWSTITLE);
        [cell.contentView addSubview:label];
        label.attributedText =  [self getAttributedFromText:record.titleName fontSize:18];
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+3, _cellH/2, _cellW-(imageView.frame.origin.x+imageView.frame.size.width+3), _cellH)];
            label.textAlignment = NSTextAlignmentLeft;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label];
            label.font = [UIFont systemFontOfSize:fontSize/1.5];
            label.text =  record.titleUrl;
        }
        [cell initVideoInfo:nil url:nil time:nil base64Png:nil];
    }
    else{//video
        [cell initVideoInfo:record.titleName url:record.titleUrl time:record.dateStr base64Png:record.iconStr];
        [cell updateDelBtn:_isEdit rect:CGRectMake((_cellW-ww*3)/2,(_cellH-ww*3)/2, ww*3, ww*3)];
    }
    return cell;
}

- (void)rr_collectionViewEditChange:(UICollectionView *)collectionView eidtState:(BOOL)eidtState{
    _isSwipeEdit = eidtState;
}

- (nullable NSArray<RRSwipeAction *> *)rr_collectionView:(UICollectionView *)collectionView swipeActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_contentType == Major_Video_Type) {
        return nil;
    }
    if (!indexPath.item) {
        return nil;
    }
    __weak typeof(self) weak_self = self;
    RRSwipeAction *remove = [[RRSwipeAction alloc] initWithTitle:@"删除" titleColor:UIColor.whiteColor backgroundColor:UIColor.redColor handler:^{
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self removeDataFrom:indexPath];
    }];
    return @[remove];
}


- (NSArray*)getSortArray:(NSArray*)historylist{
    //新数据分类
    NSMutableArray *arrayRet = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *dataInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    for (int i = 0; i < historylist.count; i++) {
        Record*recd = [historylist objectAtIndex:i];
        NSString *dateStr = [recd.dateStr substringToIndex:8];
        NSMutableDictionary *newInfo = [dataInfo objectForKey:dateStr];
        if(!newInfo){
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSDate *resDate = [formatter dateFromString:recd.dateStr];
            NSDate *oldDate = [formatter dateFromString:recd.dateStr];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: resDate];
            resDate = [resDate  dateByAddingTimeInterval: interval];
            
            NSString *leftDes = @"";
            NSString *rightDes = @"";
            NSArray *weekDaydes = [[oldDate formattedDateWithStyle:NSDateFormatterFullStyle] componentsSeparatedByString:@" "];
            if ([weekDaydes count]>=2) {
                leftDes =  [weekDaydes objectAtIndex:0];
                rightDes = [weekDaydes objectAtIndex:1];
            }
            if ([oldDate isToday]) {
                if(self.contentType==Major_History_Type)
                    leftDes = @"今日阅读";
                else if (self.contentType==Major_Video_Type)
                    leftDes = @"播放记录";
            }
            else{
                
            }
            newInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray arrayWithCapacity:1],HistoryDateArrayKey,leftDes,HistoryDateleftDesKey,rightDes,HistoryDateRightDesKey,[NSNumber numberWithBool:false],HistoryDateIsHiddenDesKey, nil];
            [dataInfo setObject:newInfo forKey:dateStr];
        }
        [[newInfo objectForKey:HistoryDateArrayKey] addObject:recd];
    }
    
    NSArray *testArr = [[dataInfo allKeys]  sortedArrayWithOptions:NSSortStable usingComparator:
                        ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                            NSInteger value1 = [obj1 integerValue];
                            NSInteger value2 = [obj2 integerValue];
                            if (value1 < value2) {
                                return NSOrderedDescending;
                            }else if (value1 == value2){
                                return NSOrderedSame;
                            }else{
                                return NSOrderedAscending;
                            }
                        }];
    for (int i = 0; i <testArr.count; i++) {
        [arrayRet addObject:[dataInfo objectForKey:[testArr objectAtIndex:i]]] ;
    }
    return arrayRet;
}

- (void)removeDataFrom:(NSIndexPath*)indexPath{
    Record *record = [self getRecordFrom:indexPath];
    NSString *num = record.titleNum;
    if(_contentType==Major_History_Type){
        [FileCache deleteAllDBDataByTitleNum:KEY_DATENAME TableName:KEY_TABLE_HISRECORD TitleNum:num];
    }
    else if(_contentType==Major_Favortite_Type){
        [WebUrlTailorManager delWebUrlTailor:record.titleName url:record.titleUrl];
        [FileCache deleteAllDBDataByTitleNum:KEY_DATENAME TableName:KEY_TABLE_LOCAL TitleNum:num];
    }
    else if(_contentType==Major_Video_Type){
        [FileCache deleteAllDBDataByTitleNum:KEY_DATENAME TableName:KEY_TABEL_VIDEOHISTORY TitleNum:num];
        GetAppDelegate.isVideoHistoryUpdate = !GetAppDelegate.isVideoHistoryUpdate;
    }
    [self delRecordFrom:indexPath];
    __weak __typeof(self)weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Record *record = [self getRecordFrom:indexPath];
    if (!_isEdit && !_isTailor && self.liveClickBlock) {
        self.liveClickBlock(record.titleUrl,record.titleName);
        [self.collectionView reloadData];
    }
    else if (_isTailor){
        NSArray *array = [[collectionView cellForItemAtIndexPath:indexPath].contentView subviews];
        //找到uiimageView图替换
        BOOL isTaile = [WebUrlTailorManager isWebUrlTailor:record.titleName url:record.titleUrl];
        NSString * imageName = @"AppMain.bundle/home_favorite";
        if(isTaile){
            [WebUrlTailorManager delWebUrlTailor:record.titleName url:record.titleUrl];
        }
        else{
            BOOL ret = [WebUrlTailorManager insertWebUrlTailor:record.titleName url:record.titleUrl];
            if (ret) {
                imageName = @"AppMain.bundle/home_tailoricon";
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"只能置顶6个网页"
                                          message:nil
                                          delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        for (int i = 0; i < array.count; i++) {
            if( [[array objectAtIndex:i] isKindOfClass:[UIImageView class]]){
                ((UIImageView*)[array objectAtIndex:i]).image =UIImageFromNSBundlePngPath(imageName);
                break;
            }
        }
    }
    else if (_isEdit)//删除
    {
        [self removeDataFrom:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 2;
    }
    return 2;
}

//手势处理
- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer {
    if (_isEdit || _isSwipeEdit) {
        return;
    }
    [super doMoveAction:recognizer];
}
//end
@end
