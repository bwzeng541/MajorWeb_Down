//
//  UcTableViewCell.m
//  WatchApp
//
//  Created by zengbiwang on 2018/4/27.
//  Copyright © 2018年 cxh. All rights reserved.
//
#if DoNotKMPLayerCanShareVideo
#else
#import "UcTableViewCell.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "AppDelegate.h"
#import "FileDonwPlus.h"
#import "M3u8ArEngine.h"
#import "AloneStateEngine.h"
#import "VipPayPlus.h"
#import "TmpSetView.h"
#import "MajorSystemConfig.h"
#import "MarjorWebConfig.h"
#import "FTWCache.h"
#import "VideoPlayerManager.h"
#import "TYAlertView.h"
#import "UIView+TYAlertView.h"
typedef enum UcTableviewClickType{
    Uc_Click_CpoyVdieo,
    Uc_Click_CpoyHtml,
    Uc_Click_OpenHtml,
    Uc_Click_ChangeVideoName,
}_UcTableviewClickType;

@interface UcTableViewCell()
@property(assign)NSInteger state;
@property(copy)NSString *name;
@property(copy)NSString *uuid;
@property(strong)IBOutlet UILabel *nameLabel;
@property(strong)IBOutlet UILabel *watchLabel;
@property(strong)IBOutlet UILabel *progressLabel;
@property(strong)IBOutlet UILabel *speedLabel;
@property(strong)IBOutlet UILabel *fileSizeLabel;
@property(strong)IBOutlet UIButton *btn;
@property(strong)IBOutlet UIButton *saveBtn;
@property(strong)IBOutlet UILabel *playLabel;
@property(strong)IBOutlet UIView *toolsView;

@property(strong)IBOutlet UIButton *reDownBtn;
@property(strong)IBOutlet UIButton *delBtn;
@property(strong)IBOutlet UIButton *jionDirBtn;
@property(strong)IBOutlet UIButton *openhtmlBtn;
@property(strong)IBOutlet UIButton *cpoyHtmlBtn;
@property(assign)_UcTableviewClickType ClickType;
@property(copy)NSString *videoName;
@property(copy)NSData *videoUrl;
@property(copy)NSString *curretBtnTitle;
@property(strong)NSDictionary *cellInfo;
@property(assign)BOOL isEdit;
@property(copy)NSString *oldTitle;
@property (nonatomic, strong) dispatch_block_t afterBlock;
@end
@implementation UcTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)removeFromSuperview
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.clickBlock = nil;self.playBlock= nil;self.playValueBlock=nil;self.saveBlock = nil;
    [self resertui];
    [super removeFromSuperview];
}

- (void)cancelBlock {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}

-(void)resertui{
    [self cancelBlock];
    self.playLabel.hidden = YES;
    self.speedLabel.text= @"";
    self.speedLabel.textColor = RGBCOLOR(255, 0, 0);
    self.nameLabel.textColor = RGBCOLOR(159,159,159);
    self.fileSizeLabel.text = @"";
    self.progressLabel.text = @"";
    [self updateNameLabel:NO];
}

-(void)updateNameLabel:(BOOL)isWatch{
    self.nameLabel.textColor = RGBCOLOR(0,0,0);
    self.nameLabel.text = self.videoName;
    if (!isWatch) {
        self.watchLabel.hidden = YES;
    }
    else{
        self.watchLabel.textColor = RGBCOLOR(7,153,255);
        // NSNumber *number = (NSNumber*)[playInfo objectForKey:@"playTime"];
//        if (number) {
//            return [number floatValue];
//        }
        self.watchLabel.hidden = NO;
        NSDictionary *info = [[RecordUrlToUUID getInstance]playTimeFromKey:self.uuid];
        NSNumber *number1 = [info objectForKey:@"playTime"];
        NSNumber *number2 = [info objectForKey:@"duration"];
        if ([number1 longValue]>0 && [number2 floatValue]>0) {
            float time = [number1 floatValue]/[number2 floatValue];
            self.watchLabel.text = [NSString stringWithFormat:@"已观看%0.2f%%",time *100];
        }
    }
}

