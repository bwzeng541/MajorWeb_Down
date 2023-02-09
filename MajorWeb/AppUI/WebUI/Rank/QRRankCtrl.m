//
//  QRRankCtrl.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRRankCtrl.h"
#import "QRRankDataManager.h"
//#import "QRSystemConfig.h"
#import "QRRecordListCell.h"
#import "Masonry.h"
//#import "QRUtilities.h"
//#import "ByteDanceAdManager.h"
#import "QrByteVideoAd.h"
#import "Toast+UIView.h"
#import "TYAlertView.h"
#import "UIView+TYAlertView.h"
#import "AppDelegate.h"
static BOOL  _isClick;
static BOOL  _isShow;
@interface QRRankCtrl ()<UICollectionViewDelegate,UICollectionViewDataSource,QRRecordListCellDelegegate>{
    float _cellW,_cellH;
}
@property(strong)QrByteVideoAd *videoAd;
@property(weak)IBOutlet UIButton *btnClose;
@property(weak)IBOutlet UIButton *btnClick;
@property(weak)IBOutlet UICollectionView *collectionView;
@property(weak)IBOutlet UICollectionView *btnsCollectionView;
@property(weak)IBOutlet UIView *btnView;;
@property(weak)IBOutlet UIButton *btnMore;
@property(assign)QRRankDataType reqeustType;
@property(assign,nonatomic)NSInteger selectBtnIndex;
@property(strong,nonatomic)NSArray *btnsArray;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(copy,nonatomic)void(^clickBlock)(NSString*url);
@property(copy,nonatomic)void(^willRemoveBlock)(void);
@end

@implementation QRRankCtrl
-(void)dealloc{
    [self.videoAd stop];self.videoAd = nil;
    [[QRRankDataManager shareInstance] clearReqeust];
#ifdef DEBUG
    printf("%s\n",__FUNCTION__);
#endif
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectBtnIndex = 1;
    _cellW =  [UIScreen mainScreen].bounds.size.width;
    _cellH = 40;
    self.btnsArray = @[@"网址排名",@"网站排名",@"关键字",@"用户推荐",@"屏蔽广告"];
    UINib *v = [UINib nibWithNibName:@"QRRecordListCell" bundle:nil];
    [self.collectionView registerNib:v forCellWithReuseIdentifier:@"QRRecordListCell"];
    [self.btnsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"btnCell"];
    [self pressHost:nil];
    self.videoAd = [[QrByteVideoAd alloc] initWithRootCtrl:[UIApplication sharedApplication].keyWindow.rootViewController];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   /* if(!_isShow && [[ByteDanceAdManager getInstance] isCanShowFullVideo:false]){
             [[ByteDanceAdManager getInstance] tryShowFullVideo:^() {
                                      
             }ctrl:self msg:nil];
        _isShow = true;
     }*/
}

- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion{
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
}

-(void)setBlock:(void(^)(NSString*url))clickBlock willRemoveBlock:(void(^)(void))willRemoveBlock{
    self.clickBlock = clickBlock;
    self.willRemoveBlock = willRemoveBlock;
}
-(void)viewDidDisappear:(BOOL)animated{

   
    [super viewDidDisappear:animated];
}

-(void)reqeustObject:(QRRankDataType)type{
    self.reqeustType= type;
     __weak __typeof(self)weakSelf = self;
    [[QRRankDataManager shareInstance] reqeustRankData:type number:15  requestBlock:^(QRRankObject * _Nonnull object, BOOL isFaild) {
        weakSelf.dataArray = object.dataMode.data;
        [weakSelf.collectionView reloadData];
        [weakSelf.view makeToast:[@"已增加" stringByAppendingFormat:@"%ld条关键字",15] duration:2 position:@"center"];
    }];
}

-(IBAction)pressBack:(id)sender{
    if (self.willRemoveBlock) {
           self.willRemoveBlock();
       }
   // [self dismissViewControllerAnimated:NO  completion:nil];
}


-(IBAction)pressMore:(id)sender{
    [self reqeustObject:self.reqeustType];
    static BOOL isClickMore = false;
    if (!isClickMore) {
        isClickMore = [self.videoAd start:^{
            [[((AppDelegate*) [UIApplication sharedApplication].delegate)window]makeToast:@"此位置，已经没有视频广告了" duration:3 position:@"center"];
        }];
        if (isClickMore) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           [[((AppDelegate*) [UIApplication sharedApplication].delegate) window]makeToast:@"只会显示一次这个视频广告，感谢支持" duration:3 position:@"center"];
            });
        }
    }
}

-(IBAction)pressClick:(id)sender{
    static BOOL isClickHl = false;
    if(!isClickHl ){
        isClickHl = [self.videoAd start:^{
            [[((AppDelegate*) [UIApplication sharedApplication].delegate)window]makeToast:@"此位置，已经没有视频广告了" duration:3 position:@"center"];
        }];
        if (isClickHl) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[((AppDelegate*) [UIApplication sharedApplication].delegate) window]makeToast:@"只会显示一次这个视频广告，感谢支持" duration:3 position:@"center"];
            });
        }
    }
     _isClick = true;
    [self.collectionView reloadData];
    [self.btnsCollectionView reloadData];
}

