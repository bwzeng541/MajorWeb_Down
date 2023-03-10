 

#import <WebKit/WebKit.h>
@interface WKWebView (LVShot)


-(void)DDGContentScreenShot:(void(^)(UIImage*screenShotImage))completion;

-(void)DDGContentScreenShotWithoutOffset:(void(^)(UIImage*screenShotImage))completion;

-(void)DDGContentPageDrawWithUIView:(UIView*)targetView Index:(int) index MaxIndex:(int)maxIndex DrawCallBack:(void (^)(void))callBack;


-(void)shotScreenContentScrollCapture:(void(^)(UIImage*screenShotImage))completion;

-(void)shotScreenContentScrollPageDrawWithIndex:(int)index MaxIndex:(int)maxIndex DrawCallBack:(void (^)(void))callBack;



@end
