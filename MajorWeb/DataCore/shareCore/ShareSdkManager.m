
#import "ShareSdkManager.h"
#if WelfareManagerValue
#import "WelfareManager.h"
#endif
#import "helpFuntion.h"
#import "WXApi.h"
#import "AppDelegate.h"
#import "MajorSystemConfig.h"
#import "TYAlertAction+TagValue.h"
#import "IQUIWindow+Hierarchy.h"
#import "BeatifyAliOssManager.h"
typedef NSArray* (^shareTypeBlock)(void);
typedef NSString* (^valueBlock)(void);
typedef UIImage* (^imageBlock)(void);
@interface ShareSdkManager()
@property(copy)isForceShareBlock forceShareBlock;
@end
@implementation ShareSdkManager
+(ShareSdkManager*)getInstance{
    static ShareSdkManager *g = NULL;
    if (!g) {
        g = [[ShareSdkManager alloc]init];
    }
    return g;
}


-(NSString*)getShareTitle{
    NSInteger titleTimes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shareTitle20180709"] integerValue];
    NSArray *array = [NSArray arrayWithObjects:TITLE,@" 推荐一个电影app，可以下载网页视频，可以看各种会员视频！",@"各大会员视频，全部免费看的电影APP。",@"支持任何网站下载视频，提供各种小电影网站",@"老司机的福利！各种福利APP！可以看各电影！",@"可以赚钱的APP，一边看电影，一边赚钱！", nil];
    titleTimes=(titleTimes+1)%array.count;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:titleTimes] forKey:@"shareTitle20180709"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    return [array objectAtIndex:titleTimes];
}

-(void)clearForceShareBlock{
    self.forceShareBlock = nil;
}

-(BOOL)isForceShare2:(SSDKPlatformType)type msg:(NSString*)msg image:(UIImage *)_image forceShareBlock:(isForceShareBlock)forceShareBlock{
    if ((![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]||[MajorSystemConfig getInstance].isOpen)) {
        return false;
    }
#if WelfareManagerValue
    if (![[WelfareManager getInstance] isWelfSupreVip] && IF_IPHONE && (GetAppDelegate.isShareGoOn))//强制分享
#else
        if (IF_IPHONE)
#endif
        {
            GetAppDelegate.isPressShare = true;
            if (true)
            {
                   if ( true) {
                    self.forceShareBlock = forceShareBlock;
                    UIImage *image = nil;
                    if (_image) {
                        image = _image;
                    }
                    else{
                        image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"AppIcon60x60@3x" ofType:@"png"]];
                    }
                    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                    SSDKContentType mediaType = SSDKContentTypeApp;
                    NSString *strMsg = TITLE;
                    if (msg) {
                        strMsg = msg;
                    }
                    [shareParams SSDKSetupWeChatParamsByText:CONTENT title:[self getShareTitle] url:[NSURL URLWithString:kAppUrl] thumbImage:image image:image musicFileURL:NULL extInfo:NULL fileData:NULL emoticonData:NULL sourceFileExtension:NULL sourceFileData:NULL type:mediaType forPlatformSubType:(type)];
                    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                        if (state != SSDKResponseStateBegin) {
                            
                        }
                        if (state==SSDKResponseStateBegin) {
                            
                        }
                        else if(state==SSDKResponseStateFail){
                            [self reSetPressShare];
                            if (self.forceShareBlock) {
                                self.forceShareBlock(false);
                            }
                        }
                        else if (state == SSDKResponseStateSuccess)
                        {
                            [self reSetPressShare];
#if WelfareManagerValue
                            [[WelfareManager getInstance] addShareTimes];
#endif
                            if (self.forceShareBlock) {
                                self.forceShareBlock(true);
                            }
                        }
                        else if (state==SSDKResponseStateCancel){
                            [self reSetPressShare];
                            if (self.forceShareBlock) {
                                self.forceShareBlock(false);
                            }
                            
                        }
                    }];
                    return true;
                }
            }
            else{
             }
        }
    return false;
}

