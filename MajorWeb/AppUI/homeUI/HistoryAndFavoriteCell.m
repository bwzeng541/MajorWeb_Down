
#import "HistoryAndFavoriteCell.h"
#import "AppDelegate.h"
#import "Record.h"
#import "FileCache.h"
#import "MajorRecordContentView.h"
@interface HistoryAndFavoriteCell()<UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource,UICollectionViewDelegate>{
    float _cellW,_cellH;
    float _column;
    BOOL  _isEdit;
    UILabel *_btnLishi,*_btnsc;
    CGSize titleNameSize;
}
@property(nonatomic,copy)NSString *titleName;
@property(nonatomic,assign)float cellSizeH;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *listArray;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) MajorShowAllContentType contentType;

@end

@implementation HistoryAndFavoriteCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    return self;
}
-(void)initListArray:(NSArray*)array name:(NSString*)name contentType:(MajorShowAllContentType)contentType{
    if (!self.collectionView) {
        self.contentType = contentType;
        self.titleName = name;
        UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
        if(contentType == Major_Video_Type)
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        else
        carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
        [self addSubview:self.collectionView];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.scrollEnabled = (contentType == Major_Video_Type);
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ButtonCell"];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);make.bottom.equalTo(self).mas_offset(-20);
            float offsetW = 20;
            if (self->_contentType==Major_Video_Type) {
                offsetW = 0;
            }
            make.right.equalTo(self).mas_offset(-offsetW);
            make.left.equalTo(self).mas_offset(offsetW);
            if (IF_IPHONE) {
                if (self->_contentType == Major_Video_Type) {
                    self->_cellSizeH = 16+30;
                }
                else{
                    self->_cellSizeH = 16+30;
                    make.top.equalTo(self).mas_offset(self->_cellSizeH);
                }
            }
            else{
                if (self->_contentType == Major_Favortite_Type) {
                    self->_cellSizeH = 16+30;
                }
                else{
                    self->_cellSizeH = 16+50;
                }
                make.top.equalTo(self).mas_offset(self->_cellSizeH);
            }
        }];
        if (true) {
            UILabel *label = [[UILabel alloc]init];
            [self addSubview:label];
            label.textAlignment = NSTextAlignmentLeft;
            label.backgroundColor = [UIColor clearColor];
              UIFont *font = nil;
            if (IF_IPHONE) {
                font = [UIFont fontWithName:@"Helvetica-Bold" size:16*AppScaleIphoneH];
             }
            else{
                font = [UIFont fontWithName:@"Helvetica-Bold" size:24*AppScaleIpadH];
             }
           
            label.attributedText = [self attributedStringFromText:name font:font] ;
            
            titleNameSize = [name boundingRectWithSize:CGSizeMake(200,  200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font} context:nil].size;
            
            self.headLabel = label;
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).mas_offset(20);
                make.bottom.equalTo(self.collectionView.mas_top);
                make.top.equalTo(self).mas_offset(10);
                make.width.equalTo(self).mas_offset(-40).multipliedBy(0.33);
            }];
            
            if ([self.titleName compare:@"播放记录"]==NSOrderedSame) {
                
                _btnLishi = [[UILabel alloc] init];
                NSString *text = @"历史记录";
                 _btnLishi.attributedText = [self attributedStringFromText:text font:font];
                _btnLishi.textAlignment = NSTextAlignmentLeft;
                _btnLishi.backgroundColor = [UIColor clearColor];
                _btnLishi.adjustsFontSizeToFitWidth = YES;
                [self addSubview:_btnLishi];
                [_btnLishi mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.bottom.equalTo(self.collectionView.mas_top);
                    make.top.equalTo(self).mas_offset(10);
                    make.width.equalTo(self).mas_offset(-40).multipliedBy(0.33);
                }];
                 text = @"我的收藏";
                 _btnsc = [[UILabel alloc] init];
                _btnsc.attributedText = [self attributedStringFromText:text font:font];
                _btnsc.textAlignment = NSTextAlignmentLeft;
                _btnsc.backgroundColor = [UIColor clearColor];
                [self addSubview:_btnsc];
                _btnsc.adjustsFontSizeToFitWidth = YES;
                [_btnsc mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).mas_equalTo(-20);
                    make.bottom.equalTo(self.collectionView.mas_top);
                    make.top.equalTo(self).mas_offset(10);
                    make.width.equalTo(self).mas_offset(-40).multipliedBy(0.33);
                }];
                self.headLabel.userInteractionEnabled = YES;
                self.headLabel.adjustsFontSizeToFitWidth = YES;
                __weak typeof(self)weakSelf = self;
                [self.headLabel bk_whenTapped:^{
                    [weakSelf showAllList];
                }];
            }
        }
        //查看所有
        NSString *rightText = @"查看所有";
        if (Major_UserHomeMain_Type==contentType) {
            rightText = @"编辑";
        }
        if ([self.titleName compare:@"播放记录"]==NSOrderedSame) {
            rightText = @"";
        }
        if (true){
                UILabel *label = [[UILabel alloc]init];
                [self addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).mas_offset(-5);
                    make.bottom.equalTo(self.collectionView.mas_top);
                    make.top.equalTo(self).mas_offset(10);
                    make.width.mas_equalTo(100);
                }];
                label.font = [UIFont systemFontOfSize:12];
                label.textAlignment = NSTextAlignmentRight;
                label.backgroundColor = [UIColor clearColor];
                label.text = rightText ;
                label.textColor = RGBCOLOR(159, 159, 159);
                if (IF_IPHONE) {
                    label.font = [UIFont systemFontOfSize:10*AppScaleIphoneH];
                }
                else{
                    label.font = [UIFont systemFontOfSize:12*AppScaleIpadH];
                }
                label.userInteractionEnabled = YES;
                __weak typeof(self)weakSelf = self;
                [label bk_whenTapped:^{
                    [weakSelf showAllList];
                }];
         }
        //end
        UIView *bottomLineView = [[UIView alloc]init];
        [self addSubview:bottomLineView];
        [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.right.equalTo(self).mas_offset(-20);
            make.left.equalTo(self).mas_offset(20);
            if(IF_IPAD)
            {
                make.height.mas_equalTo(1);
                make.bottom.equalTo(self.mas_bottom);
            }
            else
            {
                make.height.mas_equalTo(1);
                make.bottom.equalTo(self.mas_bottom).mas_offset(-1);
            }
        }];
        bottomLineView.backgroundColor = RGBCOLOR(255, 255, 255);
    }
    _isEdit = false;
    self.selectIndex = -1;
    float w = self.bounds.size.width;
    w = w- 40;
    _column = 1;
    if (IF_IPHONE) {
        _column = 1;
    }
    _cellW = w /_column;
    _cellH = 30;
    if (_contentType==Major_Video_Type) {
        _cellH = 80;
        _cellW = 142;
    }
    else if (_contentType == Major_UserHomeMain_Type){
        _column = 4;
        //创建cel
        float w = self.bounds.size.width;
        w = w- 60;
        _cellW = w /_column;
        _cellH = 32;
    }
    self.listArray = array;
    [self updatePanelSize];
    [self.collectionView reloadData];
    [self bringSubviewToFront:_btnsc];
    [self bringSubviewToFront:_btnLishi];
    __weak typeof(self)weakSelf = self;
    _btnLishi.userInteractionEnabled = YES;
    [_btnLishi bk_whenTapped:^{
        [weakSelf clickHistory];
    }];
    _btnsc.userInteractionEnabled = YES;
    [_btnsc bk_whenTapped:^{
        [weakSelf clickSc];
    }];
}

