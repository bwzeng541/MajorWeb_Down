//
//  PopPromptView.m
//  UrlWebViewForIpad
//
//  Created by Flipped on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopPromptView.h"
#import "SqliteInterface.h"
#import "Record.h"
#import "SHistory.h"
#import "WHConfigures.h"
#import "FileCache.h"
#import "PromptView.h"
#import "AppDelegate.h"
#import "MarjorWebConfig.h"
#import "AddressToolBarTopView.h"
#define CopyUrlTitle @"最近拷贝的网址，点击访问"
#define KEY_WORDS_BLUE RGBCOLOR(73, 152, 253)

#define CGRectSetX(rect,x) rect = CGRectMake(x, rect.origin.y,rect.size.width,rect.size.height)
#define CGRectSetWidth(rect,w) rect = CGRectMake(rect.origin.x, rect.origin.y,w,rect.size.height)
#define CGRectSetHeight(rect,h) rect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width,h)

BOOL WZInterfaceIsPortrait(void) {
    return (NIInterfaceOrientation() == UIInterfaceOrientationPortrait) || (NIInterfaceOrientation() == UIInterfaceOrientationPortraitUpsideDown);
}

BOOL WZInterfaceIsLandscape(void) {
    return (NIInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft) ||
    (NIInterfaceOrientation() == UIInterfaceOrientationLandscapeRight);
}

BOOL WZScreenIsRetina(void) {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))?1:0;
}

@interface PopPromptView()
@property(copy)NSString *showText;
@property(strong)NSMutableArray *hostArrayData;
@end
@implementation PopPromptView{
    NSMutableArray *_websArray;
    PromptView *_hotsView;
    AddressToolBarTopView *_topToolsView;
}



@synthesize myTableView = _myTableView;
@synthesize dataArray = _dataArray;


- (void) shutdown_promptView {
    [_dataArray removeAllObjects];
  _dataArray = nil;
  _myTableView = nil;
    self.hostArrayData = nil;
    _hotsView = nil;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self shutdown_promptView];
}

- (id)initWithFrame:(CGRect)frame tabManager:(id)tabManager {
    self = [super initWithFrame:frame];
    if (self) {
        self.dk_backgroundColorPicker = DKColorPickerWithKey(NEWSBG);
        self.hostArrayData = [[NSMutableArray alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        NSString *path = [[NSBundle mainBundle]pathForResource:@"AppMain.bundle/websites" ofType:@"txt"];
        NSString *dataString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        _websArray = [NSJSONSerialization
                                     JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding]
                                     options:NSJSONReadingAllowFragments
                                     error:nil];

        _hotsView = [[PromptView alloc] initWithFrame:CGRectMake(0, 23, MY_SCREEN_WIDTH, 0)];
        [self addSubview:_hotsView];
        __weak typeof(self) weakSelf = self;
        _hotsView.block = ^(Record *record) {
            [weakSelf clickFromCell:record];
        };
        _topToolsView = [[AddressToolBarTopView alloc] initWithFrame:CGRectMake(0, 0, MY_SCREEN_WIDTH, 25)];
        [self addSubview:_topToolsView];
        _topToolsView.copyWeb = ^{
            [weakSelf copyUrl];
        };
        _topToolsView.editWeb = ^{
            [weakSelf editUrl];
        };
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(280, 23, MY_SCREEN_WIDTH, 220 - 32 - 20) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.rowHeight = 100;
        _myTableView.delaysContentTouches = NO;
        _myTableView.delegate = self;
        _myTableView.dk_separatorColorPicker = DKColorPickerWithKey(ADDRESSTABLECELLLINE);
        _myTableView.dk_backgroundColorPicker = DKColorPickerWithKey(NEWSBG);
        [self addSubview:_myTableView];
        if (IF_IPAD) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKGFrame:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        }
      if (IF_IPHONE) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePromptView) name:@"NOTIFICATION_Recommend_CLICK" object:nil];
      }
        [self hide];
    }
    return self;
}