-(void)initCellInfo:(NSDictionary*)info 
{
    if(!info){
        NSLog(@"errpr initCellInfo");
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
     [self resertui];
    self.cellInfo = info;
    NSString *uuidKey = StateUUIDKEY;
    if ([info isKindOfClass:NSClassFromString(@"GuanliNSDictionary")]) {
        uuidKey = GuanliNodeKey;
        [self pareName:GuanliNameKey uuid:uuidKey];
    }
    else{
        if ([info objectForKey:ALONE_FILE_URL]) {
            [self pareName:ALONE_VIDEO_SHOW_NAME uuid:uuidKey ];
            self.videoUrl = [[info objectForKey:ALONE_FILE_URL] copy];
        }
        else{
            [self pareName:M3U8_VIDEO_FILE_NAME uuid:uuidKey];
            self.videoUrl = [[info objectForKey:M3U8_FILE_URL] copy];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBtnTitie:) name:UcBtnTitleChangeNotifi object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:[info objectForKey:uuidKey] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpeed:) name:[NSString stringWithFormat:@"SpeedTaskNotifi_%@",self.uuid] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webGetVideoFaild:) name:[NSString stringWithFormat:@"webGetVideFaild_%@",self.uuid] object:nil];
    
    info = [NSDictionary dictionaryWithObjectsAndKeys:@"AppNewStateManager",@"param1",@"getInstance",@"param2",@"getValueFaild:",@"param3",@[self.uuid],@"param4", nil];
    NSString *retValue = [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    if ([retValue length]<=1) {
        info = [NSDictionary dictionaryWithObjectsAndKeys:@"AppNewStateManager",@"param1",@"getInstance",@"param2",@"getDownProgress:",@"param3",@[self.uuid],@"param4", nil];
        self.progressLabel.text = [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    }
    else{
        self.progressLabel.text = retValue;
    }
    if ([self.progressLabel.text length]>4) {
        self.progressLabel.textColor = RGBCOLOR(255, 0, 0);
    }
    @weakify(self)
    
    [RACObserve(self.btn.titleLabel,text) subscribeNext:^(id x) {
        @strongify(self)
        [self updateSaveBtn];
    }];
}

-(void)updateSaveBtn{
    if ([self.btn.titleLabel.text compare:@"播放"]==NSOrderedSame) {
        self.saveBtn.hidden = NO;
    }
    else{
        self.saveBtn.hidden = YES;
    }
}

-(void)webGetVideoFaild:(NSNotification*)object{
    [self updateFix:false];
}

-(void)updateSpeed:(NSNotification*)object{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.speedLabel.text = [NSString stringWithFormat:@"%@/s",object.object];
    });
}

-(void)updateBtnEdit:(BOOL)flag{
    if (self.playValueBlock && self.playValueBlock(self.uuid)) {
        self.playLabel.hidden = NO;
        [self updateNameLabel:YES];
        //修改namelabelt字和颜色
    }
    else{
        self.playLabel.hidden = YES;
        [self updateNameLabel:NO];
    }
    if (flag) {
        self.curretBtnTitle = @"删除";
         [self.btn setTitle:self.curretBtnTitle forState:UIControlStateNormal];
    }
    else{
         self.curretBtnTitle = self.oldTitle;
        [self.btn setTitle:self.oldTitle forState:UIControlStateNormal];
    }
    self.isEdit = flag;
    [self updateBtnColor];
}

-(void)updateBtnColor{
    NSString *ss = self.curretBtnTitle;
    self.textLabel.font = [UIFont systemFontOfSize:15];
    if ([ss compare:@"删除"]==NSOrderedSame) {
        [self.btn setTitleColor:RGBCOLOR(255, 0, 0) forState:UIControlStateNormal];
    }
    else if ([ss compare:@"暂停"]==NSOrderedSame) {
        [self.btn setTitleColor:RGBCOLOR(132, 0, 255) forState:UIControlStateNormal];
    }
    else if ([ss compare:@"播放"]==NSOrderedSame) {
        self.textLabel.font = [UIFont systemFontOfSize:20];
        [self.btn setTitleColor:RGBCOLOR(255, 144, 0) forState:UIControlStateNormal];
    }
    else if ([ss compare:@"开始"]==NSOrderedSame) {
        [self.btn setTitleColor:RGBCOLOR(52, 120, 246) forState:UIControlStateNormal];
    }
}

