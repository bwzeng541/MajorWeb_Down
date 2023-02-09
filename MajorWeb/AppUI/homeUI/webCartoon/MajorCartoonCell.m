//
//  MajorCartoonCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/29.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorCartoonCell.h"
#import <BUAdSDK/BUAdSDK.h>
#import "BUDFeedAdTableViewCell.h"
#import "IQUIWindow+Hierarchy.h"
#import "BUDAdManager.h"
#import "UIImage+webCartoonTools.h"
#define Cartoon_MAINTHREAD_SYNC(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#define YB_MAINTHREAD_ASYNC(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

static NSDate *requestAdTime = nil;
@interface MajorCartoonCell ()<WebCartoonImageDelegate,BUNativeAdsManagerDelegate,BUNativeAdDelegate,BUVideoAdViewDelegate>
@property(strong,nonatomic)WebCartoonItem *cartoonItem;
@property(strong,nonatomic)UIImageView *cartoonImageView;
@property(weak,nonatomic)UICollectionView *tableView;
@property(assign,nonatomic)NSInteger index;
@property (nonatomic, copy) void(^updateImageBlock)(void);
@property (nonatomic, copy) void(^updateAdBlock)(void);
@property(nonatomic,assign)BOOL isCanReqeustAd;
@property(nonatomic,strong)NSIndexPath *indexPath;
//广告部分
@property(strong)BUNativeAdsManager *adManager;
@property(strong)UIView *adNativeView;
@property(strong)NSMutableArray *nativeAdDataArray;
@property(assign)NSInteger adIndex;
//end
@end
@implementation MajorCartoonCell
//ad begin




//end ad
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)dealloc{
     self.cartoonItem.imagedelegate = nil;
    self.cartoonItem = nil;
}


-(void)configWithConfig:(WebCartoonItem*)config index:(NSInteger)index tableView:(id)tabelView{
    if (!self.cartoonImageView) {
        self.index = -1;
        self.cartoonImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.cartoonImageView];
    }
    if (self.cartoonItem!=config || self.index!=index) {
        self.index = index;
        self.indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        self.tableView = tabelView;
        self.cartoonItem=config;
        self.cartoonItem.imagedelegate = self;
        if (![self.cartoonItem tryToLoaclFile]) {
            if (!self.cartoonItem.image) {
                self.cartoonImageView.image = [UIImage imageNamed:@"CartoonAsset.bundle/loading.jpg"];
            }
            else{
                self.cartoonImageView.image = self.cartoonItem.image;
            }
            [self.cartoonItem reqeustAsset];
        }
        else{
            [self loadFromFile];
        }
    }
    else{
        [self loadFromFile];
    }
    [self.cartoonImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(self.mas_width).multipliedBy(self.cartoonItem.imageSize.height/self.cartoonItem.imageSize.width);
    }];
 }

-(void)loadFromFile{
    if ([self.cartoonItem tryToLoaclFile]) {
        UIImage *image  = [UIImage decode:[UIImage imageWithContentsOfFile:self.cartoonItem.filePath]];
        self.cartoonItem.imageSize = image.size;
        self.cartoonImageView.image = image;
        [self updateWebImageSuccess:self.cartoonItem];
    }
}

-(void)updateWebImageFromWeb:(id)object{
    if (self.cartoonItem == object) {
        UIImage *image  = [UIImage decode:[UIImage imageWithContentsOfFile:self.cartoonItem.filePath]];
        self.cartoonItem.imageSize = image.size;
        [self updateWebImageSizeSuccess:self.cartoonItem];
        self.cartoonImageView.image = image;
        [self updateWebImageSuccess:self.cartoonItem];
    }
}

-(void)updateWebImageSizeSuccess:(id)object{
    if (self.cartoonItem==object) {
            [self.tableView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.index inSection:0]]];
    }
}


-(void)updateWebImageProgress:(id)object{
    if (self.cartoonItem==object) {
         self.cartoonImageView.image = [UIImage imageWithContentsOfFile:self.cartoonItem.filePath];
    }
}

-(void)updateWebImageSuccess:(id)object{
    __weak __typeof(self)weakSelf = self;
    self.updateImageBlock = ^{
        WebCartoonItem *v = (WebCartoonItem*)object;
        if (weakSelf.cartoonItem==object) {
            [weakSelf.delegate saveCartoonImageSize:v.uuid imageSize:v.imageSize];
        }
    };
    YB_MAINTHREAD_ASYNC(_updateImageBlock);
}

-(void)updateWebImageFaild:(id)object{
    if (self.cartoonItem==object) {

    }
}

@end
