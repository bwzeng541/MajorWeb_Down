//
//  MajorHomeBaesCell.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/24.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MajorHomeBaesCell.h"

@implementation MajorHomeBaesCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)updateRightLableState{
    
}

-(void)updateHeadColor:(UIColor*)color{
    if(self.headLabel.attributedText){
      NSMutableAttributedString *attrStr =  [[NSMutableAttributedString alloc] init];
        [attrStr setAttributedString:self.headLabel.attributedText];
        [attrStr addAttribute: NSForegroundColorAttributeName
                   value:color
                   range:NSMakeRange(0, attrStr.length)];
        self.headLabel.attributedText = attrStr;
    }
    else{
        self.headLabel.textColor = color;
    }
}
@end