-(void)updateBtnTitie:(NSNotification*)object{
    [self updateBtnEdit:[object.object boolValue]];
}

-(void)pareName:(NSString*)nameKey uuid:(NSString*)uuidKey {
    self.uuid = [self.cellInfo objectForKey:uuidKey];
    if(!self.uuid){
        NSLog(@"uuid initCellInfo");
    }
    NSString *name =  [[RecordUrlToUUID getInstance] titleFromKey:self.uuid];
    self.videoName = name?name:[self.cellInfo objectForKey:nameKey];
    self.nameLabel.text = self.videoName;
    if ([self getUUIDStateNewUc]) {
        self.progressLabel.text = @"已下载";
    }
    if ([NSThread isMainThread]) {
        [self updateBtnState];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateBtnState];
        });
    }
}


-(void)updatePlayState:(NSString*)str{
    self.state = 0;
    self.oldTitle = @"播放";
    self.progressLabel.text = self.speedLabel.text = @"";
    self.curretBtnTitle = self.oldTitle;
    [self.btn setTitle:self.oldTitle forState:UIControlStateNormal];
    self.nameLabel.textColor = [UIColor blackColor];
    [self updateStateNew:str];
}


-(void)updateBtnState
{
    NSNumber *ret = [NSNumber numberWithBool:false];
    self.speedLabel.text= @"";
    NSString *str = [self getUUIDStateNewUc];
    if (str) {
        ret = [NSNumber numberWithBool:true];
        [self updatePlayState:str];
        [self updateBtnColor];
        return;
    }
    else {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf5];
        [info setObject:@[self.uuid] forKey:@"param4"];
        if ([self.cellInfo isKindOfClass:NSClassFromString(@"GuanliNSDictionary")]) {
            info  =  [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf16];
            [info setObject:@[self.uuid] forKey:@"param4"];
        }
        ret = [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    }//ret = 0只是表示是否在下载队里里面，需要判断是否在下载状态，才是
    [self updateFix:[ret boolValue]];
}

-(void)updateFix:(BOOL)ret{
    if (ret) {
        self.state = 2;
        self.oldTitle = @"暂停";
        self.curretBtnTitle = self.oldTitle;
        [self.btn setTitle:self.oldTitle forState:UIControlStateNormal];
    }
    else{
        self.state = 3;
        self.oldTitle = @"开始";
        self.curretBtnTitle = self.oldTitle;
        [self.btn setTitle:self.oldTitle forState:UIControlStateNormal];
    }
    self.fileSizeLabel.text = @"";
    [self updateBtnColor];
}

-(void)updateStateNew:(NSString*)filePath{
    [self cancelBlock];
    if ([filePath rangeOfString:[NSString stringWithFormat:@"/%@%@",@"Web/vi",@"deopath"]].location != NSNotFound) {
        filePath = [filePath stringByDeletingPathExtension];
        __weak typeof(self) weakSelf = self;
        self.afterBlock = dispatch_block_create(0, ^{
            float vv = [weakSelf folderSizeAtPath:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.fileSizeLabel.text = [NSString stringWithFormat:@"%0.2fMB",vv];
            });
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            if (weakSelf.afterBlock) {
                weakSelf.afterBlock();
            }
        });
    }
    else{
        float vv = [self fileSizeAtPath:filePath]/(1024*1024.0);
        self.fileSizeLabel.text = [NSString stringWithFormat:@"%0.2fMB",vv];
    }
    [self updateBtnColor];
}

- (float )folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        
    }
    return folderSize/(1024.0*1024.0);
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(void)tryPlay{
    if (self.state==0) {
        [self pressBtnEvent:nil];
    }
}

-(void)changeName{
    NSString *title = [[RecordUrlToUUID getInstance] titleFromKey:self.uuid];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"重命名" message:title preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = title;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        NSString *text = envirnmentNameTextField.text;
        if (text.length>1) {
            NSString *url = [[RecordUrlToUUID getInstance] urlFromKey:wself.uuid];
            [[RecordUrlToUUID getInstance] addUrl:url uuid:wself.uuid title:text];
            [wself initCellInfo:wself.cellInfo];
        }
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:true completion:nil];
}

