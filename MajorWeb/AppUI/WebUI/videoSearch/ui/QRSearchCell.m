//
//  QRSearchCell.m
//  QRTools
//
//  Created by zengbiwang on 2020/7/15.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import "QRSearchCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
@interface QRSearchCell()
@property(weak)IBOutlet UIImageView *imageView;
@property(weak)IBOutlet UILabel *label;

@end

@implementation QRSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)buildItem:(NSDictionary*)item{
    [self.imageView setImageWithURL:[NSURL URLWithString:item[@"bgUrl"]] placeholderImage:[UIImage imageNamed:@"qr_search_default"]];
    self.label.text = item[@"name"];
}
@end
