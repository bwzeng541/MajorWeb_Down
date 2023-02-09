//
//  ZFAutoAssetListView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/11.
//  Copyright © 2019 cxh. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define LineColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]

#import "ZFAutoAssetListView.h"
@interface ZFAutoAssetListView()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSArray *array;

@property(assign)float buttonH;
@property(assign)float buttonMargin;
@property(assign)float contentShift;
@property(assign)float animationTime;
@property (nonatomic, strong) UIView *contentView;

@end
@implementation ZFAutoAssetListView

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)initAttribute{
    self.buttonH = SCREEN_HEIGHT * (40.0/736.0)+1;
    self.buttonMargin = 10;
    self.contentShift = SCREEN_HEIGHT * (250.0/736.0)*1.5;
    self.animationTime = 0.8;
    self.backgroundColor = [UIColor colorWithWhite:0.614 alpha:0.700];
    [self initSubViews];
}

- (void)initSubViews{
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.frame = CGRectMake(20,(SCREEN_HEIGHT -self.contentShift)/2, SCREEN_WIDTH-40, self.contentShift);
    [self addSubview:self.contentView];
}

- (void)initTabelView{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 60)];
    titleLabel.text = @"视频分类-向下滑动选择更多";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:IF_IPHONE?20:24];
    [self.contentView addSubview:titleLabel];

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,titleLabel.frame.size.height , SCREEN_WIDTH-40, self.contentShift-titleLabel.frame.size.height) style:UITableViewStylePlain];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.contentView addSubview:self.tableView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissThePopView];
}

-(void)dismissThePopView{
    if ([self.delegate respondsToSelector:@selector(removeAssetListView)]) {
        [self.delegate removeAssetListView];
    }
}


- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        //初始化各种起始属性
        self.array = array;
        [self initAttribute];
        [self initTabelView];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id v = self.array[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [v objectForKey:@"name"];
    cell.textLabel.textColor = RGBCOLOR(0, 0, 0);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /// 如果正在播放的index和当前点击的index不同，则停止当前播放的index
    if([self.delegate respondsToSelector:@selector(clickAssetListView:)]){
        [self.delegate clickAssetListView:indexPath.row];
    }
    if ([self.delegate respondsToSelector:@selector(removeAssetListView)]) {
        [self.delegate removeAssetListView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.buttonH;
}


@end
