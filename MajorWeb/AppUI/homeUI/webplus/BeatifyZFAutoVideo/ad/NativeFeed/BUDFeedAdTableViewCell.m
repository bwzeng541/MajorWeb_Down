//
//  BUDFeedAdCell.m
//  BUDemo
//
//  Created by carlliu on 2017/7/27.
//  Copyright © 2017年 bytedance. All rights reserved.
//

#import "BUDFeedAdTableViewCell.h"
#import "BUDFeedStyleHelper.h"
#import "BUDMacros.h"
#import "UIImageView+AFNetworking.h"
//#import "NSString+LocalizedString.h"

static CGFloat const margin = 15;
static CGSize const logoSize = {15, 15};
static UIEdgeInsets const padding = {10, 15, 10, 15};

@implementation BUDFeedAdBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildupView];
    }
    return self;
}

- (void)buildupView {
    CGFloat swidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.separatorLine = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, swidth-margin*2, 0.5)];
    self.separatorLine.backgroundColor = BUD_RGB(0xd9, 0xd9, 0xd9);
    [self.contentView addSubview:self.separatorLine];
    
    self.iv1 = [[UIImageView alloc] init];
    self.iv1.userInteractionEnabled = YES;
    [self.contentView addSubview:self.iv1];
    
    self.adTitleLabel = [UILabel new];
    self.adTitleLabel.numberOfLines = 0;
    self.adTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.adTitleLabel];
    
    self.adDescriptionLabel = [UILabel new];
    self.adDescriptionLabel.numberOfLines = 0;
    self.adDescriptionLabel.textColor = BUD_RGB(0x55, 0x55, 0x55);
    self.adDescriptionLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.adDescriptionLabel];
    
    // Add custom button
    [self.contentView addSubview:self.customBtn];
    
    self.nativeAdRelatedView = [[BUNativeAdRelatedView alloc] init];
    
    [self addAccessibilityIdentifier];
}

+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width height:(float)height{
    return 0;
}

- (void)refreshUIWithModel:(BUNativeAd *)model {
    self.nativeAd = model;
    [self.iv1 addSubview:self.nativeAdRelatedView.logoImageView];
    [self.contentView addSubview:self.nativeAdRelatedView.dislikeButton];
    [self.contentView addSubview:self.nativeAdRelatedView.adLabel];
    [self.nativeAdRelatedView refreshData:model];

}

