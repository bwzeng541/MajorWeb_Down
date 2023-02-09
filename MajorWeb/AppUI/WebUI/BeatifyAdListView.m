//
//  BeatifyAdListView.m
//  BeatfiyCut
//
//  Created by zengbiwang on 2019/10/7.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "BeatifyAdListView.h"
#import "BeatifyWebAdManager.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define LineColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
@protocol ButtonTableViewCellDelegate <NSObject>
-(void)clickTabbleViewCell:(NSInteger)row;
@end

@interface ButtonTableViewCell : UITableViewCell

@property(nonatomic,strong) UILabel *label;
@property(nonatomic,strong) UIButton *btndele;
@property(nonatomic,readwrite) UIImageView *imageView1;
@property(nonatomic,weak)id<ButtonTableViewCellDelegate>delegate;
@end

@implementation ButtonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        float btnW = 100;
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH-20-btnW, SCREEN_HEIGHT * (40.0/736.0))];
        
        self.label.font = [UIFont systemFontOfSize:13];
        self.label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.label];
    
        UIView *view = [UIView new];
        [self addSubview:view];
        view.backgroundColor = LineColor;
        view.frame = CGRectMake(0, SCREEN_HEIGHT * (40.0/736.0), SCREEN_WIDTH-40, 1);
        
         self.btndele = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.btndele setFrame:CGRectMake(SCREEN_WIDTH-btnW-20, 0, btnW, self.label.frame.size.height)];
        [self.btndele setTitle:@"取消屏蔽" forState:UIControlStateNormal];
        self.btndele.titleLabel.font = [UIFont systemFontOfSize:13];
        self.btndele.titleLabel.textColor = [UIColor redColor];
        [self addSubview:self.btndele];
        [self.btndele addTarget:self action:@selector(removeAdBlock:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)removeAdBlock:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(clickTabbleViewCell:)]) {
        [self.delegate clickTabbleViewCell:self.btndele.tag];
    }
}

@end


@interface BeatifyAdListView ()<UITableViewDataSource,UITableViewDelegate,ButtonTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *imageSource;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, copy) NSString *md5;
@end
@implementation BeatifyAdListView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        //初始化各种起始属性
        [self initAttribute];
        
        [self initTabelView];
    }
    return self;
}

- (void)initTabelView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-40, self.contentShift) style:UITableViewStylePlain];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ButtonTableViewCell class] forCellReuseIdentifier:@"cell1"];
    
    [self.contentView addSubview:self.tableView];
    
}



/**
 *  初始化起始属性
 */

- (void)initAttribute{
    
    self.buttonH = SCREEN_HEIGHT * (40.0/736.0)+1;
    self.buttonMargin = 10;
    self.contentShift = SCREEN_HEIGHT * (250.0/736.0);
    self.animationTime = 0.8;
    self.backgroundColor = [UIColor colorWithWhite:0.614 alpha:0.700];
    
    [self initSubViews];
}


/**
 *  初始化子控件
 */
- (void)initSubViews{
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.frame = CGRectMake(20,(SCREEN_HEIGHT -self.contentShift)/2, SCREEN_WIDTH-40, self.contentShift);
    [self addSubview:self.contentView];
    
}
/**
 *  展示pop视图
 *
 *  @param array 需要显示button的title数组
 */
- (void)showThePopViewWithArray:(NSMutableArray *)array md5:(NSString*)md5{
     UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [view addSubview:self];
    self.md5 = md5;
    self.dataSource = array;
}

-(void)showTheCheckViewWithArray:(NSMutableArray *)array{
    
    self.imageSource = array;
    
    NSLog(@"%@",self.imageSource);
    
}

- (void)dismissThePopView{
    if ([self.delegate respondsToSelector:@selector(adList_WillRemove:)]) {
        [self.delegate adList_WillRemove:_isReload];
    }
    [self removeFromSuperview];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    [self dismissThePopView];
    
    
}


-(void)clickTabbleViewCell:(NSInteger)row{
    [[BeatifyWebAdManager getInstance] removeAdDom:self.md5 domCss:[self.dataSource[row]objectForKey:WebAdDomCssKey]];
    self.dataSource = [[BeatifyWebAdManager getInstance] getAdDomCssAndTime:self.md5];
    _isReload = true;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    NSString * buttonStr = [self.dataSource[indexPath.row]objectForKey:WebAdDomTimeKey];
    cell.label.text = [NSString stringWithFormat:@"记录%ld %@",indexPath.row+1, buttonStr];
    cell.btndele.tag = indexPath.row;
    cell.delegate = self;
    return cell;
    
    
    
}
#pragma mark - UITableViewDelagate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.buttonH;
}





@end
