//
//  ReferImageView.m
//  WatchApp
//
//  Created by zengbiwang on 2018/7/2.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "ReferImageView.h"
#import "MKNetworkEngine.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "PicUpPlusDef.h"
@interface ReferImageView()
{
    MKNetworkEngine *enging;
    MKNetworkOperation *downloadOption;
}
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,copy)NSString *iconFile;
@end
@implementation ReferImageView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)loadImageFrom:(NSString*)url webRefer:(NSString*)webRefer{
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    
    self.iconFile = [NSString stringWithFormat:@"%@%@",ReferCachesDir,[url md5]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.iconFile]) {
        [self loadImageFromLocalFile];
        return;
    }
    if (!enging) {
       enging = [[MKNetworkEngine alloc]initWithHostName:nil customHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:webRefer,@"Referer", nil]];
    }
    [downloadOption cancel];
    downloadOption = [enging operationWithURLString:url timeOut:5];
    [downloadOption addDownloadStream:[NSOutputStream outputStreamToFileAtPath:self.iconFile append:NO]];
    
    
    [downloadOption onCompletion:^(MKNetworkOperation *completedOperation) {
        [self loadImageFromLocalFile];
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        
    }];
    [enging enqueueOperation:downloadOption];
}

-(void)loadImageFromLocalFile{
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
         //将多余的部分切掉
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.iconFile]) {
        self.imageView.image = [UIImage imageWithContentsOfFile:self.iconFile];
    }
}

-(void)removeFromSuperview{
    [downloadOption cancel];downloadOption = nil;
    enging = nil;
     [super removeFromSuperview];
}
@end
