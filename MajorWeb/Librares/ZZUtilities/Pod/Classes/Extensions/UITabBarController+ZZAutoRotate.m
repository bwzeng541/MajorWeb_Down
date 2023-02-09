#import "UITabBarController+ZZAutoRotate.h"

@implementation UITabBarController (ZZAutoRotate)

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end