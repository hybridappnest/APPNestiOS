//
//  baseNavigationController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "BaseNavigationController.h"

@implementation BaseNavigationController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//不支持频幕旋转
- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

//界面支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}


@end