-(IBAction)pressTj:(id)sender{
    self.selectBtnIndex = 3;
    QRRankObject *o = [[QRRankDataManager shareInstance] getQrRankObject:QRRank_Get_Recommends_Type];
      self.reqeustType = QRRank_Get_Recommends_Type;
      if (o.dataMode.data.count>0) {
           self.dataArray =o.dataMode.data;
          [self.collectionView reloadData];
      }
      else {
          [self reqeustObject:QRRank_Get_Recommends_Type];
      }
}


-(IBAction)pressUrl:(id)sender{
    self.selectBtnIndex = 0;
    QRRankObject *o = [[QRRankDataManager shareInstance] getQrRankObject:QRRank_Url_Type];
    self.reqeustType = QRRank_Url_Type;
    if (o.dataMode.data.count>0) {
         self.dataArray =o.dataMode.data;
        [self.collectionView reloadData];
    }
    else {
        [self reqeustObject:QRRank_Url_Type];
    }
}

-(IBAction)pressSearch:(id)sender{
    self.selectBtnIndex = 2;
    self.reqeustType = QRRank_Search_Type;
    QRRankObject *o = [[QRRankDataManager shareInstance] getQrRankObject:QRRank_Search_Type];
    if (o.dataMode.data.count>0) {
            self.dataArray =o.dataMode.data;
           [self.collectionView reloadData];
       }
       else {
           [self reqeustObject:QRRank_Search_Type];
       }
}

 
-(IBAction)pressHost:(id)sender{
    self.selectBtnIndex = 1;
    self.reqeustType = QRRank_Host_Type;
    QRRankObject *o = [[QRRankDataManager shareInstance] getQrRankObject:QRRank_Host_Type];
    if (o.dataMode.data.count>0) {
            self.dataArray =o.dataMode.data;
           [self.collectionView reloadData];
       }
       else {
           [self reqeustObject:QRRank_Host_Type];
       }
}

-(IBAction)pressAdHost:(id)sender{
    self.selectBtnIndex = 4;
      self.reqeustType = QRRank_Get_Ads_Type;
      QRRankObject *o = [[QRRankDataManager shareInstance] getQrRankObject:QRRank_Get_Ads_Type];
      if (o.dataMode.data.count>0) {
              self.dataArray =o.dataMode.data;
             [self.collectionView reloadData];
         }
         else {
             [self reqeustObject:QRRank_Get_Ads_Type];
         }
}

-(NSString*)isVaildUrl:(NSString*)text{
    NSString *tempUrl = [text
    stringByTrimmingCharactersInSet:[NSCharacterSet
                                        whitespaceAndNewlineCharacterSet]];
    NSString *regex = [NSString
                      stringWithFormat:
                          @"%@%@%@%@%@%@%@%@%@%@", @"^((https|http|ftp|rtsp|mms)?://)",
                          @"?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?",
                          @"(([0-9]{1,3}\\.){3}[0-9]{1,3}", @"|", @"([0-9a-zA-Z_!~*'()-]+\\.)*",
                          @"([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\.", @"[a-zA-Z]{2,6})",
                          @"(:[0-9]{1,4})?", @"((/?)|",
                          @"(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"];
    if (tempUrl.length>0) {
        if ([tempUrl isMatchedByRegex:regex] || [tempUrl hasPrefix:@"http://"] ||
           [tempUrl hasPrefix:@"https://"]) {
         if (![tempUrl hasPrefix:@"http://"] && ![tempUrl hasPrefix:@"https://"]) {
           tempUrl = [@"http://" stringByAppendingString:tempUrl];
         }
         
         tempUrl =
             (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                 kCFAllocatorDefault, (CFStringRef)tempUrl,
                 (CFStringRef) @"!$&'()*+,-./:;=?@_~%#[]", NULL,
                 kCFStringEncodingUTF8));
           return tempUrl;
        }
    }
    return nil;
}

