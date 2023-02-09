
#import <UIKit/UIKit.h>
#import "MajorModeDefine.h"
@interface ContentWebView : UIView
//当前操作试图界面
-(instancetype)initWithSnapshotFrame:(CGRect)frame config:(WebConfigItem*)webUserConfig webUUID:(NSString*)webUUID imageData:(NSData*)imageData webTopArray:(NSArray*)webTopArray lastUrl:(NSString*)lastUrl;
-(instancetype)initWithFrame:(CGRect)frame config:(WebConfigItem*)webUserConfig;
-(void)updateShowState:(BOOL)showState;
-(void)removeFromSuperviewAndDesotryWeb;
-(void)stopBanner;
-(void)createBottomFixBug;
-(void)createSnapshotViewOfView:(BOOL)isRemoveWeb;
-(NSData*)getSnapshotSmallImageData;
-(void)showSnapshot:(BOOL)isShow;
-(void)snapshotToExct;
-(void)tryPlayOperation;
-(void)loaUrl:(NSString*)url config:(WebConfigItem*)webUserConfig;
@property(nonatomic,readonly)WebConfigItem *webUserConfig;
@property(nonatomic,readonly)NSString *webUUID;
@property(nonatomic,readonly)NSArray *webTopArray;
@property(nonatomic,readonly)NSString *requestUrl;
@property(nonatomic,readonly)NSString *title;

@property(nonatomic,strong)NSString *snapsthotBigImagefile;
@end
