
#import <UIKit/UIKit.h>
@protocol WebTopChannelDelegate<NSObject>
-(UIColor*)selectColor;
-(UIColor*)unSelectColor;
@optional
-(float)selectFontSize;
-(float)unSelectFontSize;
@end

typedef NSString* (^WebTopChannelFeeBackBlock)(void);
typedef void (^WebTopChannelClickBlock)(id item);
typedef void (^WebTopChannelMoreBlock)(void);
@interface WebTopChannel : UICollectionViewCell
-(void)updateTopArray:(NSArray*)topArray;
-(void)loadSouSouItem:(NSInteger)index;
-(void)updateSelect:(NSInteger)index;
-(void)hiddenMore;
-(void)updateVertical;
-(void)addAdBlockUI:(BOOL)isAdd;
-(id)initWithAdBlockView:(CGRect)frame;
@property(nonatomic,readonly)UICollectionView *collectionView;
@property(weak,nonatomic)id<WebTopChannelDelegate>delegate;
@property(copy)WebTopChannelClickBlock clickBlock;
@property(copy)WebTopChannelFeeBackBlock feeBackBlock;
@property(copy)WebTopChannelMoreBlock moreBlock;
@end
