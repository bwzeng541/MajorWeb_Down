//
//  Majo.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/10/12.
//  Copyright © 2018年 cxh. All rights reserved.
//

#import "MajorRecordContentView.h"

@interface MajorRecordContentView(){
    UILabel *titleLabel;
    UILabel *urlLabel;
    UILabel *timeLabel;
    UIImageView *iconImage;
    float lableH;
    float fontSize;
}
@property(assign,nonatomic)CGRect imageRect;
@end

@implementation MajorRecordContentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    fontSize = 12;
    lableH = 20;//iconImage->16:9
    iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width*0.56)];
    self.imageRect = iconImage.frame;
    [self addSubview:iconImage];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, lableH)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = RGBACOLOR(0, 0, 0, 0.8);
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,  frame.size.height-lableH*4.5, frame.size.width, lableH)];
    timeLabel.backgroundColor = [UIColor clearColor];
    
    urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,  frame.size.height-lableH*4, frame.size.width, lableH)];
    titleLabel.textAlignment = urlLabel.textAlignment = NSTextAlignmentLeft;
    urlLabel.backgroundColor =  RGBACOLOR(0, 0, 0, 0.8);
    titleLabel.textColor = urlLabel.textColor = RGBCOLOR(105, 105, 105);
    titleLabel.font = urlLabel.font = [UIFont systemFontOfSize:fontSize];
    timeLabel.font = [UIFont systemFontOfSize:fontSize*0.8];
    [self addSubview:urlLabel];
    [self addSubview:titleLabel];
    [self addSubview:timeLabel];
    return self;
}


-(void)initVideoInfo:(NSString*)titleName url:(NSString*)url time:(NSString*)time base64Png:(NSString*)base64Png fontScale:(float)fontScale number:(NSInteger)line
{
    titleLabel.hidden = YES;
    urlLabel.hidden = YES;
    iconImage.hidden = YES;
    NSInteger lablelLine = line;
    fontSize = 12;
    titleLabel.font = urlLabel.font = [UIFont systemFontOfSize:fontSize];
    
    timeLabel.frame = CGRectMake(0,  self.frame.size.height-lableH*2, self.frame.size.width, lableH);
    urlLabel.frame = CGRectMake(0,  self.frame.size.height-lableH*(line==1)?1:1.5, self.frame.size.width, lableH);
    
    if (titleName) {
        titleLabel.text = titleName;
        titleLabel.hidden = NO;
    }
    if (url) {
        urlLabel.text = url;
        urlLabel.hidden = NO;
        if (line>1) {
            fontSize *= 1.2;
        }
        urlLabel.font = titleLabel.font = [UIFont systemFontOfSize:fontSize*fontScale];
        CGRect rect = urlLabel.frame;
        rect.origin = CGPointMake(rect.origin.x, self.frame.size.height-lableH*((line==1)?1:1.5)*fontScale);
        rect.size   = CGSizeMake(rect.size.width, lableH*fontScale);
        urlLabel.frame = rect;
        rect = titleLabel.frame;
        rect.origin = CGPointMake(rect.origin.x,0);
        
        
        CGSize nameSize =  [titleName boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:titleLabel.font,NSFontAttributeName,nil]
                                                   context:nil].size;
        
        if (lablelLine>1 && nameSize.width<rect.size.width) {
            lablelLine=1;
        }
        rect.size   = CGSizeMake(rect.size.width, lableH*fontScale*lablelLine);
        titleLabel.frame = rect;
        titleLabel.numberOfLines=lablelLine;
        if (line>1) {
            urlLabel.font = [UIFont systemFontOfSize:fontSize*fontScale*0.8];
            titleLabel.center = CGPointMake(titleLabel.center.x, iconImage.center.y+iconImage.bounds.size.height/2+titleLabel.bounds.size.height/2);
            urlLabel.backgroundColor = timeLabel.backgroundColor = titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor blackColor];
            timeLabel.textColor = urlLabel.textColor = RGBCOLOR(109, 109, 109);
            NSDateFormatter *formatterNew = [[NSDateFormatter alloc] init];
            [formatterNew setDateFormat:@"yyyyMMddHHmmss"];
            NSDate *date =[formatterNew dateFromString:time];//
            timeLabel.text = [NSString stringWithFormat:@"%d-%02d-%02d  Time:%02d:%02d",[date year],[date month],[date day],[date hour],[date minute]];
            timeLabel.frame = CGRectMake(0, titleLabel.frame.origin.y+nameSize.height+5, titleLabel.frame.size.width, titleLabel.frame.size.height);
            urlLabel.frame = CGRectMake(0, timeLabel.frame.origin.y+timeLabel.frame.size.height*0.8, urlLabel.frame.size.width, urlLabel.frame.size.height);
            
        }
    }
    if (base64Png) {
        iconImage.hidden = NO;
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64Png options:0];
        if ([decodedData length]>10) {
            iconImage.image = [UIImage imageWithData:decodedData];
        }
        else{
            NSString *path = [[NSBundle mainBundle]pathForResource:@"AppMain.bundle/play_re" ofType:@"png"];
            iconImage.image = [UIImage imageWithContentsOfFile:path];
        }
    }
}

@end