-(void)copyUrl{
    if ([self.delegate respondsToSelector:@selector(promptCopyUrl)]) {
        [self.delegate promptCopyUrl];
    }
}

-(void)editUrl{
    if ([self.delegate respondsToSelector:@selector(promptEditUrl)]) {
        [self.delegate promptEditUrl];
    }
}


-(void)changeKGFrame:(id)sender{
    if (self.alpha) {
         [self layoutSubviews];
    }
}
- (void)changeAutoFrame:(float)height
{
    self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, [[UIScreen mainScreen]bounds].size.height - 20 - 44 - height);
    //[self rearrangeViews];
}

- (void)updateTableAndHostFrame{
    if (self.hostArrayData.count==0) {
        [self.hostArrayData addObjectsFromArray:[[MarjorWebConfig getInstance] getSearchHotsArray]];
    }
   NSInteger h = [_hotsView updateHotsArray:self.hostArrayData];
    if (h<3) {
        _hotsView.frame = CGRectMake(0, 0, MY_SCREEN_WIDTH, h);
    }
    else{
        _hotsView.frame = CGRectMake(0, 5, MY_SCREEN_WIDTH, h);
    }
    [self bringSubviewToFront:_hotsView];
}

- (void)layoutSubviews
{
    if(WZInterfaceIsLandscape()){
        CGRectSetHeight(self.myTableView.frame, 170);
    }else{
        CGRectSetHeight(self.myTableView.frame, self.frame.size.height);
    }

        CGRectSetWidth(self.myTableView.frame, MY_SCREEN_WIDTH);
        CGRectSetHeight(self.myTableView.frame, self.frame.size.height);
        
        CGRectSetWidth(self.frame, MY_SCREEN_WIDTH);
        CGRectSetHeight(self.frame, MY_SCREEN_HEIGHT);
    if (_hotsView.frame.size.height<2) {
        _topToolsView.hidden = NO;
           self.myTableView.frame = CGRectMake(0, _topToolsView.frame.origin.y+ _topToolsView.frame.size.height, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(_topToolsView.frame.origin.y+ _topToolsView.frame.size.height)-(GetAppDelegate.appStatusBarH)-50);
        }
    else{
        _topToolsView.hidden = YES;
         self.myTableView.frame = CGRectMake(0, _hotsView.frame.origin.y+ _hotsView.frame.size.height+5, MY_SCREEN_WIDTH, MY_SCREEN_HEIGHT-(_hotsView.frame.origin.y+ _hotsView.frame.size.height+5)-(GetAppDelegate.appStatusBarH)-50);
    }
}

- (void)show {
  _myTableView.alpha = 1;
}

- (void)hide{
  
  _myTableView.alpha = 0;
}