-(IBAction)changeVideoName:(id)sender{
    if (true || [VipPayPlus getInstance].systemConfig.vip!=General_User) {
        [self changeName];
    }
    else{
        self.ClickType = Uc_Click_ChangeVideoName;
        [self showFuctionInfo];
    }
}


-(IBAction)reDownEvent:(id)sender{
   NSString *url = [[RecordUrlToUUID getInstance] urlFromKey:self.uuid];
   NSString *title = [[RecordUrlToUUID getInstance] titleFromKey:self.uuid];
    if(self.reDownBlock && url && title){
        self.reDownBlock(url, title, self.uuid);
    }
    else{
        [[[UIApplication sharedApplication] keyWindow] makeToast:@"无法查找视频,请删除重新下载" duration:2 position:@"center"];
    }
}

-(void)cpoyVideoFuction{
    NSString *videoUrl = [FTWCache decryptWithKey:self.videoUrl];
    UIPasteboard *appPasteBoard =  [UIPasteboard generalPasteboard];
    appPasteBoard.persistent = YES;
    NSString *pasteStr =videoUrl;
    [appPasteBoard setString:pasteStr];
    [[[UIApplication sharedApplication] keyWindow] makeToast:@"复制视频地址成功" duration:2 position:@"center"];
}

-(IBAction)jionVideoDir:(id)sender{
    if (self.jionDirBlock) {
        if (!self.saveBtn.hidden) {
            self.jionDirBlock(self.uuid);
        }
        else{
            [[[UIApplication sharedApplication] keyWindow] makeToast:@"下载完成后才能加入" duration:2 position:@"center"];
        }
    }
}

-(IBAction)copyVideoUrl:(id)sender{
    NSString *videoUrl = [FTWCache decryptWithKey:self.videoUrl];
    if (videoUrl) {
        if (true || [VipPayPlus getInstance].systemConfig.vip!=General_User) {
            [self cpoyVideoFuction];
        }
        else{
            self.ClickType = Uc_Click_CpoyVdieo;
                [self showFuctionInfo];
            
        }
    }
    else{
        [[[UIApplication sharedApplication] keyWindow] makeToast:@"暂时无法获取" duration:2 position:@"center"];
    }
}

-(void)cpoyhtmlFuction{
    NSString *htmlUrl = [[RecordUrlToUUID getInstance] urlFromKey:self.uuid];
    UIPasteboard *appPasteBoard =  [UIPasteboard generalPasteboard];
    appPasteBoard.persistent = YES;
    NSString *pasteStr =htmlUrl;
    [appPasteBoard setString:pasteStr];
    [[[UIApplication sharedApplication] keyWindow] makeToast:@"复制网页地址成功" duration:2 position:@"center"];
}

-(IBAction)copyhtmlUrl:(id)sender{
    /*
   NSString *htmlUrl = [[RecordUrlToUUID getInstance] urlFromKey:self.uuid];
    if(htmlUrl){
        if (true || [VipPayPlus getInstance].systemConfig.vip!=General_User) {
            [self cpoyhtmlFuction];
        }
        else{
            self.ClickType = Uc_Click_CpoyHtml;
            [self showFuctionInfo];
        }
    }
    else{
        [[[UIApplication sharedApplication] keyWindow] makeToast:@"暂时无法获取" duration:2 position:@"center"];
    }*/
    [self showDelAlter];
}

-(void)openhtmlFuction{
    NSString *htmlUrl = [[RecordUrlToUUID getInstance] urlFromKey:self.uuid];
    if(htmlUrl){
        [[[UIApplication sharedApplication] keyWindow] makeToast:@"打开网页地址成功" duration:2 position:@"center"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenUrlFromCacheCell" object:htmlUrl];
    }
}

-(IBAction)openhtmlUrl:(id)sender{
    NSString *htmlUrl = [[RecordUrlToUUID getInstance] urlFromKey:self.uuid];
    if(htmlUrl){
        if (true || [VipPayPlus getInstance].systemConfig.vip!=General_User) {
            [self openhtmlFuction];
        }
        else{
            self.ClickType = Uc_Click_OpenHtml;
            [self showFuctionInfo];
        }
    }
    else{
        [[[UIApplication sharedApplication] keyWindow] makeToast:@"暂时无法获取" duration:2 position:@"center"];
    }
}

-(IBAction)delSelf:(id)sender{
    [self showDelAlter];
}

-(void)showDelAlter{
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
                                    if(weakSelf.delValueBlock){
                                        weakSelf.delValueBlock(weakSelf.uuid);
                                    };
                                }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}


