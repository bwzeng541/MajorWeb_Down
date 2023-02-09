//
//  SelectedAssetCell.h
//  XGAssetPickerController-Demo
//
//  Created by huxinguang on 2018/11/14.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SavePhotoInfo;
@interface SelectedAssetCell : UICollectionViewCell
@property (strong, nonatomic)  UIImageView *imgView;
@property (strong, nonatomic)  UIButton *playBtn;
@property (strong, nonatomic)  UIButton *deleteBtn;
@property (nonatomic, strong) SavePhotoInfo *model;
-(void)removeAsset;
@end
