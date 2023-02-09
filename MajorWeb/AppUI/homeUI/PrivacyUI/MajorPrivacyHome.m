//
//  MajorPrivacyHome.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/8.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorPrivacyHome.h"
#import "MorePanelCell.h"
#import "MarjorPrivateDataManager.h"
#import "ModifyView1Ctrl.h"
#import "AppDelegate.h"
#import "YSCHUDManager.h"
#import "Toast+UIView.h"
#import "ModifyChangeView.h"
#import <Photos/Photos.h>
#import "MarjorWebConfig.h"
#import "ThrowWebController.h"
#import "MainMorePanel.h"
#define HeaderDesKey @"HeaderDesKey"
#define HeaderStateKey  @"HeaderStateKey"
#define HeaderIconKey  @"HeaderIconKey"


@interface MajorPrivacyHome()<UICollectionViewDelegate,UICollectionViewDataSource,MarjorPrivateDataManagerDelegate,ModifyView1CtrlDelegate,ModifyChangeViewDelegate,AXWebViewControllerDelegate>
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *arrayMiddCellView;
@property(nonatomic,strong)NSMutableArray *listArray;
@property(nonatomic,strong)NSMutableArray *listHeaderArray;
@property(nonatomic,strong)NSString *showName;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UILabel *labelName;
@property(nonatomic,strong)ModifyView1Ctrl *modiyCtrl;
@property(nonatomic,strong)ModifyChangeView *modifyChangeView;
@property(nonatomic,strong)UIView *uploadMaskView;
@property(nonatomic,strong)UIView *imageMaskView;
@end

@implementation MajorPrivacyHome

#pragma MarjorPrivateDataManagerDelegate --
-(void)removeFromSuperview{
    [MarjorPrivateDataManager getInstance].delegate = nil;
    [super removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(major_privacy_end_remove)]) {
        [self.delegate major_privacy_end_remove];
    }
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)start_update_pic_config{
    [YSCHUDManager showHUDOnView:self];
}

-(void)finish_update_pic_config:(UIImage*)image{
    if (!image) {
        [self makeToast:@"获取最新数据失败" duration:2 position:@"center"];
    }
    else{
        if (!self.imageMaskView) {
            self.imageMaskView = [[UIView alloc] init];
            self.imageMaskView.backgroundColor = [UIColor whiteColor];
            [self addSubview:self.imageMaskView];
            [self.imageMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [self.imageMaskView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.imageMaskView);
                make.height.width.equalTo(self.imageMaskView.mas_width);//640X640
            }];
            UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnSave setImage:UIImageFromNSBundlePngPath(@"privacy_save") forState:UIControlStateNormal];
            __weak typeof(self) wself = self;
            [btnSave bk_addEventHandler:^(id sender) {
                [wself saveImage:image];
            } forControlEvents:UIControlEventTouchUpInside];
            [self.imageMaskView addSubview:btnSave];
            //265X57
            [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.imageMaskView.mas_centerX);
                make.bottom.equalTo(self.imageMaskView.mas_bottom).mas_offset(IF_IPAD?-265:-133);
                make.width.mas_equalTo(IF_IPAD?265:133);
                make.height.mas_equalTo(IF_IPAD?57:28);
            }];
        }
    }
    [YSCHUDManager hideHUDOnView:self animated:NO];
}

-(void)saveSuccessWithAlter:(UIImage*)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), nil);
}

- (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication] keyWindow] makeToast:!error?@"图片保存成功":@"图片保存失败" duration:2 position:@"center"];
    });
}

-(void)saveImage:(UIImage*)image{
    [self.imageMaskView removeFromSuperview];self.imageMaskView=nil;
    if (image) {
        __weak typeof(self)weakSelf = self;
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied) {
            [weakSelf makeToast:@"请求设置中打开保存图片权限" duration:1 position:@"center"];
        } else if(status == PHAuthorizationStatusNotDetermined){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                if (status == PHAuthorizationStatusAuthorized) {
                    [weakSelf saveSuccessWithAlter:image];
                } else {
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized){
            [weakSelf saveSuccessWithAlter:image];
        }
        
    }
}

-(void)start_down_private_config{
    [YSCHUDManager showHUDOnView:self];
}

-(void)finish_down_private_config:(BOOL)isSuccess{
    if (isSuccess) {
        [self updateData];
    }
    else{
        [self makeToast:@"该分享密钥已经失效" duration:2 position:@"center"];
    }
    [YSCHUDManager hideHUDOnView:self animated:NO];

}

