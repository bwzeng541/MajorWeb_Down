//
//  MajorHistoryAndFavoriteCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/8/7.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorHistoryAndFavoriteCell.h"
#import "MajorRecordContentView.h"
@interface MajorHistoryAndFavoriteCell()
{
    UIImageView *delImageView;
    MajorRecordContentView *recordConentView;
}
@end

@implementation MajorHistoryAndFavoriteCell
- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
 
    return self;
}

-(void)initVideoInfo:(NSString*)titleName url:(NSString*)url time:(NSString*)time base64Png:(NSString*)base64Png
{
    if (!recordConentView && url) {
        recordConentView = [[MajorRecordContentView alloc]initWithFrame:self.bounds];
        [self addSubview:recordConentView];
    }
    [recordConentView initVideoInfo:titleName url:url time:time base64Png:base64Png fontScale:0.8 number:2];
}

-(void)updateDelBtn:(BOOL)isShow rect:(CGRect)rect{
    if (!delImageView) {
        delImageView = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:delImageView];
        delImageView.image = [UIImage imageNamed:@"AppMain.bundle/home_cell_del"];
        if (recordConentView) {
            CGRect rectNew = recordConentView.imageRect;
            delImageView.frame = CGRectMake(delImageView.frame.origin.x, (rectNew.size.height-rect.size.height)/2, rect.size.width, rect.size.height);
        }
    }
    delImageView.hidden = !isShow;
}
@end
