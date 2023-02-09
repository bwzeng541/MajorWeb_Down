 
#import <UIKit/UIKit.h>

#define GGSearchWordCount 100
 typedef enum GGSearchType{
    GGSearch_Html,
    GGSearch_Video,
    GGSearch_Pic,
}GGSearchType;

NS_ASSUME_NONNULL_BEGIN
@protocol GGWebSearchViewDelegate <NSObject>
-(void)ggWebSearchViewClick:(NSString*)word type:(GGSearchType)type;
@end

@interface GGWebSearchView : UIView
-(instancetype)initWithFrame:(CGRect)frame  type:(GGSearchType)type wordArray:(NSArray*)wordArray title:(NSString*)title delegate:(id<GGWebSearchViewDelegate>)delegate maxLine:(NSInteger)maxLine ;
@end

NS_ASSUME_NONNULL_END
