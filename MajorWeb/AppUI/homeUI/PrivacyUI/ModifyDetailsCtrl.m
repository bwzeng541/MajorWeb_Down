//
//  ModifyDetailsCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/4/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ModifyDetailsCtrl.h"
#import "MainMorePanel.h"
#import "ModifyDetailCell.h"
#import "MarjorWebConfig.h"
@interface ModifyDetailsCtrl ()<WebConfigItemDelegate >{
    float cellh;
}
@property(nonatomic,strong)IBOutlet UIView *topView;
@property(nonatomic,strong)IBOutlet UIView *nameView;
@property(nonatomic,strong)IBOutlet UICollectionView *collectionView;

@property(nonatomic,strong)IBOutlet UIButton *btnModify;
@property(nonatomic,strong)IBOutlet UIButton *btnBack;
@property(nonatomic,strong)IBOutlet UIButton *btnAdd;
@property(nonatomic,strong)IBOutlet UILabel *showName;

@property(nonatomic,copy)NSString* defaultUrl;
@property(nonatomic,copy)NSString* defaultTitle;

@property(nonatomic,strong)onePanel *editPanel;
@property(nonatomic,strong)NSMutableArray *arrayData;
@end

@implementation ModifyDetailsCtrl

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(id)data url:(NSString*)url title:(NSString*)title{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.arrayData = [NSMutableArray arrayWithCapacity:10];
    self.editPanel = data;
    self.defaultTitle = title;
    self.defaultUrl = url;
    if (self.editPanel.array.count>0) {
        [self.arrayData addObjectsFromArray:self.editPanel.array];
    }
    cellh = 50;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showName.text =  self.editPanel.headerName;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ModifyDetailCell" bundle:nil] forCellWithReuseIdentifier:@"ModifyDetailCell"];
    self.showName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:self.showName.font.pointSize];
    if (self.defaultUrl) {
        [self pressAdd:nil];
    }
}
//WebConfigItem
-(IBAction)pressBack:(id)sender{
    [self.delegate willRmoveCtrl];
}

-(IBAction)pressAdd:(id)sender{//添加新的,
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加新的一项" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = wself.defaultTitle?wself.defaultTitle:@"输入名称";
        if (wself.defaultTitle) {
            textField.text = wself.defaultTitle;
        }
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = wself.defaultUrl?wself.defaultUrl:@"htt://www.baidu.com";
        if (wself.defaultUrl) {
            textField.text = wself.defaultUrl;
        }
    }];
     [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField1 = alertController.textFields.firstObject;
        __block NSString*nameText = envirnmentNameTextField1.text;
        
        UITextField *envirnmentNameTextField2 = [alertController.textFields objectAtIndex:1];
        __block NSString*urlText = envirnmentNameTextField2.text;
        [MarjorWebConfig isUrlValid:urlText callBack:^(BOOL validValue, NSString *result) {
            if (validValue && [nameText length]>1) {
                [wself addNewItem:nameText url:result];
            }
            else{
                [[[UIApplication sharedApplication] keyWindow] makeToast:@"输入不合法" duration:2 position:@"center"];
            }
        }];
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(IBAction)pressModify:(id)sender{//修改名字
    NSString *title = self.showName.text;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改名字" message:title preferredStyle:UIAlertControllerStyleAlert];
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
        else{
            [[[UIApplication sharedApplication] keyWindow] makeToast:@"输入不合法" duration:2 position:@"center"];
        }
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(void)addNewItem:(NSString*)name url:(NSString*)url{
    WebConfigItem *item = [[WebConfigItem alloc] init];
    item.url = url;
    item.name = name;
    [self.arrayData addObject:item];
    self.editPanel.array = self.arrayData;
    [self.delegate willSyncData:YES newData:self.editPanel];
    [self.collectionView reloadData];
}

-(void)updateShowName:(NSString*)name{
    self.editPanel.headerName = name;
    self.showName.text =  self.editPanel.headerName;
    [self.delegate willSyncData:YES newData:self.editPanel];
}

-(void)syncWebConfigItemData:(WebConfigItem*)item index:(NSInteger)index{
    if (index>=0&&index<self.arrayData.count && item) {
        [self.arrayData replaceObjectAtIndex:index withObject:item];
        self.editPanel.array = self.arrayData;
        [self.delegate willSyncData:YES newData:self.editPanel];
    }
}

-(void)syncWebConfigItemDelData:(WebConfigItem*)item index:(NSInteger)index{
    if (index>=0&&index<self.arrayData.count) {
        [self.arrayData removeObjectAtIndex:index];
        self.editPanel.array = self.arrayData;
        [self.delegate willSyncData:YES newData:self.editPanel];
        [self.collectionView reloadData];
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
    ModifyDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ModifyDetailCell" forIndexPath:indexPath];
    [cell updateConfigItem:[self.arrayData objectAtIndex:indexPath.row] index:indexPath.row delegate:self];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}

@end