-(NSString*)buildRealUrl:(NSString*)text{
    NSString *tempUrl = [text
              stringByTrimmingCharactersInSet:[NSCharacterSet
                                                  whitespaceAndNewlineCharacterSet]];
         if (tempUrl.length > 0) {
             NSString *newTmp = [self isVaildUrl:text];
             
            if(!newTmp){
             NSString *keywords = [tempUrl
                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *urlStr = [NSString stringWithFormat: @"https://www.baidu.com/s?word=%@",keywords];
                return urlStr;
           }
            else{
                return newTmp;
            }
         }
    return nil;//@"http://www.baiu.com";
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
 {
     if (self.collectionView == collectionView) {
         return CGSizeMake(collectionView.bounds.size.width, _cellH+5);
     }
     UIFont *font = [UIFont boldSystemFontOfSize:14];
      if (self.selectBtnIndex == indexPath.row) {
         font = [UIFont boldSystemFontOfSize:20];
     }
     NSString *text = [self.btnsArray objectAtIndex:indexPath.row];
//        CGSize size = [text boundingRectWithSize:CGSizeMake(200,  58) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font} context:nil].size;
     NSMutableDictionary *attr = [NSMutableDictionary dictionary];
      attr[NSFontAttributeName] = font;
     CGSize size = [text boundingRectWithSize:CGSizeMake(200,  45) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
     return CGSizeMake(size.width+40, 40);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
       return 1;
}
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
   if (self.collectionView == collectionView) {
    return self.dataArray.count;
   }
   else{
       return self.btnsArray.count;
   }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (self.collectionView == collectionView)
    return 20;
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.collectionView == collectionView) {
    QRRankItemModel *model  = (QRRankItemModel*)[self.dataArray objectAtIndex:indexPath.row];
    self.clickBlock([self buildRealUrl:model.name]);
        self.willRemoveBlock();
    }
    else{
        if (indexPath.row==0) {
            [self pressUrl:nil];
        }
        else if(indexPath.row==1){
            [self pressHost:nil];
        }
        else if(indexPath.row==2){
            [self pressSearch:nil];
        }
        else if(indexPath.row==3){
            [self pressTj:nil];
        }
        else if(indexPath.row==4){
            [self pressAdHost:nil];
        }
        [self.btnsCollectionView reloadData];
        [self.btnsCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.collectionView == collectionView) {
        QRRecordListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QRRecordListCell" forIndexPath:indexPath];
        cell.delegate = self;
         cell.desLabel.textColor = [UIColor lightGrayColor];
                //20DDFF
                cell.timeLabel.textColor = [UIColor colorWithRed:0x20/255.0 green:0xdd/255.0 blue:0xff/255.0 alpha:1];
            QRRankItemModel *model  = (QRRankItemModel*)[self.dataArray objectAtIndex:indexPath.row];
                 cell.desLabel.hidden =  cell.timeLabel.hidden = YES;
                cell.centerLabel.hidden = NO;
        cell.centerLabel.text = [NSString stringWithFormat:@"%ld --%@",indexPath.row+1,model.name];
        cell.btnDel.hidden = YES;
        cell.btnRankDel.hidden = NO;
        if(_isClick && [model.nickname length]>1)
        {
            cell.centerLabel.hidden = YES;
            cell.desLabel.hidden = cell.timeLabel.hidden = NO;
            cell.desLabel.text = [NSString stringWithFormat:@"%@",model.nickname];
            cell.timeLabel.text = [NSString stringWithFormat:@"%ld --%@",indexPath.row+1,model.name];
        }
        return cell;
    }
    else{
    UICollectionViewCell * cell = (UICollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"btnCell" forIndexPath:indexPath];
         UILabel *iconView =  [cell.contentView viewWithTag:1];
           if (!iconView) {
               iconView = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
               iconView.tag = 1;
               iconView.textColor = [UIColor blackColor];
               iconView.textAlignment = NSTextAlignmentCenter;
               [cell.contentView addSubview:iconView];
               [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.edges.equalTo(cell.contentView);
               }];
            }
        if (self.selectBtnIndex == indexPath.row) {
            iconView.textColor = [UIColor redColor];
            iconView.font = [UIFont boldSystemFontOfSize:20];
        }
        else{
            iconView.textColor = [UIColor blackColor];
            iconView.font = [UIFont boldSystemFontOfSize:14];
        }
        iconView.text = [self.btnsArray objectAtIndex:indexPath.row];
        return cell;
    }
}

-(void)clickDel:(QRRecordListCell*)cell{
    NSIndexPath *indexPath =[self.collectionView indexPathForCell:cell];
    QRRankItemModel *v = [self.dataArray objectAtIndex:indexPath.row];
    __weak __typeof(self)weakSelf = self;
    TYAlertView *alertView = nil;
             alertView = [TYAlertView alertViewWithTitle:@"该网站不安全？需要删除？" message:@"删除后，所有人都看不到，重启APP即可查看"];
             alertView.buttonFont = [UIFont systemFontOfSize:14];
       [alertView addAction:[TYAlertAction actionWithTitle:@"NO"
         style:TYAlertActionStyleCancel
       handler:^(TYAlertAction *action) {
        }]];
       [alertView addAction:[TYAlertAction actionWithTitle:@"YES"
           style:TYAlertActionStyleDefault
         handler:^(TYAlertAction *action) {
           [[QRRankDataManager  shareInstance] sumibitRankData:v.name title:nil type:(weakSelf.reqeustType)isDel:true uuid:[NSString stringWithFormat:@"%ld",v.uuid]];
            [weakSelf.view makeToast:@"已提交到删除" duration:2 position:@"center"];
           /*if ([[ByteDanceAdManager getInstance] isCanShowFullVideo:true]) {
               [[ByteDanceAdManager getInstance] tryShowFullVideo:^() {
                                        
               }ctrl:weakSelf msg:nil];
           }*/
       }]];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
}

@end