//保存
-(IBAction)pressSaveEvent:(id)sender{
    self.saveBlock([self getUUIDStateNewUc],self.nameLabel.text,self.uuid);
}

-(IBAction)pressBtnEvent:(id)sender{
    if(self.getEditBlock && self.getEditBlock()){
        __weak __typeof(self)weakSelf = self;
        TYAlertView *alertView = [TYAlertView alertViewWithTitle:[NSString stringWithFormat:@"删除:%@?",self.videoName] message:nil];
        [alertView setButtonFont:[UIFont systemFontOfSize:14]];
        TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                       
                                                   }];
        [alertView addAction:v];
        TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"删除"
                                                      style:TYAlertActionStyleDefault
                                                    handler:^(TYAlertAction *action) {
                                                    weakSelf.clickBlock(weakSelf.state,weakSelf.uuid);
                                                    }];
        [alertView addAction:v1];
        [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
        return;
    }
    if (self.clickBlock && !self.clickBlock(self.state,self.uuid)) {
        if (self.state==0) {
            self.playBlock([self getUUIDStateNewUc],self.videoName,self.uuid);
            if (self.playValueBlock && self.playValueBlock(self.uuid)) {
                self.playLabel.hidden = NO;
                //修改namelabelt字和颜色
                [self updateNameLabel:YES];
            }
            else{
                self.playLabel.hidden = YES;
                [self updateNameLabel:NO];
            }
            [self updateBtnColor];
            return;
        }
        if (self.state==2) {
            if(true)//CanDownMutileFileOneTime==1
            {
                [self stopDown];
            }
             [self updateSome];
             [self updateBtnColor];
            return;
        }
        else if (self.state==3){
            if([MajorSystemConfig getInstance].isWifiState == AFNetworkReachabilityStatusReachableViaWWAN && ![MarjorWebConfig getInstance].isAllows4GDownMode){//非wifi状态，禁止4g下载
                return;
            }
            NSInteger downCount = [[M3u8ArEngine getInstance] getCurrentDownNumber]+[[AloneStateEngine getInstance] getCurrentDownNumber];
            if (true || (downCount==0 || [[VipPayPlus getInstance] isVaildOperation:[TmpSetView isShowState]plugKey:@"HuanCunCtrl"])) {
                [self updateSome];
                [self startDown];
                [self updateBtnColor];
            }
        }
        [self updateBtnState];
    }
}

-(void)startDown{
    //fix 单文件处理
    if( [[[AloneStateEngine getInstance] isCanSetState:self.uuid] boolValue]){
        if(![[NSFileManager defaultManager]fileExistsAtPath:[[AloneStateEngine getInstance] getStateWjTmpRootPath:self.uuid]]){
            [self reDownEvent:nil];
            return ;
        }
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf8];
    [info setObject:@[self.uuid] forKey:@"param4"];
    if(![[[AppWtManager getInstanceAndInit] getWtCallBack:info] boolValue]){
        info =  [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf17];
        [info setObject:@[self.uuid] forKey:@"param4"];
        [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    }
}

-(void)stopDown{
    //从下载下载引里面删除
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf24];
    [info setObject:@[self.uuid] forKey:@"param4"];
    [[AppWtManager getInstanceAndInit] getWtCallBack:info];
    //如果有请求网页的，需要删除用
    [[FFmpegCmd getInstace] exitffmpeg:self.uuid];
    [self updateBtnState];
    [self updateFix:false];
}

-(void)updateSome{
    if (false) {//CanDownMutileFileOneTime==0
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:DOWNAPICONFIG.msgappf6];
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNAPICONFIG.msgappOverall object:DOWNAPICONFIG.msgappf18];
    }
}

