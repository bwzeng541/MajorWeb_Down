#import <UIKit/UIKit.h>

typedef void (^WebDesListViewCloseBlock)(id v);
typedef void (^WebDesListViewSelectBlock)(NSInteger index);
typedef void (^WebDesListViewSelectUrlBlock)(NSString*url);
typedef void (^WebDesListViewUpdateLineBlock)(NSInteger index);
@interface WebDesListView : UIView
@property(readonly,nonatomic)BOOL isCanFireAutoFadeOut;
@property(copy)WebDesListViewSelectUrlBlock selectUrlBlock;
-(instancetype)initWith:(CGRect)frame viewOffset:(float)viewOffsetH block: (WebDesListViewCloseBlock)block selectBlock:(WebDesListViewSelectBlock)selctblock updateLine:(WebDesListViewUpdateLineBlock)updateLine  nCount:(NSArray*)nCount isSousouType:(BOOL)isSousouType;
-(void)updateSelectIndex:(NSInteger)index;
-(void)updateSelectState;
-(void)updateLineData:(NSArray*)array;
-(void)updateCulm:(NSInteger)customCulm;
-(void)initUI:(NSArray*)lineArray title:(NSString*)title;
-(UIView*)getCollectionView;
@end
