//
//  KHookObjectWrapper.m
//  grayWolf
//
//  Created by zengbiwang on 2017/7/5.
//
//

#import "KHookObjectWrapper.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "GDTCpNativeManager.h"
@implementation KHookObjectWrapper
- (void)setup
{
    Method m = class_getInstanceMethod([UIApplication class], @selector(openURL:options:completionHandler:));
    class_addMethod([UIApplication class], @selector(openNewURL:options:completionHandler:), method_getImplementation(m), method_getTypeEncoding(m));
    method_setImplementation(m, class_getMethodImplementation([self class], @selector(openNewURL:options:completionHandler:)));
}

- (void)presentViewControllerNew:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion{

}


-(void)openNewURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion
{
    if(_clickState == GDT_CLICK_unVaild)
    {
      [self openNewURL:url options:options completionHandler:completion];
    }
}

@end
