#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BeatifyFavoriteListViewDelegate <NSObject>
-(void)clickAssetListView:(NSString*)url;
-(void)clickAssetRemove:(NSInteger)pos;
-(void)removeAssetListView;
@end
@interface BeatifyFavoriteListView : UIView
@property(weak)id<BeatifyFavoriteListViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