- (UIButton *)customBtn {
    if (!_customBtn) {
        _customBtn = [[UIButton alloc] init];
        [_customBtn setTitle:@"自定义点击" forState:UIControlStateNormal];
        [_customBtn setTitleColor:BUD_RGB(0x47, 0x8f, 0xd2) forState:UIControlStateNormal];
        _customBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _customBtn;
}

#pragma mark addAccessibilityIdentifier
- (void)addAccessibilityIdentifier {
    self.adTitleLabel.accessibilityIdentifier = @"feed_title";
    self.adDescriptionLabel.accessibilityIdentifier = @"feed_des";
    self.nativeAdRelatedView.dislikeButton.accessibilityIdentifier = @"dislike";
    self.customBtn.accessibilityIdentifier = @"feed_button";
    self.iv1.accessibilityIdentifier = @"feed_view";
}

@end

@implementation BUDFeedAdLeftTableViewCell

- (void)refreshUIWithModel:(BUNativeAd *_Nonnull)model {
    [super refreshUIWithModel:model];
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat contentWidth = (width - 2 * margin);
    CGFloat y = padding.top;
    
    BUImage *image = model.data.imageAry.firstObject;
    const CGFloat imageWidth = (width - 2 * margin) / 3;
    const CGFloat imageHeight = imageWidth * (image.height / image.width);
    CGFloat imageX = width - margin - imageWidth;
    self.iv1.frame = CGRectMake(imageX, y, imageWidth, imageHeight);
    [self.iv1 setImageWithURL:[NSURL URLWithString:image.imageURL] placeholderImage:nil];
    self.nativeAdRelatedView.logoImageView.frame = CGRectMake(imageWidth - logoSize.width, imageHeight - logoSize.height, logoSize.width, logoSize.height);
    
    CGFloat maxTitleWidth =  contentWidth - imageWidth - margin;
    NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle scale:1];
    CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(maxTitleWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
    self.adTitleLabel.frame = CGRectMake(padding.left, y , maxTitleWidth, MIN(titleSize.height, imageHeight));
    self.adTitleLabel.attributedText = attributedText;
    
    y += imageHeight;
    y += 5;
    
    CGFloat originInfoX = padding.left;
    self.nativeAdRelatedView.adLabel.frame = CGRectMake(originInfoX, y + 3, 26, 14);
    originInfoX += 24;
    originInfoX += 5;
    
    CGFloat dislikeX = width - 24 - padding.right;
    self.nativeAdRelatedView.dislikeButton.frame = CGRectMake(dislikeX, y, 24, 20);
    
    CGFloat maxInfoWidth = width - 2 * margin - 24 - 24 - 10;
    self.adDescriptionLabel.frame = CGRectMake(originInfoX , y , maxInfoWidth, 20);
    self.adDescriptionLabel.attributedText = [BUDFeedStyleHelper subtitleAttributeText:model.data.AdDescription scale:1];
}

+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width height:(float)height{
    BUImage *image = model.data.imageAry.firstObject;
    const CGFloat contentWidth = (width - 2 * margin) / 3;
    const CGFloat imageHeight = contentWidth * (image.height / image.width);
    return padding.top + imageHeight + 10 + 20 + padding.bottom;
}

@end

@implementation BUDFeedAdLargeTableViewCell

- (void)refreshUIWithModel:(BUNativeAd *)model {
    [super refreshUIWithModel:model];
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat contentWidth = (width - 2 * margin);
    CGFloat y = padding.top;
    
    NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle scale:1];
    CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
    self.adTitleLabel.frame = CGRectMake(padding.left, y , contentWidth, titleSize.height);
    self.adTitleLabel.attributedText = attributedText;
    
    y += titleSize.height;
    y += 5;
    
    BUImage *image = model.data.imageAry.firstObject;
    const CGFloat imageHeight = contentWidth * (image.height / image.width);
    self.iv1.frame = CGRectMake(padding.left, y, contentWidth, imageHeight);
    [self.iv1 setImageWithURL:[NSURL URLWithString:image.imageURL] placeholderImage:nil];
    self.nativeAdRelatedView.logoImageView.frame = CGRectMake(contentWidth - logoSize.width, imageHeight - logoSize.height, logoSize.width, logoSize.height);
    
    y += imageHeight;
    y += 10;
    
    CGFloat originInfoX = padding.left;
    self.nativeAdRelatedView.adLabel.frame = CGRectMake(originInfoX, y + 3, 26, 14);
    originInfoX += 24;
    originInfoX += 10;
    
    CGFloat dislikeX = width - 24 - padding.right;
    self.nativeAdRelatedView.dislikeButton.frame = CGRectMake(dislikeX, y, 24, 20);
    
    CGFloat maxInfoWidth = width - 2 * margin - 24 - 24 - 10 - 100;
    self.adDescriptionLabel.frame = CGRectMake(originInfoX , y , maxInfoWidth, 20);
    self.adDescriptionLabel.attributedText = [BUDFeedStyleHelper subtitleAttributeText:model.data.AdDescription scale:1];
    
    CGFloat customBtnWidth = 100;
    self.customBtn.frame = CGRectMake(dislikeX - customBtnWidth, y, customBtnWidth, 20);
}

- (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width height:(float)height{
    CGFloat contentWidth = (width - 2 * margin);
    NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle scale:1];
    CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
    
    BUImage *image = model.data.imageAry.firstObject;
    const CGFloat imageHeight = contentWidth * (image.height / image.width);
    return padding.top + titleSize.height + 5+ imageHeight + 10 + 20 + padding.bottom;
}


@end

@interface BUDFeedVideoAdTableViewCell ()

@end

@implementation BUDFeedVideoAdTableViewCell

- (void)buildupView {
    [super buildupView];
    // Video ad did not use iv1, temporarily hidden...
    self.iv1.hidden = YES;
    
    self.bgView = [UIView new];
    self.bgView.backgroundColor = BUD_RGB(0xf5, 0xf5, 0xf5);
    [self.contentView insertSubview:self.bgView atIndex:0];
}

