
#import <Foundation/Foundation.h>
#import <BUAdSDK/BUNativeAd.h>
#import <BUAdSDK/BUNativeAdRelatedView.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BUDFeedCellProtocol <NSObject>

@property (nonatomic, strong) UIButton *customBtn;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdRelatedView *nativeAdRelatedView;

- (void)refreshUIWithModel:(BUNativeAd *_Nonnull)model;
+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width height:(float)height;
@end


@interface BUDFeedAdBaseTableViewCell : UITableViewCell <BUDFeedCellProtocol>
@property (nonatomic, strong, nullable) UIView *separatorLine;
@property (nonatomic, strong, nullable) UIImageView *iv1;
@property (nonatomic, strong, nullable) UILabel *adTitleLabel;
@property (nonatomic, strong, nullable) UILabel *adDescriptionLabel;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) UIButton *customBtn;
@property (nonatomic, strong) BUNativeAdRelatedView *nativeAdRelatedView;

- (void)buildupView;
@end

@interface BUDFeedAdLeftTableViewCell : BUDFeedAdBaseTableViewCell
@end

@interface BUDFeedAdLargeTableViewCell : BUDFeedAdBaseTableViewCell
@end

@interface BUDFeedVideoAdTableViewCell : BUDFeedAdBaseTableViewCell
/**
 Creative button which is usede by video ad, need to actively add to the view, and register the view for user click.
 */
@property (nonatomic, strong, nullable) UIButton *creativeButton;
@property (nonatomic, strong) UIView *bgView;
@end

NS_ASSUME_NONNULL_END
