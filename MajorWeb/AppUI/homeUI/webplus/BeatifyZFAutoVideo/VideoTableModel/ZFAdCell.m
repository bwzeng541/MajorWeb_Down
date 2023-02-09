//
//  ZFAdCell.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/9/2.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "ZFAdCell.h"

@implementation ZFAdCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLayout:(ZFAdCellLayout *)layout {
    _layout = layout;
    self.backgroundColor = RGBCOLOR(100, 100, 399);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
