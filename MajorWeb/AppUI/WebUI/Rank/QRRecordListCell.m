//
//  QRRecordListCell.m
//  QRTools
//
//  Created by bxing zeng on 2020/5/6.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRRecordListCell.h"

@implementation QRRecordListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(IBAction)pressDel:(id)sender{
    if ([self.delegate respondsToSelector:@selector(clickDel:)]) {
        [self.delegate clickDel:self];
    }
}



-(IBAction)pressRankDel:(id)sender{
    if ([self.delegate respondsToSelector:@selector(clickDel:)]) {
        [self.delegate clickDel:self];
    }
}

@end