-(void)clickHistory{
    if (self.historyShowBlock) {
        self.historyShowBlock();
    }
}

-(void)clickSc{
    if (self.favoriteShowBlock) {
        self.favoriteShowBlock();
    }
}

-(NSMutableAttributedString*)attributedStringFromText:(NSString*)text font:(UIFont*)font{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange rangeHeader = NSMakeRange(0, [text length]);
    [attrStr addAttribute:NSFontAttributeName
                    value:font
                    range:rangeHeader];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:RGBCOLOR(0, 0, 0)
                    range:rangeHeader];
    return attrStr;
}

- (void)updatePanelSize{
    if (IF_IPHONE) {
        if (Major_Favortite_Type == _contentType) {
            _cellSizeH = (16+40);
        }
        _cellSizeH = (16+30);
    }
    else{
        _cellSizeH =(16+50);
    }
    _cellSizeH+=20;
    float _oldSizeH = _cellSizeH;
    NSInteger maxCount = self.listArray.count>4?4:self.listArray.count;
    if (self->_contentType == Major_Favortite_Type) {
        maxCount = self.listArray.count>4?4:self.listArray.count;
    }
    else if (self->_contentType==Major_Video_Type){
        maxCount = self.listArray.count>10?10:self.listArray.count;
    }
    else if (self->_contentType==Major_UserHomeMain_Type){
        maxCount = self.listArray.count>12?12:self.listArray.count;
    }
    NSInteger line = [self getRows:maxCount columns:_column];
    if (self->_contentType==Major_Video_Type){
        line=line>1?1:line;
    }
    if (_oldSizeH!=_cellSizeH+(line*(_cellH+2))) {
        self.cellSizeH = _cellSizeH+(line*(_cellH+2));
    }
    else{
        _cellSizeH = _oldSizeH;
    }
    if (self->_contentType==Major_Video_Type && maxCount==0){
        _cellSizeH = 0;
    }
    if (line==0) {
        if ([self.titleName compare:@"播放记录"]==NSOrderedSame) {
            _cellSizeH = 45;
            if (IF_IPAD) {
                _cellSizeH = 60;
            }
        }
        else{
            _cellSizeH = 0;
        }
    }
}