-(void)clickFromCell:(Record*)record{
    NSString *urlString = [record titleUrl];
    //地址加入百度索引
    if (!urlString.length) {
        NSString *hot = [record titleName];
        NSString *keywords = [hot
                              stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlStr = [WHConfigures baiduSearchLink:keywords];
        [self hidePromptView];
        [[MarjorWebConfig getInstance] addSearchHots:hot];
        [self.delegate promptClickUrl:urlStr];
        return;
    }
    NSString *typeUrl = [record typeStr];
    if (typeUrl.length) {
        urlString = typeUrl;
    }
    //回调出去
    //
    [self hidePromptView];
    [self.delegate promptClickUrl:urlString];
}

#pragma mark - tableview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(promptStartDragg)]) {
        [self.delegate promptStartDragg];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    
    NSInteger row = indexPath.row;
    cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(NEWSTITLE);
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    NSString *titleName = [[self.dataArray objectAtIndex:row] titleName];
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:titleName];
    NSRange per = [titleName rangeOfString:self.showText];
    UIColor *color = KEY_WORDS_BLUE;
    BOOL isCopy = false;
    if ([titleName compare:CopyUrlTitle]==NSOrderedSame){
        color = RGBCOLOR(0, 162, 255);
        isCopy = true;
    }
    [titleText addAttribute:NSForegroundColorAttributeName value:color range:per];

    NSRange range1 = [titleName rangeOfString:@"《"];
    NSRange range2 = [titleName rangeOfString:@"》"];
    if (range1.location!=NSNotFound && range2.location!=NSNotFound && range2.location>range1.location) {
        [titleText addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(0, 0, 255) range:NSMakeRange(range1.location, range2.location-range1.location)];
    }
    if (isCopy) {
        cell.textLabel.textColor = color;
    }
    cell.textLabel.attributedText = titleText;
    if(!isCopy)
    cell.detailTextLabel.dk_textColorPicker = DKColorPickerWithKey(NEWSSUBTITLE);
    else cell.detailTextLabel.textColor = color;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    NSString *titleUrl = [[self.dataArray objectAtIndex:row] titleUrl];
    NSMutableAttributedString *titleR = [[NSMutableAttributedString alloc] initWithString:titleUrl];
    NSRange perUrl = [titleUrl rangeOfString:self.showText];
    [titleR addAttributes:@{NSForegroundColorAttributeName:color} range:perUrl];
    cell.detailTextLabel.attributedText = titleR;
    
    cell.imageView.image = [UIImage imageNamed:[[self.dataArray objectAtIndex:row] iconStr]];
    cell.dk_backgroundColorPicker = DKColorPickerWithKey(NEWSBG);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self clickFromCell:[self.dataArray objectAtIndex:indexPath.row]];
}

-(void)hidePromptView
{
  [self.delegate promptViewWillDissmiss:self isChangeAddressTool:YES];
  [self hide];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 50.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] init];
//  bgView.backgroundColor = RGBCOLOR(242, 242, 242);
    bgView.dk_backgroundColorPicker = DKColorPickerWithKey(NEWSBG);
  
    UIButton *delBtn = [[UIButton alloc] init];
    [delBtn setBackgroundImage:[UIImage imageNamed:@"Brower.bundle/ljt"] forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delHistory) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:delBtn];
    
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bgView.mas_right).with.offset(-10);
        make.centerY.equalTo(bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.text = @"历史记录";
    titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:20*AppScaleIphoneH];
    titleLab.textAlignment = NSTextAlignmentLeft;
    //      titleLab.textColor = RGBCOLOR(175, 175, 175);
    titleLab.dk_textColorPicker = DKColorPickerWithKey(NEWSTITLE);
    [bgView addSubview:titleLab];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView.mas_left).with.offset(10);
        make.centerY.equalTo(bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
  
  return bgView;
}

-(void)delHistory
{
    __weak __typeof(self)weakSelf = self;
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"是否删除?" message:nil];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                                   
                                               }];
    [alertView addAction:v];
    v  = [TYAlertAction actionWithTitle:@"删除"
                                  style:TYAlertActionStyleDefault
                                handler:^(TYAlertAction *action) {
                                    [FileCache deleteAllDBDataByTbName:KEY_DATENAME TableName:KEY_TABLE_HISRECORD];
                                    [weakSelf getDataArray:@"" Cate:NO];
                                    GetAppDelegate.isHistoryUpdate = !GetAppDelegate.isHistoryUpdate;
                                }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.alpha = 0;
    [self.delegate promptViewWillDissmiss:self isChangeAddressTool:NO];
  
}

