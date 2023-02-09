//
//  ModifyView1Ctrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ModifyChangeView.h"
#import "MarjorPrivateDataManager.h"
#import "MainMorePanel.h"
#import "UIDevice+YSCKit.h"
#import "NSString+MKNetworkKitAdditions.h"
@interface ModifyChangeView (){
    float cellh;
}
@property(nonatomic,assign)NSInteger currentEditIndex;
@property(nonatomic,assign) NSString *showName;
@property(nonatomic,assign) BOOL isEdit;
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(weak,nonatomic)IBOutlet UIButton *btnCancle;
@property(weak,nonatomic)IBOutlet UIButton *btnDel;
@property(weak,nonatomic)IBOutlet UIButton *btnAdd;
@property(weak,nonatomic)IBOutlet UIView *contentView;
@property(weak,nonatomic)IBOutlet UICollectionView *collectionView;

@end

@implementation ModifyChangeView

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.arrayData = [NSMutableArray arrayWithCapacity:10];
    [[MarjorPrivateDataManager getInstance] initAllSortArray];
    [self.arrayData addObjectsFromArray:[[MarjorPrivateDataManager getInstance] getPrivateConfigList]];
    cellh = 45;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view from its nib.
}

-(void)addNewSort:(NSString*)name{
    arraySort *newOne = [[arraySort alloc] init];
    newOne.showName = name;
    [[MarjorPrivateDataManager getInstance] addNewSortItem:[[UIDevice stringWithUUID]md5] object:newOne];
    [self.arrayData  removeAllObjects];
    [self.arrayData addObjectsFromArray:[[MarjorPrivateDataManager getInstance] getPrivateConfigList]];
    [self.collectionView  reloadData];
 }

-(void)willRmoveCtrl{
    [self.collectionView reloadData];
}

-(IBAction)pressCancle:(id)sender{
    [self.delegate willModifyCtrl];
}

-(IBAction)pressDel:(id)sender{
    self.isEdit = !self.isEdit;
    [self.collectionView reloadData];
}

-(IBAction)pressAdd:(id)sender{
    NSString *title = @"输入导航名字";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加导航" message:title preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = title;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        NSString *text = envirnmentNameTextField.text;
        if (text.length>1) {
            [wself addNewSort:text];
        }
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}


-(void)delIt:(NSInteger)index{
    NSDictionary *info = [self.arrayData objectAtIndex:index];
    BOOL isReload =[[MarjorPrivateDataManager getInstance] delSortItemIfCurrent:[info objectForKey:@"key"]] ;
    [self.arrayData removeObject:info];
    [self.collectionView reloadData];
    if (isReload) {
        if (self.arrayData.count>0) {
           NSDictionary *info = [self.arrayData objectAtIndex:0];
            [[MarjorPrivateDataManager getInstance]  updateLocalFormKey:[info objectForKey:@"key"]];
        }
        else{
            [[MarjorPrivateDataManager getInstance] clearAllSortData];
        }
        [self.delegate willModfiyChangeView];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.frame.size.width, cellh);
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
    lable.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    lable.textAlignment = NSTextAlignmentCenter;
    arraySort*sortItem = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"object"];
    lable.text = sortItem.showName;
    [cell.contentView addSubview:lable];
    //b_sh Menu.bundle
    if (self.isEdit) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:UIImageFromNSBundlePngPath(@"Menu.bundle/b_sh")];
        [cell.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);//119X43
            make.right.equalTo(cell.contentView).mas_offset(self->cellh/4);//119X43
            make.width.mas_equalTo(self->cellh*(119.0/43)*0.5);
            make.height.mas_equalTo(self->cellh*0.5);
        }];
    }
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:lineView];
    lable.textColor = self.isEdit?[UIColor redColor]:[UIColor blackColor];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(cell.contentView);
        make.bottom.equalTo(cell.contentView);
        make.height.mas_equalTo(1);
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isEdit) {//进入编辑页面
        [[MarjorPrivateDataManager getInstance]  updateLocalFormKey:[[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"key"]];
        [self.delegate willModifyCtrl];
    }
    else{//删除
        __block NSInteger index = indexPath.row;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) wself = self;
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself delIt:index];
        }]];
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}

@end