-(NSInteger)getRows:(NSInteger)size columns:(NSInteger)columns{
    if (size < 1 || columns < 1)
        return 0;
    // 整除
    BOOL isDivisible = (size % columns) == 0;
    if (isDivisible) {
        return size / columns;
    } else {
        return size / columns + 1;
    }
}


- (void)showAllList{
    if (_contentType == Major_UserHomeMain_Type) {
        _isEdit = !_isEdit;
        [self.collectionView reloadData];
        return;
    }
    if (self.liveShowBlock) {
        self.liveShowBlock(self.listArray, _contentType);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_cellW, _cellH);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_contentType == Major_Video_Type) {
        return [self.listArray count]>10?10:[self.listArray count];
    }
    else if (_contentType == Major_Favortite_Type) {
        return [self.listArray count]>4?4:[self.listArray count];
    }
    else if (self->_contentType==Major_UserHomeMain_Type){
        return [self.listArray count]>12?12:[self.listArray count];
    }
    return [self.listArray count]>4?4:[self.listArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ButtonCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_contentType != Major_Video_Type) {
        NSString *imageName = @"AppMain.bundle/home_ls";
        if (_contentType == Major_Favortite_Type) {
            imageName = @"AppMain.bundle/home_favorite";
        }
        float ww = 23;
        float fontSize = 16;
        if (IF_IPHONE) {
            ww/=2;
            fontSize = 10*AppScaleIphoneH;
        }
        UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0,(_cellH-ww)/2, ww, ww)];
        imageView.image = [UIImage imageNamed:imageName];
        [cell.contentView addSubview:imageView];
        imageView.hidden = (_contentType== Major_UserHomeMain_Type);
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+3, 0, _cellW-(imageView.frame.origin.x+imageView.frame.size.width+3), _cellH)];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:label];
        label.font = [UIFont systemFontOfSize:fontSize];
        Record *record = [self.listArray objectAtIndex:indexPath.row];
        label.text =  record.titleName;
        if (_isEdit) {
            label.textColor = RGBCOLOR(255, 0, 0);
            if (_contentType== Major_UserHomeMain_Type) {
                label.text =  [NSString stringWithFormat:@"X %@",record.titleName];
            }
        }
        else{
            label.textColor = RGBCOLOR(76, 76, 76);
        }
       
    }
    else{
        Record *record = [self.listArray objectAtIndex:indexPath.row];
        MajorRecordContentView *view = [[MajorRecordContentView alloc] initWithFrame:CGRectMake(0, 0, _cellW, _cellH)];
        [view initVideoInfo:record.titleName url:record.titleUrl time:record.dateStr base64Png:record.iconStr fontScale:0.7 number:1];
        [cell.contentView addSubview:view];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.liveClickBlock) {
        if (_contentType == Major_UserHomeMain_Type && _isEdit) {
            Record *record = [self.listArray objectAtIndex:indexPath.row];
            NSString *num = record.titleNum;
            [FileCache deleteAllDBDataByTitleNum:KEY_DATENAME TableName:KEY_TABEL_USERMAINHOME TitleNum:num];
            GetAppDelegate.isUserMainHomeUpdate = !GetAppDelegate.isUserMainHomeUpdate;
        }
        else{
            self.selectIndex = indexPath.row;
            Record *info = [self.listArray objectAtIndex:indexPath.row];
            self.liveClickBlock(info.titleUrl,info.titleName);
            [self.collectionView reloadData];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}



- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 2;
    }
    return 2;
}
@end
