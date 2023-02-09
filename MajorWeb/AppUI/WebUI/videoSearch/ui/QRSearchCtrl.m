//
//  QRSearchCtrl.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRSearchCtrl.h"
#import "QRSearchManager.h"
#import "QRDataManager.h"
#import "QRMultiView.h"
#import "QRSystemConfig.h"
#import "ZYInputAlertView.h"
#import "UIView+TYAlertView.h"
//#import "QRRecordListCell.h"
#import "MajorSystemConfig.h"
#import "QRSearchCell.h"
#import "Masonry.h"
#import "AXPracticalHUD.h"
#import "QrByteVideoAd.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#define JianGe 10
 
#define GeShu 3
 
//#define ScreenWidth ([QRSystemConfig shareInstance].deviceSize.width)
 
//#define Screenheight ([UIScreen mainScreen].bounds.size.height)
 
@interface QRSearchCtrl (){
    BOOL _isFirstInit;
 }
@property(strong)QrByteVideoAd *videoAd;
@property(strong)QRMultiView *hotsView;
@property(copy)NSString *searchText;
@property(strong)NSMutableArray *dataArray;
@property(weak)IBOutlet UICollectionView *collectionView;
@property(weak)IBOutlet UIButton *btnClose;
@property(weak)IBOutlet UIButton *btnSearch;
@property (nonatomic, copy) void (^clickBlock)(NSString *url);
@end

@implementation QRSearchCtrl

-(void)dealloc{
    [[AXPracticalHUD sharedHUD] hide:NO];
    if (self.dataArray.count>0 && self.searchText) {
        [[QRDataManager shareInstance] delSearchRecord:self.searchText];
        [[QRDataManager shareInstance] addSearchRecord:self.searchText array:self.dataArray];
    }
    [self.videoAd stop];self.videoAd=nil;
    [[QRSearchManager shareInstance] stopSearch];
#ifdef DEBUG
    printf("%s\n",__FUNCTION__);
#endif
}

-(void)initClickBlock:(void (^)(NSString *url))clickBlock{
    self.clickBlock = clickBlock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray arrayWithCapacity:10];
    __weak typeof(self) weakSelf = self;
    
    self.hotsView = [[QRMultiView alloc] initWithFrame:CGRectMake(0, 23, [UIScreen mainScreen].bounds.size.width, 0)];
    [self.view addSubview:_hotsView];
    
 
    [self.collectionView registerNib:[UINib nibWithNibName:@"QRSearchCell" bundle:nil] forCellWithReuseIdentifier:@"QRSearchCell"];
    self.hotsView.block = ^(QRSearhWord *record) {
        [weakSelf searchText:record.word];
    };
    if (![[QRSystemConfig shareInstance] isSearchVideoAdWatch]) {
            self.videoAd = [[QrByteVideoAd alloc] initWithRootCtrl:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateUIFrame];
}

-(void)updateUIFrame{
    RLMResults *vv = [[QRDataManager shareInstance]getSearchWordRecord];
    float h =[_hotsView updateHotsArray:vv];
       self.hotsView.frame = CGRectMake(0, self.btnSearch.frame.origin.y+self.btnSearch.frame.size.height+5, self.hotsView.frame.size.width, h);
    float startY = self.hotsView.frame.origin.y+self.hotsView.frame.size.height+5;
    [self.collectionView setFrame:CGRectMake(0,startY,self.view.bounds.size.width, self.view.frame.size.height-startY-([MajorSystemConfig getInstance].zhiboFixTopH-20))];
    if (!_isFirstInit && vv.count>0) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:[[QRDataManager shareInstance] getSearchRecord:((QRSearhWord*)vv[0]).word]] ;
        [self.collectionView reloadData];
    }
    _isFirstInit = true;
}