-(void)start_upload_private_config{
#define UpLoadDesTag  10
    if (!self.uploadMaskView) {
        self.uploadMaskView = [[UIView alloc] init];
        [self addSubview:self.uploadMaskView];
        [self.uploadMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.uploadMaskView.backgroundColor = RGBCOLOR(242, 242, 242);
        UILabel *lable = [[UILabel alloc] init];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = @"正在上传，请稍等...";
        lable.font = [UIFont systemFontOfSize:20];
        lable.textColor = RGBCOLOR(0, 0, 0);
        lable.tag = UpLoadDesTag;
        [self.uploadMaskView addSubview:lable];
        [lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self.uploadMaskView);
            make.bottom.equalTo(self.uploadMaskView.mas_centerY).mas_offset(-80);
            make.height.mas_equalTo(80);
        }];
    }
}

-(void)finish_upload_private_config:(NSString*)key error:(NSError*)error{
    __weak typeof(self) wself = self;
    UILabel *label = [self.uploadMaskView viewWithTag:UpLoadDesTag];
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setImage:UIImageFromNSBundlePngPath(@"privacy_fuzhi") forState:UIControlStateNormal];
    if (error) {
        label.text = @"分享失败";
        [btnShare addTarget:self action:@selector(exitShareKey:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        label.numberOfLines = 2;
        label.text = [NSString stringWithFormat:@"请复制下面秘钥,分享给好友 \n %@",key];
        [btnShare bk_addEventHandler:^(id sender) {
            [wself copyShareKey:key];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    [self.uploadMaskView addSubview:btnShare];
    //265X57
    [btnShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.uploadMaskView.mas_centerX);
        make.top.equalTo(self.uploadMaskView.mas_centerY).mas_offset(IF_IPAD?265:133);
        make.width.mas_equalTo(IF_IPAD?265:133);
        make.height.mas_equalTo(IF_IPAD?57:28);
    }];
    [self.uploadMaskView bk_whenTapped:^{
        [wself exitShareKey:nil];
    }];
}

-(void)copyShareKey:(NSString*)shareKey{
    if(shareKey){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = shareKey;
        [self makeToast:@"复制成功" duration:2 position:@"center"];
    }
    [self.uploadMaskView removeFromSuperview];self.uploadMaskView=nil;
 }
 

-(void)exitShareKey:(UIButton*)sender{
    [self.uploadMaskView removeFromSuperview];self.uploadMaskView=nil;
}

-(void)loadFromUseCell:(WebConfigItem*)item{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewWeb" object:item];
}

-(void)willRemoveCtrlAndMustSyncData{
    [self.modiyCtrl.view removeFromSuperview];
    self.modiyCtrl = nil;
    [self updateData];
}


-(void)willModfiyChangeView{
    [self updateData];
}

-(void)willModifyCtrl{
    [self.modifyChangeView.view removeFromSuperview];
    self.modifyChangeView = nil;
}

-(void)update_local_private:(BOOL)isSuccess
{
    if (isSuccess) {
        [self updateData];
    }
}

-(void)updateData{
    [self.arrayMiddCellView removeAllObjects];
    self.listHeaderArray = [NSMutableArray arrayWithCapacity:10];
    self.listArray = [NSMutableArray arrayWithArray:[[MarjorPrivateDataManager getInstance] getCurrentConfigArray]];
    self.showName = [[MarjorPrivateDataManager getInstance] getCurrentConfigName];
    self.labelName.text = self.showName;
     if (self.listArray.count>0 ) {
        NSMutableArray *panelArray = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < self.listArray.count; i++) {
            MorePanelCell *v = [[MorePanelCell alloc] initWithPrivacyFrame:CGRectMake(0, 0, self.bounds.size.width,10) morePanelInfo:nil onePanel:[self.listArray objectAtIndex:i]];
            if (v) {
                NSMutableDictionary *infoSave = [NSMutableDictionary dictionaryWithCapacity:1];
                [infoSave setObject:v.onePanel forKey:OnePlayKey];
                @weakify(self)
                v.clickBlock = ^(WebConfigItem *item,id view) {
                    @strongify(self)
                    [MarjorWebConfig getInstance].webItemArray = ((MorePanelCell*)view).onePanel.array;
                    [self loadFromUseCell:item];
                };
                 BOOL ii = false;
                NSMutableAttributedString *stringA = v.headerName?v.headerName:@"未知错误";
                NSMutableDictionary *headInfo = [NSMutableDictionary dictionaryWithCapacity:1];
                [headInfo setObject:@(true) forKey:HeaderStateKey];
                [headInfo setObject:stringA forKey:HeaderDesKey];
                [headInfo setObject:v.iconUrl?v.iconUrl:@"AppMain.bundle/headerIcon.png" forKey:HeaderIconKey];
                [infoSave setObject:stringA forKey:OneHeaderStringKey];
                [panelArray addObject:infoSave];
                if (ii) {
                    if (self.arrayMiddCellView.count>0) {
                        [self.arrayMiddCellView insertObject:v atIndex:0];
                     }
                    else{
                        [self.arrayMiddCellView addObject:v];
                     }
                }
                else{
                    [self.arrayMiddCellView addObject:v];
                    [self.listHeaderArray addObject:headInfo];
                }
            }
        }
    }    
    [self.collectionView reloadData];
}

-(UIButton*)createBtn:(NSString*)imageName action:(nonnull SEL)action{
    UIButton *btnAddFa = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddFa addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btnAddFa setImage:UIImageFromNSBundlePngPath(imageName) forState:UIControlStateNormal];
    [btnAddFa setTitleColor:RGBCOLOR(16, 195, 71) forState:UIControlStateNormal];
    return btnAddFa;
}

