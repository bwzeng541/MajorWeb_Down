//
//  MajorVideosSelect.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/19.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorVideosSelect.h"

@interface MajorVideosSelect ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *tableView;
    float cellW,cellH;
    UIImageView *imageView;
}
@property(copy,nonatomic)NSMutableArray *arrayBtns;
@property(copy,nonatomic)NSString *videoUrl;
@property(copy,nonatomic)NSArray *videoArray;
@end

@implementation MajorVideosSelect

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

-(void)updateFrame:(CGRect)rect{
    self.view.frame = rect;
    //136X40  110X40;
    cellW=110;cellH=40;
    float imw = 136, imh = 40;
    if (IF_IPHONE) {
        cellH/=2;cellW/=2;imh/=2;imw/=2;
        cellH*=1.5;cellW*=1.5;imh*=1.5;imw*=1.5;
    }
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marjor_change_quality"]];
    imageView.frame = CGRectMake(rect.size.width-imw, 0, imw, imh);
    [self.view addSubview:imageView];
}

-(void)click:(UIButton*)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(marjor_select_video_url:)]) {
        [_delegate marjor_select_video_url:self.videoArray[sender.tag]];
    }
}

-(void)updateVideoArray:(NSArray*)videoArray{
    NSMutableArray *newArray = [NSMutableArray array];
    for(int i = 0; i < videoArray.count; i++) {
        NSString *string = [videoArray objectAtIndex:i];
            if ( ! [newArray containsObject:string] ) {
                    [newArray addObject:string];
               }
    }
    self.videoArray = [NSArray arrayWithArray:newArray];
    [self.arrayBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.arrayBtns removeAllObjects];
    if (videoArray.count>0) {
        self.view.alpha=1;
        [self updateBtns];
    }
    else{
        self.view.alpha=0;
    }
   // [tableView reloadData];
}

-(void)updateBtns{
    CGRect rect =  self.view.frame;
    float x = rect.size.width-cellW;
    float y = imageView.frame.origin.y+imageView.frame.size.height+5;
    for (int i = 0; i<self.videoArray.count; i++) {
       UIButton *btns =    [UIButton buttonWithType:UIButtonTypeCustom];
        btns.tag = i;
        if (self.videoUrl&& [self.videoUrl compare:[self.videoArray objectAtIndex:i]]==NSOrderedSame) {
            [btns setBackgroundImage:[UIImage imageNamed:@"marjor_select_back_"] forState:UIControlStateNormal];
        }
        else{
            [btns setBackgroundImage:[UIImage imageNamed:@"marjor_select_back"] forState:UIControlStateNormal];
        }
        [self.view addSubview:btns];
        [btns setTitle:[NSString stringWithFormat:@"线路%d",i+1] forState:UIControlStateNormal];
        btns.titleLabel.adjustsFontSizeToFitWidth = YES ;
        [btns addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        CGRect rect = CGRectMake(x, y+(i*(cellH+2)), cellW, cellH);
        btns.frame = rect;
        [self.arrayBtns addObject:btns];
    }
}

-(void)updateSelectUrl:(NSString*)videoUrl{
    self.videoUrl = videoUrl;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
         if (_delegate && [_delegate respondsToSelector:@selector(marjor_select_video_url:)] && indexPath.row<self.videoArray.count) {
            [_delegate marjor_select_video_url:self.videoArray[indexPath.row]];
        }
 }


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellH+2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCell"];
    }
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellW,cellH)];
    imageView.image = [UIImage imageNamed:@"marjor_select_back"];
    
    [cell.contentView addSubview:imageView];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellW, cellH)];
    lable.text = [NSString stringWithFormat:@"线路%ld",indexPath.row+1];
    if (self.videoUrl && [self.videoUrl compare:[self.videoArray objectAtIndex:indexPath.row]]==NSOrderedSame) {
        lable.textColor = [UIColor whiteColor];
    }
    else{
        lable.textColor = [UIColor blackColor];
    }
    lable.font = [UIFont systemFontOfSize:13];
    lable.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:lable];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];

    return cell;
}

@end
