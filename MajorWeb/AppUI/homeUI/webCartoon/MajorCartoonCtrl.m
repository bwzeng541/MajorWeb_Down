//
//  MajorCartoonCtrl.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/2.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorCartoonCtrl.h"
#import "MajorWebCartoonView.h"
#import "MainMorePanel.h"
#import "WebCartoonManager.h"
#import "NSString+MKNetworkKitAdditions.h"
static NSInteger MajorCartoonIndex = -1;
@interface MajorCartoonCtrl ()
{
    BOOL isStautsBarHidden;
}
@property(strong,nonatomic)MajorWebCartoonView *majorView;
@end

@implementation MajorCartoonCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak __typeof(self)weakSelf = self;
    if (MajorCartoonIndex==-1) {
        MajorCartoonIndex = arc4random() % [MainMorePanel getInstance].morePanel.manhuaurl.count;
    }
    self.majorView = [[MajorWebCartoonView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT) index:MajorCartoonIndex];
    [self.view addSubview:self.majorView];
    manhuaurlInfo *info = [[MainMorePanel getInstance].morePanel.manhuaurl objectAtIndex:MajorCartoonIndex];
    NSDictionary *parseInfo = [[MainMorePanel getInstance].morePanel.manhuaParseInfo objectForKey:info.key];
    [[WebCartoonManager getInstance]startWithUrl:[info.url md5] url:info.url parseInfo:parseInfo updateBlock:^(WebCartoonItem * _Nonnull item, NSArray * _Nonnull array, BOOL isRemoveOldAll) {
            MajorWebCartoonView  *view = weakSelf.majorView;
            if (array.count>0) {
                [view addDataArray:array isRemoveOldAll:isRemoveOldAll];
            }
            else{
                [view addDataItem:item isRemoveOldAll:isRemoveOldAll];
            }
        }beginUrlRequestBlock:^{
            MajorWebCartoonView  *view = weakSelf.majorView;
            [view beginUrlRequest];
        } falidBlock:^{
            
        }];
   
    // Do any additional setup after loading the view.
}

-(BOOL)prefersStatusBarHidden{
    return isStautsBarHidden;
}

-(void)showStautsBar:(BOOL)isHidden{
    isStautsBarHidden = isHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
