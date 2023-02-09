//
//  QrMutilLineScanCtrl.h
//  QRTools
//
//  Created by bxing zeng on 2020/5/8.
//  Copyright © 2020 bixing zeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol QrMutilLineScanCtrlDelegate <NSObject>
-(void)qrMutitlLineRemove;
@end
@interface QrMutilLineScanCtrl : UIViewController
@property(weak)id<QrMutilLineScanCtrlDelegate>delegate;
@property(assign)BOOL isMutilFront;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil array:(NSArray*)array webView:(WKWebView*)webView title:(NSString*)mediaTitle;
@end

NS_ASSUME_NONNULL_END