- (void)getDataArray:(NSString *)str Cate:(BOOL)sender {
  self.isHideRecommend = str.length == 0 ? NO : YES;
    self.showText = !str?@"":str;
    if (sender) {
        [self.dataArray removeAllObjects];
        [self.hostArrayData removeAllObjects];
        [[SqliteInterface sharedSqliteInterface] setupDB:KEY_DATENAME];
        [[SqliteInterface sharedSqliteInterface] connectDB];
        FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;
        
        NSString *preHandle = str;
        
        NSMutableString *mutableString = [NSMutableString string];
        
        //处理中文输入法时候的特殊字符
        for(int i = 0;i < preHandle.length;i++){
            
            if([preHandle characterAtIndex:i] != 0x2006){
                
                [mutableString appendFormat:@"%c",[preHandle characterAtIndex:i]];
                
            }
            
        }
       
        NSString *urlString = mutableString;
            //NSLog(@"urlString %@",urlString);
        if(urlString.length > 3){
                //NSLog(@"search %X",[urlString characterAtIndex:3]);
        }
        int topCount = 2;//查询多少条纪录
        if (urlString == nil) {
            urlString = @"";
        }
        if (!urlString.length) {
            topCount = 10;
        }
//        if ([GVUserDefaults standardUserDefaults].isCleanMode) {
//            topCount = 0;
//        }
        topCount = 100;
        NSPredicate *pred;
        NSArray *contacts = [_websArray copy];
        pred = [NSPredicate predicateWithFormat:@"title contains[cd] %@ OR displayUrl contains[cd] %@ ", urlString, urlString];
        contacts = [contacts filteredArrayUsingPredicate:pred];
        
        //前2条是推荐网址
        int webIdx = 0;
        for (NSDictionary *dict in contacts) {
            if (webIdx>=2) {
                break;
            }
            Record *record = [[Record alloc] init];
            record.titleName = dict[@"title"];
            record.iconStr = @"dzltb1.png";
            record.titleUrl= dict[@"displayUrl"];
            record.typeStr = dict[@"maskedUrl"];
            [self.dataArray addObject:record];
            webIdx++;
        }

        topCount += webIdx;
        
            //NSLog(@"urlString %@ urlString",urlString);
        NSString *strSql = [NSString stringWithFormat:@"%@%@%@%@%@", @"SELECT * FROM ", KEY_TABLE_HISRECORD, @" WHERE TitleUrl like '%", urlString, [NSString stringWithFormat:@"%%' order by dateStr desc limit 0,%i ",topCount]];
        FMResultSet *rs = [dbo executeQuery:strSql, strSql];
            //NSLog(@"%@  cccccccc",strSql);
        while ([rs next]) {
            Record *record = [[Record alloc] init];
            record.titleName = [rs stringForColumn:@"titleName"];
            record.iconStr = @"dzltb2.png";//[rs stringForColumn:@"iconStr"];
            record.titleUrl = [rs stringForColumn:@"titleUrl"];
            record.typeStr  = record.titleUrl;

            if ([self.dataArray count] < topCount) {
                [self.dataArray addObject:record];
            } else {
                break;
            }
        }
        [rs close];
        [[SqliteInterface sharedSqliteInterface] closeDB];
        
        if (sender) {
            [self baiduSuggestion:str];
        }
        [self insertPasteboard];
        [self.myTableView reloadData];
    } else {
        [self.dataArray removeAllObjects];
        [self.hostArrayData removeAllObjects];
        [[SqliteInterface sharedSqliteInterface] setupDB:@"MAIN.sqlite"];
        [[SqliteInterface sharedSqliteInterface] connectDB];
        FMDatabase *dbo = [SqliteInterface sharedSqliteInterface].dbo;//select *  from student where detail  like ‘%学生%’
        NSString *strSql = [NSString stringWithFormat:@"%@", @"SELECT * FROM sHistory group by(sdate) order by sdate desc"];
        FMResultSet *rs = [dbo executeQuery:strSql, strSql];
        while ([rs next]) {
            SHistory *record = [[SHistory alloc] init];
            record.sName = [rs stringForColumn:@"sName"];
            record.sDate = [rs stringForColumn:@"sdate"];
            if ([self.dataArray count] < 10) {
                [self.dataArray addObject:record];
            }
        }
        [rs close];
        [[SqliteInterface sharedSqliteInterface] closeDB];
        [self insertPasteboard];
        [self.myTableView reloadData];
    }
}

