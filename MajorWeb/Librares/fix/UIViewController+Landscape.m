/*
 * This file is part of the BLLandscape package.
 * (c) NewPan <13246884282@163.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Click https://github.com/newyjp
 * or http://www.jianshu.com/users/e2f2d779c022/latest_articles to contact me.
 */

#import "UIViewController+Landscape.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"
#import "AppDelegate.h"
#import "MajorSystemConfig.h"
@implementation UIViewController (Landscape)

+ (void)load{
    [self jr_swizzleMethod:@selector(shouldAutorotate) withMethod:@selector(bl_shouldAutorotate) error:nil];
    [self jr_swizzleMethod:@selector(supportedInterfaceOrientations) withMethod:@selector(bl_supportedInterfaceOrientations) error:nil];
}

- (BOOL)bl_shouldAutorotate{ // 是否支持旋转.

    
    if ([self checkSelfNeedLandscape]) {
        return YES;
    }
    
    if (self.bl_shouldAutoLandscape) {
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)bl_supportedInterfaceOrientations{ // 支持旋转的方向.
    if ([self checkSelfNeedLandscape]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    if (self.bl_shouldAutoLandscape) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setBl_shouldAutoLandscape:(BOOL)bl_shouldAutoLandscape{
    objc_setAssociatedObject(self, @selector(bl_shouldAutoLandscape), @(bl_shouldAutoLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bl_shouldAutoLandscape{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)checkSelfNeedLandscape{
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSOperatingSystemVersion operatingSytemVersion = processInfo.operatingSystemVersion;
    if (operatingSytemVersion.majorVersion >= 10){
        if ([self isKindOfClass:NSClassFromString(VideoCtrlSystem)]) {
            return YES;
        }
    }
    if ([self isKindOfClass:NSClassFromString(@"MajorMain")]){
        return true;
    }
    if ([MajorSystemConfig getInstance].isGotoUserModel==1 && [self isKindOfClass:NSClassFromString(@"GDTWebViewController")]) {
        return YES;
    }
    return NO;
}

@end
