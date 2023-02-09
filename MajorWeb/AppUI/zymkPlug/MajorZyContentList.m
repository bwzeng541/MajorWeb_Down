//
//  MajorZyContentList.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/1/10.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MajorZyContentList.h"
#import "MajorZyPlug.h"
#import "AppDelegate.h"
@interface MajorZyContentList()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UIButton *closeBtn;
@property(strong,nonatomic)UIButton *editBtn;
@property(strong,nonatomic)UILabel *desLabel;
@property(strong,nonatomic)UITableView *myTableView;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(copy,nonatomic)void(^closeBlock)(void);
@property(copy,nonatomic)void(^selectSortBlock)(NSString*sortUrl);
@property(copy,nonatomic)void(^selectBlock)(NSArray*array ,NSString*showName,NSString*historUrl);
@end

@implementation MajorZyContentList

-(instancetype)initWithFrame:(CGRect)frame array:(NSArray*)array selectBlock:(void(^)(NSString*sortUrl))selectBlock closeBlcok:(void(^)(void))closeBlock{
    self = [super initWithFrame:frame];
    self.closeBlock = closeBlock;
    self.selectSortBlock = selectBlock;
    self.dataArray = [NSMutableArray arrayWithArray:array];
    [self initUI];
    RemoveViewAndSetNil(self.editBtn);
    self.desLabel.text = @"分类";
    return self;
}

-(void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    UIView *topW = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, GetAppDelegate.appStatusBarH)];
    self.isUsePopGesture = true;
    [self addSubview:topW];
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn addTarget:self action:@selector(closeZyList) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self.closeBtn setFrame:CGRectMake(5, GetAppDelegate.appStatusBarH, 55, 35)];
    [self addSubview:self.closeBtn];
    
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editBtn addTarget:self action:@selector(editEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:RGBCOLOR(0, 0, 0) forState:UIControlStateNormal];
    [self.editBtn setFrame:CGRectMake(MY_SCREEN_WIDTH-60, GetAppDelegate.appStatusBarH, 55, 35)];
    [self addSubview:self.editBtn];
    
    self.desLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, 30)];
    [self insertSubview:self.desLabel belowSubview:self.closeBtn];
    self.desLabel.center = CGPointMake(self.desLabel.center.x, self.closeBtn.center.y);
    self.desLabel.textAlignment = NSTextAlignmentCenter;
    
    float startY = self.closeBtn.frame.origin.y+self.closeBtn.frame.size.height;
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,startY , MY_SCREEN_WIDTH,MY_SCREEN_HEIGHT-startY-(GetAppDelegate.appStatusBarH-20) ) style:UITableViewStylePlain];
    _myTableView.dataSource = self;
    _myTableView.rowHeight = 45;
    _myTableView.delaysContentTouches = NO;
    _myTableView.delegate = self;
    [self addSubview:_myTableView];
}

-(instancetype)initWithFrame:(CGRect)frame typeDes:(NSString*)typeDes selectBlock:(void(^)(NSArray*array ,NSString*showName,NSString*historUrl))selectBlock closeBlcok:(void(^)(void))closeBlock{
    self = [super initWithFrame:frame];
    self.closeBlock = closeBlock;
    self.selectBlock = selectBlock;
    [self initUI];
    self.desLabel.text = typeDes;
    if ([typeDes containsString:@"收藏"]) {
       self.dataArray = [NSMutableArray arrayWithArray:getCartoonFavouriteKey()]  ;
    }
    if ([typeDes containsString:@"历史"]) {
        RemoveViewAndSetNil(self.editBtn);
        self.dataArray = [NSMutableArray arrayWithArray:getAllCartKey()]  ;
    }
    return self;
}

-(void)editEvent:(UIButton*)sender{
    [self.myTableView setEditing:!self.myTableView.editing];
}

-(void)removeFromSuperview{
    if (self.closeBlock) {
        self.closeBlock();
    }
    [super removeFromSuperview];
}

- (BOOL)isValidGesture:(CGPoint)point{
    if (point.x<self.bounds.size.width/2) {
        return true;
    }
    return false;
}

-(void)closeZyList{
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ApplicationListCell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (self.selectSortBlock) {
        cell.textLabel.text = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    }
    else{
        NSDictionary *info = [self.dataArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [info objectForKey:@"dataSource"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = getCartName([info objectForKey:@"key"]);
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.editBtn) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *ifno = [self.dataArray objectAtIndex:indexPath.row];
    NSString *key = [ifno objectForKey:@"key"];
    delCartoonFavouriteKey(key);
    [self.dataArray removeObjectAtIndex:indexPath.row];
    // 删除某一行 cell
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectSortBlock){
        self.closeBlock = nil;
        self.selectSortBlock([[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"url"]);
        [self removeFromSuperview];
    }
    else if (self.selectBlock) {
        NSDictionary *ifno = [self.dataArray objectAtIndex:indexPath.row];
        NSString *key = [ifno objectForKey:@"key"];
        NSArray *array = getCartList(key);
        NSString *name = getCartName(key);
        NSString *url = getCartoonHistory(key);
        if (!url) {
            [[UIApplication sharedApplication].keyWindow makeToast:@"此记录无法打开"];
            return;
        }
        self.closeBlock = nil;
        self.selectBlock(array, name, url);
        [self removeFromSuperview];
    }
}

@end