-(NSString*)getUUIDStateNewUc{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:DOWNAPICONFIG.msgappf2];
    [info setObject:[NSArray arrayWithObjects:self.uuid, nil] forKey:@"param4"];
    return [[AppWtManager getInstanceAndInit] getWtCallBack:info];
}


-(void)updateState:(NSNotification*)object{
    if ([NSThread isMainThread]) {
        [self updateMainUI:object];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateMainUI:object];
        });
    }
}

-(void)updateDownProgress:(float)progress{
    self.progressLabel.text = [NSString stringWithFormat:@"%@%0.2f%%",@"下载进度",progress];
    self.progressLabel.textColor = RGBCOLOR(255, 0, 0);
    self.nameLabel.textColor = [UIColor redColor];
    if (!self.isEdit) {
        self.state = 2;
        self.oldTitle = @"暂停";
        self.curretBtnTitle = self.oldTitle;
        [self.btn setTitle:self.oldTitle forState:UIControlStateNormal];
        [self updateBtnColor];
    }
}

-(void)updateMainUI:(NSNotification*)object{
    NSDictionary *info = object.object;
    NSArray *allKey = [info allKeys];
    NSString *ret = [self getUUIDStateNewUc];
    if(ret){
        [self updatePlayState:ret];
        return;
    }
     if ([self.progressLabel.text compare:UnKnownDespc_fileDown]==NSOrderedSame) {
     }
    if (allKey.count>0) {
        NSString *key = [allKey objectAtIndex:0];
        if ([key compare:state4_info_key]==NSOrderedSame) {
            [self updateDownProgress:[[info objectForKey:state4_info_key]floatValue]*100];
        }
        else if ([key compare:state5_info_key]==NSOrderedSame){
            self.progressLabel.text = @"";
            [self updateBtnState];
        }
        else if ([key compare:state6_info_key]==NSOrderedSame){
            self.progressLabel.text = UnKnownDespc_fileDown;
             [self updateBtnState];
        }
        else if ([key compare:state7_info_key]==NSOrderedSame){
            self.progressLabel.text = UnKnownDespc_fileDown;
             [self updateBtnState];
        }
        else if ([key compare:state1_info_key]==NSOrderedSame){
             [self updateBtnState];
        }
        else if ([key compare:state2_info_key]==NSOrderedSame || [key compare:state3_info_key]==NSOrderedSame){
             self.state = 3;
            self.oldTitle = @"开始";
            self.speedLabel.text = @"";
            self.curretBtnTitle = self.oldTitle;
            [self.btn setTitle:self.oldTitle forState:UIControlStateNormal];
            [self updateBtnColor];
        }
    }
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x += 0;
    frame.origin.y += 10;
    frame.size.height -= 10;
    frame.size.width -= 0;
    [super setFrame:frame];
}


-(void)showFuctionInfo{
    @weakify(self)
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"看视频广告,获得功能" message:nil];
    [alertView setButtonFont:[UIFont systemFontOfSize:14]];
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"NO"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
 
                                               }];
    [alertView addAction:v];
    TYAlertAction *v1  = [TYAlertAction actionWithTitle:@"看视频获得功能"
                                                  style:TYAlertActionStyleDefault
                                                handler:^(TYAlertAction *action) {
                                                    [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:0];
                                                    [[VipPayPlus getInstance] reqeustVideoAd:^(BOOL isSuccess) {
                                                        @strongify(self)
                                                        if(self.ClickType==Uc_Click_CpoyVdieo){
                                                            [self cpoyVideoFuction];
                                                        }
                                                        else if(self.ClickType==Uc_Click_CpoyHtml){
                                                            [self cpoyhtmlFuction];
                                                        }
                                                        else if (self.ClickType==Uc_Click_OpenHtml){
                                                            [self openhtmlFuction];
                                                        }
                                                        else if (self.ClickType==Uc_Click_ChangeVideoName){
                                                            [self changeName];
                                                        }
                                                          [[VideoPlayerManager getVideoPlayInstance] updatePlayAlpha:1];
                                                    }isShowAlter:true isForce:false];
                                                }];
    [alertView addAction:v1];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:NO];
}
@end
#endif
