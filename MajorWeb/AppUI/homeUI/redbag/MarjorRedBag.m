//
//  MarjorRedBag.m
//  MajorWeb
//
//  Created by zengbiwang on 2019/3/6.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "MarjorRedBag.h"
#import "MKNetworkKit.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "YSCHUDManager.h"
#import <AdSupport/AdSupport.h>
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "OSSManager.h"
#import "NISnapshotRotation.h"
#import "MainMorePanel.h"
#import <Photos/Photos.h>
@interface MarjorRedBag (){
    
}
@property(weak,nonatomic)IBOutlet UIImageView *headImage1;
@property(weak,nonatomic)IBOutlet UILabel *haoLabel;
@property(weak,nonatomic)IBOutlet UILabel *yzmLabel;
@property(weak,nonatomic)IBOutlet UILabel *sm1Label;
@property(weak,nonatomic)IBOutlet UILabel *sm2Label;

@property(weak,nonatomic)IBOutlet UIImageView *headImage3;
@property(weak,nonatomic)IBOutlet UIImageView *headImage2;
@property(weak,nonatomic)IBOutlet UIButton *btnResult;
@property(weak,nonatomic)IBOutlet UIButton *btnClose;
@property(weak,nonatomic)IBOutlet UIView *resultView;
//@property(weak,nonatomic)IBOutlet UIView *redJsView;

@property(nonatomic,copy)NSString* imageFilePath;
@property(nonatomic,copy)NSString* usrSerct;
@property(nonatomic,copy)NSString* timeDes;
@property(nonatomic,assign)BOOL isWin;
@property(nonatomic,copy)NSString* userNumber;
@property(nonatomic,strong)MKNetworkEngine *netWorkKit;
@property(nonatomic,strong)MKNetworkOperation *operation;
@property (nonatomic, copy) void(^willCloseBlock)(void);
@property (nonatomic, strong) OSSClient *client;
@end

@implementation MarjorRedBag


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  willCloseBlock:(void(^)(void))willCloseBlock{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.willCloseBlock = willCloseBlock;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.isWin = false;
    self.haoLabel.hidden  = self.resultView.hidden  = YES;
    self.timeDes = [[NSDate date] formattedDateWithFormat: @"YYYY/MM/dd HH:mm:ss"];
    if(GetAppDelegate.isProxyState){
        [self showError];
    }
    else{
        self.netWorkKit = [[MKNetworkEngine alloc] init];
        self.usrSerct = [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] md5];
        [self sumbit];
    }
}

-(void)sumbit{
    [YSCHUDManager showHUDOnView:self.view message:@"请稍后..."];
    self.operation = [self.netWorkKit operationWithURLString:@"http://biezhi360.cn/GetCount.aspx" timeOut:4];
    [self.operation onCompletion:^(MKNetworkOperation *completedOperation) {
        if (completedOperation.HTTPStatusCode==200) {
            [self getData];
        }
        else{
            [self showError];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self showError];
    }];
    [self.netWorkKit enqueueOperation:self.operation];
}

-(void)getData{
    self.operation = [self.netWorkKit operationWithURLString:@"http://biezhi360.cn/GetCount.aspx?back=1" timeOut:4];

    [self.operation onCompletion:^(MKNetworkOperation *completedOperation) {
        if (completedOperation.HTTPStatusCode==200) {
             self.userNumber =  completedOperation.responseString;
            [self updateReslut];
        }
        else{
            [self showError];
        }
    } onError:^(NSError *error, MKNetworkOperation *completedOperation) {
        [self showError];
    }];
    [self.netWorkKit enqueueOperation:self.operation];
}

-(void)updateReslut
{//33 66 99
    if ([self.userNumber length]>=2) {
        NSString *newStr =  [self.userNumber substringFromIndex:[self.userNumber length]-2];
        if ([newStr compare:@"33"]==NSOrderedSame || [newStr compare:@"66"]==NSOrderedSame || [newStr compare:@"99"]==NSOrderedSame) {
            self.isWin = true;
        }
    }
    else{
        self.isWin = false;
    }
    if (!self.isWin) {
        [self updateUI];
    }
    else{//提交数据到oss
        [self updateUI];
     }
}


