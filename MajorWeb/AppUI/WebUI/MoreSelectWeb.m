//
//  MoreSelectWeb.m
//  MajorWeb
//
//  Created by zengbiwang on 2018/12/12.
//  Copyright © 2018 cxh. All rights reserved.
//

#import "MoreSelectWeb.h"
#import "MainMorePanel.h"
@interface MoreSelectWeb()<UITableViewDelegate,UITableViewDataSource>
@property(copy)MoreSelectBlock selectBlock;
@property(assign)float cellH;
@end
@implementation MoreSelectWeb
-(id)initWithFrame:(CGRect)frame selectBlock:(MoreSelectBlock)selectBlock;
{
    self = [super initWithFrame:frame];
    self.selectBlock = selectBlock;
    self.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
    self.cellH = 70;
    //505X852
    UIImage *image = UIImageFromNSBundlePngPath(@"Brower.bundle/more_select_icon");
    CGSize size = image.size;
    float offsetY = 60,offsetX=70,btnWH = 79;;
    if (IF_IPHONE) {
        size.width /=1.5;
        size.height /=1.5;
        offsetY /=1.5;
        offsetX /=1.5;
        btnWH /=1.5;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-size.width)/2, (frame.size.height-size.height)/2, size.width, size.height)];
    imageView.image = image;
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(offsetX, offsetY, size.width-2*offsetX, size.height-2*offsetY) style:(UITableViewStylePlain)];
    [imageView addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView reloadData];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btnClose];
    btnClose.frame = CGRectMake((frame.size.width-btnWH)/2, imageView.frame.origin.y+imageView.frame.size.height+10, btnWH, btnWH);
    [btnClose setImage:UIImageFromNSBundlePngPath(@"Brower.bundle/xbtn_icon") forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

-(void)closeView:(UIButton*)sender{
    if (self.selectBlock) {
        self.selectBlock([NSArray array]);
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [MainMorePanel getInstance].validPanelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SetListCell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDictionary *info = [[MainMorePanel getInstance].validPanelArray objectAtIndex:indexPath.row];
    NSMutableAttributedString *ss = [info objectForKey:OneHeaderStringKey];
    onePanel *panel =  [info objectForKey:OnePlayKey];
    
    
    CGSize size = CGSizeMake(tableView.bounds.size.width, self.cellH);
    UIImageView *imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, size.height*0.2, size.height*0.6, size.height*0.6)];
    [cell.contentView addSubview:imageIcon];
    NSString *iconUrl = panel.iconurl;
    NSString *tmpIcon = @"AppMain.bundle/headerIcon.png";
    if (iconUrl.length<5) {
        imageIcon.image = [UIImage imageNamed:tmpIcon];
    }
    else{
        [imageIcon sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:tmpIcon]];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageIcon.frame.size.width+imageIcon.frame.origin.x+10,0,size.width-20,size.height)];
    label.attributedText = ss;
    label.userInteractionEnabled =YES;
    label.numberOfLines =2;
    [cell.contentView addSubview:label];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectBlock){
        self.selectBlock(((onePanel*)[[[MainMorePanel getInstance].validPanelArray objectAtIndex:indexPath.row] objectForKey:OnePlayKey]).array);
    }
}
@end