-(BOOL)isForceShare:(SSDKPlatformType)type msg:(NSString*)msg image:(UIImage *)_image forceShareBlock:(isForceShareBlock)forceShareBlock{
    if ((![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]||[MajorSystemConfig getInstance].isOpen)) {
        return false;
    }
#if WelfareManagerValue
    if (![[WelfareManager getInstance] isWelfSupreVip] && IF_IPHONE && (GetAppDelegate.isShareGoOn))//强制分享
#else
     if (IF_IPHONE)
#endif
    {
        
        if ( [[helpFuntion gethelpFuntion] isValideNotAutoAddCommonDay:@"ss_cc_20180615_"nCount:1 intervalDay:7 isUseYYCache:true time:nil])
        {
            GetAppDelegate.isPressShare = true;
            //判断第二次点击才用
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            int number = [[defaults objectForKey:@"ss_cc_20180615_flag"] intValue];
            if ( number>=2) {
                self.forceShareBlock = forceShareBlock;
                UIImage *image = nil;
                if (_image) {
                    image = _image;
                }
                else{
                    image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"AppIcon60x60@3x" ofType:@"png"]];
                }
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                SSDKContentType mediaType = SSDKContentTypeApp;
                NSString *strMsg = TITLE;
                if (msg) {
                    strMsg = msg;
                }
                [shareParams SSDKSetupWeChatParamsByText:CONTENT title:[self getShareTitle] url:[NSURL URLWithString:kAppUrl] thumbImage:image image:image musicFileURL:NULL extInfo:NULL fileData:NULL emoticonData:NULL sourceFileExtension:NULL sourceFileData:NULL type:mediaType forPlatformSubType:(type)];
                [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                    if (state != SSDKResponseStateBegin) {
                        
                    }
                    if (state==SSDKResponseStateBegin) {
                        
                    }
                    else if(state==SSDKResponseStateFail){
                        [self reSetPressShare];
                        if (self.forceShareBlock) {
                            self.forceShareBlock(false);
                        }
                    }
                    else if (state == SSDKResponseStateSuccess)
                    {
                        [self reSetPressShare];
#if WelfareManagerValue
                        [[WelfareManager getInstance] addShareTimes];
#endif
                        [[helpFuntion gethelpFuntion] isValideCommonDay:@"ss_cc_20180615_"nCount:1 intervalDay:7 isUseYYCache:true time:nil];
                        if (self.forceShareBlock) {
                            self.forceShareBlock(true);
                        }
                    }
                    else if (state==SSDKResponseStateCancel){
                        [self reSetPressShare];
                        if (self.forceShareBlock) {
                            self.forceShareBlock(false);
                        }
                  
                    }
                }];
                return true;
            }
            else{
                [defaults setObject:[NSNumber numberWithInt:number+1] forKey:@"ss_cc_20180615_flag"];
                [defaults synchronize];
            }
        }
        else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ss_cc_20180615_flag"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return false;
}

-(NSString*)getDesFrom:(SSDKPlatformType)type{
    if (type==SSDKPlatformSubTypeWechatSession) {
        return @"微信好友";
    }
    else if (type == SSDKPlatformSubTypeWechatTimeline)
    {
        return @"微信朋友圈";
    }
    else if (type==SSDKPlatformSubTypeQQFriend){
        return @"QQ好友";
    }
    else if (type==SSDKPlatformSubTypeQZone){
        return @"QQ空间";
    }
    return @"测试";
}

-(void)showShareTypeFixType:(SSDKContentType)shareType typeArray:(NSArray*(^)(void))typeArray  value:(NSString*(^)(void) )msgBlock titleBlock:(NSString*(^)(void))titleBlock imageBlock:(UIImage*(^)(void))imageBlock urlBlock:(NSString*(^)(void))urlBlock shareViewTileBlock:(NSString*(^)(void))shareTitleBlock{
    NSArray *array =  typeArray();
    NSString *msg = msgBlock();
    NSString* title = titleBlock();
    UIImage *image = imageBlock();
    NSString *url = urlBlock();
    NSString *shareTitle = shareTitleBlock();
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:shareTitle message:nil];
    for (int i =0; i < array.count; i++) {
        NSInteger type = [[array objectAtIndex:i] integerValue];
        __weak __typeof(self)weakSelf = self;
        TYAlertAction *v  = [TYAlertAction actionWithTitle:[self getDesFrom:type]
                                                     style:TYAlertActionStyleDefault
                                                   handler:^(TYAlertAction *action) {
                                                       NSInteger vv = action.tagValue;
                                                       [weakSelf shareHomeWithContent:vv msg:msg title:title contentType:(shareType) image:image url:url];
                                                   }];
        v.tagValue =type;
        [alertView addAction:v];
    }
    TYAlertAction *v  = [TYAlertAction actionWithTitle:@"取消"
                                                 style:TYAlertActionStyleCancel
                                               handler:^(TYAlertAction *action) {
                                                   
                                               }];
    [alertView addAction:v];
    [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
}