-(void)insertPasteboard{
    __weak typeof(self) weakSelf = self;
    NSString *copyUrl = [UIPasteboard generalPasteboard].string;
    if (!copyUrl) {
        return;
    }
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:copyUrl options:NSMatchingReportProgress range:NSMakeRange(0, copyUrl.length)];
    if(arrayOfAllMatches.count>0)
    {
        copyUrl = [copyUrl substringWithRange:((NSTextCheckingResult*)[arrayOfAllMatches firstObject]).range];
    [MarjorWebConfig isUrlValid:copyUrl callBack:^(BOOL validValue, NSString *result) {
        if (validValue) {
            Record *record = [[Record alloc] init];
            record.titleName = CopyUrlTitle;
            record.iconStr = @"dzltb2.png";//[rs stringForColumn:@"iconStr"];
            record.titleUrl = result;
            record.typeStr  =result;
            if (weakSelf.dataArray.count>0) {
                [weakSelf.dataArray insertObject:record atIndex:0];
            }
            else{
            [weakSelf.dataArray addObject:record];
            }
        }
    }];
    }
}

- (void)baiduSuggestion:(NSString *)keywords {
    __weak typeof(self) weakSelf = self;
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       @autoreleasepool {
                           NSString *urlString = [NSString
                                                  stringWithFormat:@"http://suggestion.baidu.com/"
                                                  @"su?wd=%@&p=3&cb=window.bdsug.su",
                                                  [keywords
                                                   stringByAddingPercentEscapesUsingEncoding:
                                                   NSUTF8StringEncoding]];
                           NSError *error = NULL;
                           NSURL *url = [NSURL URLWithString:urlString];
                           NSData *data =
                           [[NSData alloc] initWithContentsOfURL:url
                                                         options:NSDataReadingMappedIfSafe
                                                           error:&error];
                           if (error) {
                               //如果读取失败，应该将之前的搜索记录也清除掉
                               //[self.dataArray removeAllObjects];
                           } else {
                               NSStringEncoding gbkEncoding =
                               CFStringConvertEncodingToNSStringEncoding(
                                                                         kCFStringEncodingGB_18030_2000);
                               NSString *jsonString =
                               [[NSString alloc] initWithData:data
                                                     encoding:gbkEncoding];
                               if (jsonString.length > 0) {
                                   error = nil;
                                   NSString *urlRegex = @"s:\\[\"(.*)\"\\]";
                                   NSRegularExpression *regex = [NSRegularExpression
                                                                 regularExpressionWithPattern:
                                                                 urlRegex options:NSRegularExpressionCaseInsensitive
                                                                 error:&error];
                                   NSTextCheckingResult *match = [regex
                                                                  firstMatchInString:jsonString
                                                                  options:NSMatchingReportProgress
                                                                  range:NSMakeRange(0, [jsonString length])];
                                   if (weakSelf.dataArray) {
                                       //[weakSelf.dataArray removeAllObjects];
                                   }
                                   if (match) {
                                       NSRange firstRange = [match rangeAtIndex:1];
                                       NSString *matchedString =
                                       [jsonString substringWithRange:firstRange];
                                       NSArray *arr_hot = [matchedString componentsSeparatedByString:@"\",\""];
                                       [weakSelf.hostArrayData removeAllObjects];
                                       for (NSString *str in arr_hot) {
                                           Record *record = [[Record alloc] init];
                                           record.titleName = str;
                                           record.iconStr = @"dzltb3.png";
                                           record.titleUrl= @"";
                                           record.typeStr = @"";
                                           [weakSelf.hostArrayData addObject:record];
                                       }
                                       //NIDPRINT(@"keyword %@ matchedString = %@",keywords,matchedString);
                                   }
                               }
                           }
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self updateTableAndHostFrame];
                           });
                       }
                   });
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
 // [self.delegate promptViewBecomeFirstResponder];
}

- (void)rearrangeViews {
  
    [self setNeedsLayout];
}


@end
