//
//  SelectedAssetCell.m
//  XGAssetPickerController-Demo
//
//  Created by huxinguang on 2018/11/14.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "SelectedAssetCell.h"
 #import "UIView+XGAdd.h"
#import "SavePhotoInfo.h"
#import "PhotoLinkPlug.h"
#import "SDImageCache.h"
#import "UIImage+ThrowScreenTools.h"
@implementation SelectedAssetCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
}

- (UIImageView*)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

-(UIButton*)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize size = self.bounds.size;
        [_deleteBtn setImage:[UIImage imageNamed:@"delete_pic"] forState:UIControlStateNormal];
        _deleteBtn.frame = CGRectMake(size.width-40, 5, 30, 30);
         [self.contentView addSubview:_deleteBtn];
    }
    return _deleteBtn;
}


 
- (void)updateImage:(UIImage*)image{
    //image = [image scaleImage:size.width/image.size.width];
    self.imgView.image = image;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setModel:(SavePhotoInfo *)model{
    _model = model;
   {
      NSString *iconFile = [[PhotoLinkPlugDir stringByAppendingPathComponent:model.dirName] stringByAppendingPathComponent:model.iconfileName];
       [self updateImage:[UIImage imageWithContentsOfFile:iconFile]];
   }
}

-(void)removeAsset{
    [[PhotoLinkPlug PhotoLinkPlug] removeAssetToLocal:_model.uuid fileName:_model.fileName dirName:_model.dirName];
}



@end