-(id)showShareType:(SSDKContentType)type typeArray:(NSArray*(^)(void))typeArray  value:(NSString*(^)(void) )msgBlock titleBlock:(NSString*(^)(void))titleBlock imageBlock:(UIImage*(^)(void))imageBlock urlBlock:(NSString*(^)(void))urlBlock shareViewTileBlock:(NSString*(^)(void))shareTitleBlock{
        NSArray *array =  typeArray();
    NSString *msg = msgBlock();
    NSString* title = titleBlock();
    UIImage *image = imageBlock();
    NSString *url = urlBlock();
    NSString *shareTitle = shareTitleBlock();
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:shareTitle message:nil];
        for (int i =0; i < array.count; i++) {
            NSInteger type = [[array objectAtIndex:i] integerValue];
            __weak __typeof(self)weakSelf = self;
            TYAlertAction *v  = [TYAlertAction actionWithTitle:[self getDesFrom:type]
                                                         style:TYAlertActionStyleDefault
                                                       handler:^(TYAlertAction *action) {
                                                           NSInteger vv = action.tagValue;
                                                           [weakSelf shareHomeWithContent:vv msg:msg title:title contentType:(SSDKContentTypeWebPage) image:image url:url];
                                                       }];
            v.tagValue =type;
            [alertView addAction:v];
        }
        TYAlertAction *v  = [TYAlertAction actionWithTitle:@"取消"
                                                     style:TYAlertActionStyleCancel
                                                   handler:^(TYAlertAction *action) {
                                                       
                                                   }];
        [alertView addAction:v];
      [alertView showInWindowWithOriginY:0 backgoundTapDismissEnable:YES];
    return alertView;
}

-(void)shareContentQQ:(UIViewController*)ctrl context:(NSString *)context image:(UIImage*)image gifPath:(NSString*)gifPath shareType:(SSDKPlatformType)type{
    NSMutableDictionary *shareParame = [NSMutableDictionary dictionary];
    [shareParame SSDKSetupQQParamsByText:CONTENT title:[self getShareTitle] url:[NSURL URLWithString:kAppUrl]  thumbImage:image image:gifPath type:SSDKContentTypeImage forPlatformSubType:type];
    
    [ShareSDK share:type parameters:shareParame onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        if (state != SSDKResponseStateBegin) {
            NSLog(@"state = %d",state);
        }
        
        if (state==SSDKResponseStateBegin) {
            
        }
        else if (state == SSDKResponseStateSuccess)
        {
#if WelfareManagerValue
            [[WelfareManager getInstance] addShareTimes];
#endif
        }
        else if (state == SSDKResponseStateFail)
        {
            NSLog(@"faild = %@",[error.debugDescription description]);
        }

    }];
}

-(void)shareHomeWithContent:(SSDKPlatformType)type msg:(NSString*)msg title:(NSString*)title contentType:(SSDKContentType)contentType image:(UIImage *)_image url:(NSString *)url{
    UIImage *image = nil;
    if (_image) {
        image = _image;
    }
    else{
        image =  [UIImage imageNamed:@"shareIcon"];
    }
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    SSDKContentType mediaType = contentType;
    NSString *strMsg = TITLE;
    if (msg) {
        strMsg = msg;
    }
    GetAppDelegate.isPressShare = true;
    NSString *_title = title;
    if (!_title) {
        _title = [self getShareTitle];
    }
    if ([_title rangeOfString:BeatifyAssetVideoShareMsg].location!=NSNotFound) {
        url = [[BeatifyAliOssManager getInstance] updateAsset2:url];
    }
    NSString *urlShare = !url?kAppUrl:url;
    NSString *conentMsgNew = CONTENT;
    NSString *titleNew = _title;
    if (url && SSDKPlatformSubTypeWechatTimeline!=type) {
        conentMsgNew = title;
        titleNew = CONTENT;
    }
    if(type==SSDKPlatformSubTypeQZone || type == SSDKPlatformSubTypeQQFriend){
        [shareParams SSDKSetupQQParamsByText:conentMsgNew title:titleNew url:[NSURL URLWithString:urlShare]  thumbImage:image image:image type:mediaType forPlatformSubType:type];
    }
    else {
    [shareParams SSDKSetupWeChatParamsByText:conentMsgNew title:titleNew url:[NSURL URLWithString:urlShare] thumbImage:image image:image musicFileURL:NULL extInfo:NULL fileData:NULL emoticonData:NULL sourceFileExtension:NULL sourceFileData:NULL type:mediaType forPlatformSubType:(type)];
    }
    [ShareSDK share:type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        NSLog(@"state = %d",state);
        if (state != SSDKResponseStateBegin) {
        
        }
        if (state==SSDKResponseStateBegin) {
            
        }
        else if(state==SSDKResponseStateFail){
            [self reSetPressShare];
        }
        else if (state == SSDKResponseStateSuccess)
        {
            [self reSetPressShare];
            NSString *o = [NSString stringWithFormat:@"%d_gold_notifi",[[contentEntity.rawData objectForKey:@"platform"]intValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:o object:nil];
#if WelfareManagerValue
            [[WelfareManager getInstance] addShareTimes];
#endif
        }
        else if (state==SSDKResponseStateCancel){
            [self reSetPressShare];
        }
    }];
}

