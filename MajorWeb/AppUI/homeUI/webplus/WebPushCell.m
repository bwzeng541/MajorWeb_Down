//
//  WebPushCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/19.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "WebPushCell.h"
#import <BUAdSDK/BUNativeAd.h>
#import <BUAdSDK/BUNativeAdRelatedView.h>

@interface WebPushCell ()
{
}
@property(strong,nonatomic)WebPushItem *pushItem;
@property(strong,nonatomic)UIImageView *iconImageView;
@end
@implementation WebPushCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)dealloc{
}


-(void)addBackImage{
    if (!self.iconImageView) {
        self.iconImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.iconImageView];
        self.iconImageView.tag = 100;
    }
}

-(void)initWithItem:(WebPushItem*)item{
    self.pushItem = item;
    [self addBackImage];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:item.iconUrl]];
    self.backgroundColor = [UIColor blackColor];
}
@end