-(void)initUI{
    [MarjorPrivateDataManager getInstance].delegate = self;
    self.backgroundColor = [UIColor whiteColor];
    self.arrayMiddCellView = [NSMutableArray arrayWithCapacity:10];
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 122)];
    [self addSubview:self.topView];
    //btn evnet
    UIButton *btn = [self createBtn:@"privacy_weixin" action:@selector(jionWeixin:)];
    btn.frame = CGRectMake(10, 0, 380, 38);
    [self.topView addSubview:btn];
    
    btn = [self createBtn:@"privacy_down" action:@selector(downOther:)];
    btn.frame = CGRectMake(10, 53, 123, 25);
    [self.topView addSubview:btn];
    
    btn = [self createBtn:@"privacy_share" action:@selector(commitAndShare:)];
    btn.frame = CGRectMake(138, 53, 250, 25);
    [self.topView addSubview:btn];
    
    btn = [self createBtn:@"privacy_qiehuan" action:@selector(qiehuandaohang:)];
    btn.frame = CGRectMake(10, 91, 123, 25);
    [self.topView addSubview:btn];
    
    btn = [self createBtn:@"privacy_modify" action:@selector(changeContent:)];
    btn.frame = CGRectMake(138, 91, 123, 25);
    [self.topView addSubview:btn];
    
    btn = [self createBtn:@"privacy_name" action:@selector(changeTitleName:)];
    btn.frame = CGRectMake(263, 91, 123, 25);
    [self.topView addSubview:btn];
    float scales = MY_SCREEN_WIDTH/400;
    self.topView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scales, scales);
    self.topView.center = CGPointMake(MY_SCREEN_WIDTH/2, GetAppDelegate.appStatusBarH+122*scales/2);
   float startY = self.topView.center.y+122*scales/2;
    
    //end
    float lableH = IF_IPAD?50:30;
    self.labelName = [[UILabel alloc] initWithFrame:CGRectMake(0,startY+lableH/2, MY_SCREEN_WIDTH, lableH)];
    [self addSubview:self.labelName];
    
    self.labelName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:IF_IPAD?40:24];
    self.labelName.textAlignment = NSTextAlignmentCenter;
    self.labelName.backgroundColor = RGBCOLOR(242, 242, 242);
    
    UICollectionViewFlowLayout * carouseLayout = [[UICollectionViewFlowLayout alloc] init];
    carouseLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    carouseLayout.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, 50);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:carouseLayout];
    _collectionView.showsVerticalScrollIndicator = false;
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerX.right.equalTo(self);
        make.bottom.equalTo(self).mas_offset(-(GetAppDelegate.appStatusBarH-20));
        make.top.equalTo(self.labelName.mas_bottom);
    }];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
     [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self updateData];

    btn = [self createBtn:@"privacy_exit_mode" action:@selector(removeFromSuperview)];
    [self addSubview:btn];
    //265X57
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).mas_offset(-(GetAppDelegate.appStatusBarH-20)-10);
        make.width.mas_equalTo(IF_IPAD?265:133);
        make.height.mas_equalTo(IF_IPAD?57:28);
    }];
}



-(void)qiehuandaohang:(UIButton*)sender{
  
    if (!self.modifyChangeView) {
        self.modifyChangeView = [[ModifyChangeView alloc] initWithNibName:@"ModifyChangeView" bundle:nil];
        self.modifyChangeView.delegate = self;
        [self.superview addSubview:self.modifyChangeView.view];
        [self.modifyChangeView.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superview);
        }];
    }
}

-(void)commitAndShare:(UIButton*)sender{
    [[MarjorPrivateDataManager getInstance] upLoadMarjorPrivateData];
}