-(void)reSetPressShare{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GetAppDelegate.isPressShare = false;
    });
}

-(void)shareHome:(SSDKPlatformType)type{
    [self shareHomeWithContent:type msg:nil title:nil contentType:SSDKContentTypeApp image:nil url:nil];
}

-(void)shareContent:(UIViewController*)ctrl context:(NSString *)contentText imagePath:(NSString*)imagePath shareType:(SSDKPlatformType)_type isShareImage:(BOOL)_isShareImage isGif:(BOOL)isGif{
    
   // isAddShareImage = _isShareImage;
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    SSDKContentType mediaType = SSDKContentTypeImage;
  
        if (_type==SSDKPlatformSubTypeWechatTimeline ||  _type == SSDKPlatformSubTypeWechatSession) {
        
            if (isGif) {
                [shareParams SSDKSetupWeChatParamsByText:CONTENT title:[self getShareTitle] url:[NSURL URLWithString:kAppUrl] thumbImage:image image:[NSURL fileURLWithPath:imagePath] musicFileURL:NULL extInfo:NULL fileData:NULL emoticonData:[NSURL fileURLWithPath:imagePath] sourceFileExtension:@"gif" sourceFileData:[NSURL fileURLWithPath:imagePath] type:SSDKContentTypeImage forPlatformSubType:(_type)];
            }
            else{
         [shareParams SSDKSetupWeChatParamsByText:CONTENT title:[self getShareTitle] url:[NSURL URLWithString:kAppUrl] thumbImage:image image:[NSURL fileURLWithPath:imagePath] musicFileURL:NULL extInfo:NULL fileData:NULL emoticonData:NULL sourceFileExtension:NULL sourceFileData:NULL type:mediaType forPlatformSubType:(_type)];
            }
    }
    else{//qq
        [shareParams SSDKSetupQQParamsByText:@"ONTENT" title:@"TITLE" url:[NSURL URLWithString:kAppUrl] audioFlashURL:NULL videoFlashURL:NULL thumbImage:image images:image type:mediaType forPlatformSubType:_type];
    }
    [ShareSDK share:_type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        if (state != SSDKResponseStateBegin) {
            NSLog(@"state = %d",state);
        }
        
        if (state==SSDKResponseStateBegin) {
            
        }
        else if (state == SSDKResponseStateSuccess)
        {
#if WelfareManagerValue
            [[WelfareManager getInstance] addShareTimes];
#endif
        }
        else if (state == SSDKResponseStateFail)
        {
            NSLog(@"faild = %@",[error.debugDescription description]);
        }
    }];
}

-(void)shareContentVideo:(UIViewController*)ctrl context:(NSString *)context image:(UIImage*)image videoPath:(NSString*)videoPath shareType:(SSDKPlatformType)_type{

    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    SSDKContentType mediaType = SSDKContentTypeFile;
  
    if (_type==SSDKPlatformSubTypeWechatTimeline ||  _type == SSDKPlatformSubTypeWechatSession) {
        NSData *data= [NSData dataWithContentsOfFile:videoPath];
        [shareParams SSDKSetupWeChatParamsByText:CONTENT title:[self getShareTitle] url:[NSURL URLWithString:kAppUrl] thumbImage:image image:image musicFileURL:NULL extInfo:NULL fileData:NULL emoticonData:NULL sourceFileExtension:@"mov" sourceFileData:data type:mediaType forPlatformSubType:(_type)];
    }
    else{//qq
        [shareParams SSDKSetupQQParamsByText:@"ONTENT" title:@"TITLE" url:[NSURL URLWithString:kAppUrl] audioFlashURL:NULL videoFlashURL:NULL thumbImage:image images:image type:mediaType forPlatformSubType:_type];
    }
    [ShareSDK share:_type parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        if (state != SSDKResponseStateBegin) {
            NSLog(@"state = %d",state);
        }
        
        if (state==SSDKResponseStateBegin) {
            
        }
        else if (state == SSDKResponseStateSuccess)
        {
#if WelfareManagerValue
            [[WelfareManager getInstance] addShareTimes];
#endif

        }
        else if (state == SSDKResponseStateFail)
        {
            NSLog(@"faild = %@",[error.debugDescription description]);
        }
        
    }];
}
@end