- (UIImage *)createShareImage:(UIImage *)sourceImage Context:(NSString *)text
{
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    CGFloat nameFont = 20.f;
    //画 自己想要画的内容
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
    CGRect sizeToFit = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
    NSLog(@"图片: %f %f",imageSize.width,imageSize.height);
    NSLog(@"sizeToFit: %f %f",sizeToFit.size.width,sizeToFit.size.height);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:CGPointMake((imageSize.width-sizeToFit.size.width)/2,0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

-(NSString*)getCaptureImagePath:(BOOL)isHight{
    UIImage *image = NISnapshotOfView(self.view);
    image = [self createShareImage:image Context:self.timeDes];
    if (!isHight) {
        image = [image scaledToSize:CGSizeMake(320, image.size.height/image.size.width*320)];
    }
    NSData *data= UIImageJPEGRepresentation(image, 0.2);
    NSString *tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.usrSerct]];
    if([data writeToFile:tmpDir atomically:YES]){
        return tmpDir;
    }
    return nil;
}


-(void)updateUI{
    [YSCHUDManager hideHUDOnView:self.view animated:NO];
    self.haoLabel.hidden  = self.resultView.hidden =  false;
    NSString *strMsg = [MainMorePanel getInstance].morePanel.RewardStep;
    self.sm1Label.text = [NSString stringWithFormat:@"每签到一次，增加%@的红包",strMsg];
    self.sm2Label.text = [NSString stringWithFormat:@"今日红包已累加到%0.2f元",[strMsg floatValue]*[self.userNumber floatValue]];

    self.haoLabel.text = [NSString stringWithFormat:@"第%@号",self.userNumber];
    if (self.isWin) {
        [self.btnResult setImage:UIImageFromNSBundlePngPath(@"red_bag_dianji") forState:UIControlStateNormal];
        self.yzmLabel.text = [@"加群验证码: " stringByAppendingString:self.usrSerct];
        self.yzmLabel.adjustsFontSizeToFitWidth = YES;
    }
    else{
        self.yzmLabel.text = @"";
        [self.btnResult setImage:UIImageFromNSBundlePngPath(@"red_bag_weiha") forState:UIControlStateNormal];
    }
    if (self.isWin) {
        [self performSelector:@selector(delayPost) withObject:nil afterDelay:0.4];
    }
}

-(void)delayPost{
#if App_Use_OSS_Sycn
    self.imageFilePath = [self getCaptureImagePath:false];
    if (!self.imageFilePath) {
        [self showError];
        return;
    }
    [YSCHUDManager showHUDOnView:self.view message:@"数据检查.."];
    OSSPlainTextAKSKPairCredentialProvider *provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 3;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    conf.maxConcurrentRequestCount = 5;
    
    // switches to another credential provider.
    _client = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT
                               credentialProvider:provider
                              clientConfiguration:conf];
    
    NSString *objectKey = [self.usrSerct stringByAppendingString:@".jpg"];
    
    NSURL * fileURL = [NSURL fileURLWithPath:self.imageFilePath];
    
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = @"maxqiandao";
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    request.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];
    OSSTask * task = [_client putObject:request];
    [task continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (task.error) {
                [self.view makeToast:@"抱歉，服务器错误，请重试" duration:3 position:@"center"];
            } else {
            }
            [YSCHUDManager hideHUDOnView:self.view animated:NO];
        });
        return nil;
    }];
#endif
}

-(void)showError{
    [YSCHUDManager hideHUDOnView:self.view animated:NO];
    [self.view makeToast:@"无法获取数据，请检查网络或联系客服" duration:3 position:@"center"];
}

-(IBAction)pressback:(id)sender{
    if (self.willCloseBlock) {
        self.willCloseBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)pressSave:(id)sender{
    if (self.isWin) {
        NSString *path = [self getCaptureImagePath:true];
        if (path) {
            __weak typeof(self)weakSelf = self;
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusDenied) {
                [weakSelf.view makeToast:@"请求设置中打开保存图片权限" duration:1 position:@"center"];
            } else if(status == PHAuthorizationStatusNotDetermined){
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                    if (status == PHAuthorizationStatusAuthorized) {
                        [weakSelf saveSuccessWithAlter:path];
                    } else {
                    }
                }];
            } else if (status == PHAuthorizationStatusAuthorized){
                [weakSelf saveSuccessWithAlter:path];
            }

        }
       
    }
}

-(void)saveSuccessWithAlter:(NSString*)path{
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:path], self, @selector(completedWithImage:error:context:), nil);
}

- (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
    [[[UIApplication sharedApplication] keyWindow] makeToast:!error?@"图片保存成功":@"图片保存失败" duration:2 position:@"center"];
}
@end