-(void)downOther:(UIButton*)sender{
    if (GetAppDelegate.isProxyState) {
        return;
    }
    NSString *title =  nil;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入密钥" message:title preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = title;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        NSString *text = envirnmentNameTextField.text;
        if (text.length>1) {
            [[MarjorPrivateDataManager getInstance] downMarjorPrivateData:text];
        }
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(void)jionWeixin:(UIButton*)sender{
    NSString *url = [MainMorePanel getInstance].morePanel.toolsurl;
    ThrowWebController *webVC = [[ThrowWebController alloc] initWithAddress:url?url:@"http://www.baidu.com"];
    webVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:NULL];
    webVC.showsToolBar = YES;
    webVC.navigationType = 1;
    //[MobClick event:@"jionWeixin_btn"];
    //[[MarjorPrivateDataManager getInstance] reqeustNewImageData];
}

-(void)changeContent:(UIButton*)sender{
    [self addUrlTitle:nil title:nil];
}

-(void)addUrlTitle:(NSString *)url title:(NSString*)title{
    if (!self.modiyCtrl) {
        self.modiyCtrl = [[ModifyView1Ctrl alloc] initWithNibName:@"ModifyView1Ctrl" bundle:nil arrayData:self.listArray showName:self.showName url:url title:title];
        self.modiyCtrl.delegate = self;
        [self.superview addSubview:self.modiyCtrl.view];
        [self.modiyCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superview);
        }];
    }
}

-(void)changeTitleName:(UIButton*)sender
{
    NSString *title = self.showName;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"重命名" message:title preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = title;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        NSString *text = envirnmentNameTextField.text;
        if (text.length>1) {
            [wself updateShowName:text];
        }
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(void)updateShowName:(NSString*)text{
    self.showName = text;
    self.labelName.text = text;
    [[MarjorPrivateDataManager getInstance] updateCurrentConfig:self.listArray showName:text];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.arrayMiddCellView.count;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.bounds.size.width, 70);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        NSInteger pos = section;
        if (pos<self.arrayMiddCellView.count) {
            NSDictionary*info = [self.listHeaderArray objectAtIndex:section];
            if([[info objectForKey:HeaderStateKey] boolValue]){
                return 1;
            }
            return 0;
        }
        return 0;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    [[headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDictionary *info = [self.listHeaderArray objectAtIndex:indexPath.section];
    CGSize size = headerView.bounds.size;
    UIImageView *imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, size.height*0.22, size.height*0.55, size.height*0.55)];
    [headerView addSubview:imageIcon];
    NSString *iconUrl = [info objectForKey:HeaderIconKey];
    if (iconUrl) {
        NSString *tmpIcon = @"AppMain.bundle/headerIcon.png";
        if ([iconUrl rangeOfString:tmpIcon].location!=NSNotFound) {
            imageIcon.image = [UIImage imageNamed:tmpIcon];
        }
        else{
            [imageIcon sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:tmpIcon]];
        }
    }
   
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageIcon.frame.size.width+imageIcon.frame.origin.x+10,0,size.width-20,size.height)];
    label.attributedText = [info objectForKey:HeaderDesKey];
    label.tag = indexPath.section;
    label.userInteractionEnabled =YES;
    label.numberOfLines =2;
    __weak __typeof(self)weakSelf = self;
    [label bk_whenTapped:^{
        [weakSelf updateSectionState:label.tag];
    }];
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ContentCollection";
    MajorHomeBaesCell *middleView=nil;
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
    middleView = [self.arrayMiddCellView objectAtIndex:indexPath.section];
        cell.contentView.bounds = CGRectMake(0,0,((MorePanelCell*)middleView).panelCellSize.width, ((MorePanelCell*)middleView).panelCellSize.height);
    
    UIColor *backColor =[UIColor whiteColor];
    UIColor  *fontColor = [UIColor blackColor];
    if (indexPath.row%2==0) {
        backColor = RGBCOLOR(242,242,242);
        fontColor = RGBCOLOR(255,126,0);
    }
    
    middleView.backgroundColor = backColor;
    [middleView updateHeadColor:fontColor];
    middleView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:middleView];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    MorePanelCell *cell = [self.arrayMiddCellView objectAtIndex:indexPath.row];
    return cell.panelCellSize;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPAD) {
        return 5;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (IF_IPHONE) {
        return 20*AppScaleIphoneH;
    }
    return 10;
}

-(void)updateSectionState:(NSInteger)pos{
    NSMutableDictionary *info = [self.listHeaderArray objectAtIndex:pos];
    BOOL retNew = ![[info objectForKey:HeaderStateKey] boolValue];
    [info setObject:[NSNumber numberWithBool:retNew] forKey:HeaderStateKey];
    [self.collectionView reloadData];
}

- (NSString*)webViewControllerUpdateTilte{
    return nil;
}
@end
