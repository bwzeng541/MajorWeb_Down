

#import <UIKit/UIKit.h>
typedef void (^MajorHomeContentViewShowTansuo)(void);
@interface MajorHomeContentView : UIView
@property(copy)MajorHomeContentViewShowTansuo tansuoBlock;
-(void)initContentData;
-(void)addWebBoradView:(UIView*)view;
-(void)updateHisotryAndFavorite;
@end