-(IBAction)pressClose:(id)sender{
    self.clickBlock(nil);
   // [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)pressSearch:(id)sender{
    __weak typeof(self) weakSelf = self;
         ZYInputAlertView *alertView = [ZYInputAlertView alertView];
         alertView.placeholder = @"输入搜索内容";
         alertView.inputTextView.text = @"";
       alertView.inputTextView.font = [UIFont systemFontOfSize:24];
         alertView.alertViewDesLabel.text = @"视频搜索";
         alertView.alertViewDesLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18];
         [alertView confirmBtnClickBlock:^(NSString *inputString) {
             [weakSelf searchText:inputString];
         }];
         alertView.conCancleBtn.hidden = alertView.confirmWebBtn.hidden = NO;
         alertView.confirmBtn.hidden = YES;
       alertView.frame = CGRectMake(0,[MajorSystemConfig getInstance].zhiboFixTopH, [MajorSystemConfig getInstance].appSize.width,[MajorSystemConfig getInstance].appSize.height-[MajorSystemConfig getInstance].zhiboFixTopH);
         [alertView setNeedsLayout];
         [alertView show];
         [alertView.conCancleBtn setTitle:@"取消" forState:UIControlStateNormal];
         [alertView.confirmWebBtn setTitle:@"确定" forState:UIControlStateNormal];
    
}

-(void)searchText:(NSString*)text{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
     text = [text stringByTrimmingCharactersInSet:set];
    if (text.length>0) {
        [[AXPracticalHUD sharedHUD] showNormalInView:self.collectionView text:nil detail:nil configuration:^(AXPracticalHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
        [[QRSearchManager shareInstance] stopSearch];
        __block NSString *name = text;
          if (self.searchText&&self.dataArray.count>0) {
              [[QRDataManager shareInstance] delSearchRecord:self.searchText];
              [[QRDataManager shareInstance] addSearchRecord:self.searchText array:self.dataArray];
          }
          self.searchText = text;
          __weak typeof(self) weakSelf = self;
          [weakSelf.dataArray removeAllObjects];
         [weakSelf.collectionView reloadData];
          [[QRSearchManager shareInstance] startSearch:name parentView:self.view retArray:^(NSArray * _Nonnull array,BOOL isAdd,BOOL isFinisd) {
              [[AXPracticalHUD sharedHUD] hide:YES afterDelay:0 completion:NULL];
              [weakSelf.dataArray addObjectsFromArray:array];
              [weakSelf.collectionView reloadData];
              [[QRDataManager shareInstance] addSearchRecord:name array:array];
              if (isFinisd) {
                  [weakSelf updateUIFrame];
                  [[QRSearchManager shareInstance] stopSearch];
              }
          }];
        
        //广告
        if (![[QRSystemConfig shareInstance] isSearchVideoAdWatch]) {
            if([self.videoAd start:^{
                [[QRSystemConfig shareInstance] watchSearchVideoAd];
                [weakSelf.view makeToast:@"感谢你的支持，搜索视频今日没有广告" duration:3 position:@"center"];
            }]){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[((AppDelegate*) [UIApplication sharedApplication].delegate)window] makeToast:@"搜索视频这里，今天只有一次视频广告" duration:4 position:@"center"];
                });
            }
        }
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
      return self.dataArray.count;
}

//定义每个UICollectionView 的大小
 
- ( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath {
    //return CGSizeMake((ScreenWidth - JianGe*(GeShu+1)) / GeShu, (ScreenWidth - JianGe*(GeShu+1)) / GeShu );
    float ww =  (collectionView.bounds.size.width - JianGe*(GeShu+1)) / GeShu;
    return CGSizeMake(ww , ww*1.77);
}
 
 
//定义每个UICollectionView 的边距
 
- ( UIEdgeInsets )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section {
    return UIEdgeInsetsMake ( JianGe , JianGe , JianGe , JianGe );
}
 
//设置水平间距 (同一行的cell的左右间距）
 
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return JianGe;
}
 
//垂直间距 (同一列cell上下间距)
 
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return JianGe;
}
 
    
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.clickBlock) {
        self.clickBlock(self.dataArray[indexPath.row][@"url"]);
    }
  //  [self dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   QRSearchCell *cell = (QRSearchCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"QRSearchCell" forIndexPath:indexPath];
    [cell buildItem:self.dataArray[indexPath.row]];
    return cell;
}



@end
