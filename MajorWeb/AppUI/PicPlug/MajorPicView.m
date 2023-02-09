
#import "MajorPicView.h"
#import "YBImageBrowser.h"
#import "YBImageBrowserCell.h"
#import "SDWebImageManager.h"
#import "AppDelegate.h"
@interface MajorPicView()<UICollectionViewDelegate,UICollectionViewDataSource,YBImageBrowserDataSource,YBImageBrowserCellDelegate,YBImageBrowserDelegate>{
    float _picW;
}
@property(nonatomic,strong)NSArray *picArray;
@property(nonatomic,strong)UICollectionView *collectionView;
@end
@implementation MajorPicView
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(instancetype)initWithFrame:(CGRect)frame withData:(NSArray*)array{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(GetAppDelegate.appStatusBarH);
    }];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setTitle:@"关闭" forState:UIControlStateNormal];
    [self addSubview:btnBack];
    [btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).mas_offset(5+GetAppDelegate.appStatusBarH);
        make.width.height.mas_equalTo(50);
    }];
    [btnBack addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.picArray = array;
    if (IF_IPHONE) {
        _picW = (MY_SCREEN_WIDTH-10)/4;
    }
    else{
        _picW = (MY_SCREEN_WIDTH-12)/6;
    }
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView  = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:YBImageBrowserCell.class forCellWithReuseIdentifier:@"PicUpIconsCell"];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self).mas_offset(0);
        make.left.equalTo(self).mas_offset(0);
        make.top.equalTo(btnBack.mas_bottom);
    }];
    return self;
}

- (void)back:(UIButton*)sender{
    RemoveViewAndSetNil(self.collectionView);
    [[SDWebImageManager sharedManager].imageDownloader cancelAllDownloads];
    [[SDImageCache sharedImageCache] clearMemory];
    [self.picArray makeObjectsPerformSelector:@selector(cancelTaskWithDownloadToken)];
    [self removeFromSuperview];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    //1240X456
    return CGSizeMake(_picW, _picW);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return self.picArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YBImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicUpIconsCell" forIndexPath:indexPath];
    cell.model = [self.picArray objectAtIndex:indexPath.row];
    cell.cancelDragImageViewAnimation = NO;
    [cell removeAllGestureAndNotification];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YBImageBrowser *v = [YBImageBrowser new];
    [v setYb_supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
    v.dataSource = self;
    v.delegate = self;
    v.currentIndex = indexPath.row;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:v animated:NO completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{

}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}

- (NSInteger)numberInYBImageBrowser:(YBImageBrowser *)imageBrowser{
    return [self.picArray count];
}

- (YBImageBrowserModel *)yBImageBrowser:(YBImageBrowser *)imageBrowser modelForCellAtIndex:(NSInteger)index{
    YBImageBrowserModel *value = [self.picArray objectAtIndex:index];
    value.rowIndex = index;
    return value;
}

- (void)addMaskByYBImageBrowserCell:(YBImageBrowser*)imageBrowser imageBrowserCell:(YBImageBrowserCell *)imageBrowserCell {
    [[imageBrowserCell.contentView viewWithTag:101] removeFromSuperview];
    [[imageBrowserCell.imageView viewWithTag:100] removeFromSuperview];
    [imageBrowserCell addAllGestureAndNotification];
}

- (BOOL)yBImageBrowserIsCanExcel:(YBImageBrowser*)imageBrowser clickFunctionWithName:(NSString *)functionName imageModel:(YBImageBrowserModel *)imageModel {
    return true;
}

@end
