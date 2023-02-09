

#import <UIKit/UIKit.h>
#import "MajorHomeBaesCell.h"
typedef void (^HistoryAndFavoriteCellSelectBlock)(NSString *url,NSString *name);
typedef void (^HistoryAndFavoriteShowAllBlock)(NSArray *array,MajorShowAllContentType contentType);
typedef void (^HistoryAndFavoriteClickHistory)(void);
typedef void (^HistoryAndFavoriteClickFavorite)(void);

@interface HistoryAndFavoriteCell : MajorHomeBaesCell
-(void)initListArray:(NSArray*)array name:(NSString*)name contentType:(MajorShowAllContentType)contentType;
@property(copy)HistoryAndFavoriteCellSelectBlock liveClickBlock;
@property(copy)HistoryAndFavoriteShowAllBlock liveShowBlock;
@property(copy)HistoryAndFavoriteClickFavorite favoriteShowBlock;
@property(copy)HistoryAndFavoriteClickHistory historyShowBlock;
@property(readonly,assign)float cellSizeH;
@end