- (void)refreshUIWithModel:(BUNativeAd *)model {
    [super refreshUIWithModel:model];
    
    if (!self.nativeAdRelatedView.videoAdView.superview) {
        [self.contentView addSubview:self.nativeAdRelatedView.videoAdView];
    }
    
    if (self.creativeButton && !self.creativeButton.superview) {
        [self.contentView addSubview:self.creativeButton];
    }
    CGFloat width = self.frame.size.width;
    float scaleX = 1;
    float www = MY_SCREEN_WIDTH;
    if (width<www-10) {
        scaleX = width/www;
    }
    CGFloat contentWidth = (width - 2 * margin * scaleX);
    CGFloat y = padding.top * scaleX;
    
    NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle scale:scaleX];
    CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
    self.adTitleLabel.frame = CGRectMake(padding.left*scaleX, y , contentWidth, titleSize.height);
    self.adTitleLabel.attributedText = attributedText;
    
    y += titleSize.height;
    y += (5*scaleX);
    
    // 广告展位图
    BUImage *image = model.data.imageAry.firstObject;
    const CGFloat imageHeight = contentWidth * (image.height / image.width);
    
    self.nativeAdRelatedView.videoAdView.frame = CGRectMake(padding.left*scaleX, y, contentWidth, imageHeight);
    
    y += imageHeight;
    
    self.bgView.frame = CGRectMake(padding.left, y, contentWidth, self.creativeButton.frame.size.height + 20);
    
    y += 10;
    
    // creativeButton //右下角
    [self.creativeButton setTitle:self.nativeAd.data.buttonText forState:UIControlStateNormal];
    [self.creativeButton sizeToFit];
    CGSize buttonSize = self.creativeButton.frame.size;
    self.creativeButton.frame = CGRectMake((contentWidth - buttonSize.width + 10), y, buttonSize.width*scaleX, buttonSize.height*scaleX);
    
    // source
    CGFloat maxInfoWidth = width - 2 * margin - buttonSize.width - 10 - 15;
    self.adDescriptionLabel.frame = CGRectMake(padding.left + 5 , y+2 , maxInfoWidth, 20);
    //    self.adDescriptionLabel.attributedText = [BUDFeedStyleHelper subtitleAttributeText:model.data.AdDescription];
    self.adDescriptionLabel.text = model.data.AdDescription;
    self.adDescriptionLabel.font = [UIFont systemFontOfSize:14*scaleX];
    y += buttonSize.height;
    
    y += 15;
    CGFloat originInfoX = padding.left;
    self.nativeAdRelatedView.adLabel.frame = CGRectMake(originInfoX, (y + 3), 26, 14);
    
    CGFloat dislikeX = width - 24 - padding.right;
    self.nativeAdRelatedView.dislikeButton.frame = CGRectMake(dislikeX, y, 24, 20);
    if(scaleX<1){
        self.creativeButton.hidden = self.adDescriptionLabel.hidden = YES;
        CGRect rect = self.frame ;
        rect.size.height -= self.adDescriptionLabel.bounds.size.height;
        CGRect adRect = self.nativeAdRelatedView.adLabel.frame;
        CGRect disRect = self.nativeAdRelatedView.dislikeButton.frame;
        CGRect videoFrame = self.nativeAdRelatedView.videoAdView.frame;
        adRect.origin.y = videoFrame.origin.y+videoFrame.size.height+3;
        disRect.origin.y = adRect.origin.y;
        self.nativeAdRelatedView.dislikeButton.frame =disRect;
        self.nativeAdRelatedView.adLabel.frame =adRect;
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, disRect.origin.y+disRect.size.height*1.5);
        UIView *pareView = self.superview;
        pareView.frame = CGRectMake(pareView.frame.origin.x, pareView.frame.origin.y, pareView.frame.size.width, self.frame.size.height-10);
        pareView.clipsToBounds = YES;
    }
}

+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width height:(float)height{
    CGFloat contentWidth = (width - 2 * margin);
    NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle scale:1];
    
    CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
    
    BUImage *image = model.data.imageAry.firstObject;
    const CGFloat imageHeight = contentWidth * (image.height / image.width);
    return padding.top + titleSize.height + 10+ imageHeight + 15 + 20 + padding.bottom + 28;
}

- (UIButton *)creativeButton
{
    if (!_creativeButton) {
        _creativeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_creativeButton setTitle:@"点击下载" forState:UIControlStateNormal];
        [_creativeButton setContentEdgeInsets:UIEdgeInsetsMake(4.0, 8.0, 4.0, 8.0)];
        [_creativeButton setTitleColor:[UIColor colorWithRed:0.165 green:0.565 blue:0.843 alpha:1] forState:UIControlStateNormal];
        _creativeButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_creativeButton sizeToFit];
        _creativeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _creativeButton.clipsToBounds = YES;
        [_creativeButton.layer setBorderColor:[UIColor colorWithRed:0.165 green:0.565 blue:0.843 alpha:1].CGColor];
        [_creativeButton.layer setBorderWidth:1];
        [_creativeButton.layer setCornerRadius:6];
        [_creativeButton.layer setShadowRadius:3];
        _creativeButton.accessibilityIdentifier = @"feed_button";
    }
    return _creativeButton;
}
@end
