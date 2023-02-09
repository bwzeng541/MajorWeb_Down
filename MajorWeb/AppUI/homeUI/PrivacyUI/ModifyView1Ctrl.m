//
//  ModifyView1Ctrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ModifyView1Ctrl.h"
#import "MarjorPrivateDataManager.h"
#import "MainMorePanel.h"
#import "ModifyDetailsCtrl.h"
@interface ModifyView1Ctrl ()<ModifyDetailsCtrlDelegate>{
    float cellh;
}
@property(nonatomic,assign)NSInteger currentEditIndex;
@property(nonatomic,strong)ModifyDetailsCtrl *modifyDetailCtrl;
@property(nonatomic,assign) NSString *showName;
@property(nonatomic,assign) BOOL isEdit;
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,copy)NSString* defaultUrl;
@property(nonatomic,copy)NSString* defaultTitle;

@property(weak,nonatomic)IBOutlet UIButton *btnCancle;
@property(weak,nonatomic)IBOutlet UIButton *btnDel;
@property(weak,nonatomic)IBOutlet UIButton *btnAdd;
@property(weak,nonatomic)IBOutlet UIView *contentView;
@property(weak,nonatomic)IBOutlet UICollectionView *collectionView;

@end

@implementation ModifyView1Ctrl

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil arrayData:(NSArray*)array showName:(NSString*)showName url:(NSString*)url title:(NSString*)title{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.arrayData = [NSMutableArray arrayWithCapacity:10];
    self.showName = showName;
    self.defaultUrl = url;
    self.defaultTitle = title;
    if (array) {
        [self.arrayData addObjectsFromArray:array];
    }
    cellh = 45;
    return self;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [self.modifyDetailCtrl.view removeFromSuperview];
    self.modifyDetailCtrl = nil;
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ContentCollection"];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view from its nib.
}

-(void)addNewSort:(NSString*)name{
    onePanel *newOne = [[onePanel alloc] init];
    newOne.headerName = name;
    [self.arrayData addObject:newOne];
    [self.collectionView  reloadData];
    [[MarjorPrivateDataManager getInstance] updateCurrentConfig:self.arrayData showName:self.showName];
}

-(void)willSyncData:(BOOL)isSync newData:(id)data{
    if (self.currentEditIndex>=0 && self.currentEditIndex<self.arrayData.count) {
        [self.arrayData replaceObjectAtIndex:self.currentEditIndex withObject:data];
        [[MarjorPrivateDataManager getInstance] updateCurrentConfig:self.arrayData showName:self.showName];
    }
}

-(void)willRmoveCtrl{
    [self.modifyDetailCtrl.view removeFromSuperview];
    self.modifyDetailCtrl = nil;
    [self.collectionView reloadData];
}




-(IBAction)pressCancle:(id)sender{
    [self.delegate willRemoveCtrlAndMustSyncData];
}

-(IBAction)pressDel:(id)sender{
    self.isEdit = !self.isEdit;
    [self.collectionView reloadData];
}

-(IBAction)pressAdd:(id)sender{
    NSString *title = @"输入类别名字";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加类别" message:title preferredStyle:UIAlertControllerStyleAlert];
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
    [self.arrayData removeObjectAtIndex:index];
    [[MarjorPrivateDataManager getInstance] updateCurrentConfig:self.arrayData showName:self.showName];
    [self.collectionView reloadData];
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
    lable.text = ((onePanel*)[self.arrayData objectAtIndex:indexPath.row]).headerName;
    [cell.contentView addSubview:lable];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:lineView];

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
        if (!self.modifyDetailCtrl) {
            self.currentEditIndex = indexPath.row;
            self.modifyDetailCtrl = [[ModifyDetailsCtrl alloc] initWithNibName:@"ModifyDetailsCtrl" bundle:nil data:[self.arrayData objectAtIndex:indexPath.row]url:self.defaultUrl title:self.defaultTitle];
            [self.view addSubview:self.modifyDetailCtrl.view];
            [self.modifyDetailCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            self.modifyDetailCtrl.delegate = self;
        }
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
