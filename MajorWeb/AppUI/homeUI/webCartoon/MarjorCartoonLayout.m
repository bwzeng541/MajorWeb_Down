//
//  MarjorCartoonLayout.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/2.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MarjorCartoonLayout.h"

@interface MarjorCartoonLayout(){
    CGSize layoutContentSize;
}

@end
@implementation MarjorCartoonLayout
- (void)prepareLayout{
    [super prepareLayout];
    NSInteger n = [self.delegate carToonItemNumber];
    layoutContentSize.width = 0;
    layoutContentSize.height = 0;
    for (int i =0; i < n; i++) {
        CGSize size = [self.delegate carToonItemSize:i];
        layoutContentSize.height += size.height;
        layoutContentSize.width =size.width;
    }
}

- (CGSize)collectionViewContentSize{
    return layoutContentSize;
}
@end
