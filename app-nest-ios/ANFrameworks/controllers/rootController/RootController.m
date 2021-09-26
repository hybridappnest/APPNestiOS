//
//  RootController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "RootController.h"
#import "BaseNavigationController.h"
#import "BaseController.h"
#import "WebViewController.h"
#import "ANFrameworks.h"
#import "AppDelegate.h"



NSString *const NOLoginNotification = @"NOLoginNotification";

@implementation RootController

- (void) viewDidLoad{
    [super viewDidLoad];
    _beforeLoginIndex = -1;
    [self creatsViewControllers];

}

- (void) switchController:(NSInteger) index {
    self.selectedIndex = index;
}

- (void) creatsViewControllers{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *tabbarConfig = [NSArray convertNull:[dic valueForKey:@"tabbar"]];
    if (tabbarConfig.count <= 0) {
        [DBXToast showToast:@"没有配置tabbar参数，请在config.plist中配置" success:NO];
        return;
    }
    
    NSArray *array = tabbarConfig;
    NSMutableArray *controllers = [NSMutableArray array];
        
    int i = 0;
    NSInteger selectedIndex = 0;
    for (NSDictionary *dic in array) {

        NSString *className = [dic objectForKey:@"className"];
        NSString *url = [dic objectForKey:@"url"];
        BOOL isSelected = [[dic objectForKey:@"isSelected"] boolValue];
        if (isSelected) {
            selectedIndex = i;
        }
        if (!(className && className.length > 0)) {
//            BOOL isIM = [[dic objectForKey:@"isIM"] boolValue];
//            if (isIM) {
//                className = @"BaseController";
//            } else
            if (url && url.length > 0) {
                className = @"WebViewController";
            }
        }
        Class class = NSClassFromString(className);
        BaseController *root = [[class alloc] init];
        root.isRootController = YES;
        if ([root isKindOfClass:[WebViewController class]]) {
            WebViewController *controller = (WebViewController*)root;
            controller.url = url;
        }
        NSString *imageName = [dic objectForKey:@"imageRes"];
        NSString *selectImageName = [dic objectForKey:@"imageResSelected"];;
    
        UIImage *nomalImage = [UIImage imageNamed:imageName];
        nomalImage = [nomalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectdImag = [UIImage imageNamed:selectImageName];
        selectdImag = [selectdImag imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:[dic objectForKey:@"name"] image:nomalImage selectedImage:selectdImag];
        item.tag = i;
        root.tabBarItem = item;
        NSString *selectString = [dic valueForKey:@"textColorResSelected"];
        unsigned selectColor = (unsigned)strtoul([selectString UTF8String],0,16);
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithInt:selectColor], NSForegroundColorAttributeName,nil] forState:UIControlStateSelected];
        NSString *nomalString = [dic valueForKey:@"textColorRes"];
        unsigned nomalColor = (unsigned)strtoul([nomalString UTF8String],0,16);
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithInt:nomalColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        NSString *highlightString = [dic valueForKey:@"textColorRes"];
        unsigned highlightColor = (unsigned)strtoul([highlightString UTF8String],0,16);
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithInt:highlightColor], NSForegroundColorAttributeName,nil] forState:UIControlStateHighlighted];
        root.needBackButton = NO;
        root.hidesBottomBarWhenPushed = NO;

        BaseNavigationController *nvcController = [[BaseNavigationController alloc] initWithRootViewController:root];
        nvcController.title = [dic objectForKey:@"name"];
        root.navigationItem.title = [dic objectForKey:@"name"];
        [controllers addObject:nvcController];
        i++;
    }
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithInt:0xf8f8f8]];
    [UITabBar appearance].translucent = NO;
    self.viewControllers = controllers;
}

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
//    NSLog(@"selectedIndex %d",self.selectedIndex);
    if(item.tag != 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOLoginNotification object:nil];
    }
}

- (UIViewController*) currentController {
    UINavigationController * nav = [self.viewControllers objectAtIndex:self.selectedIndex];
    NSArray *array = [nav viewControllers];
    return [array lastObject];
}


+ (UIViewController*) topController {
    UIViewController *controller = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
//            NSLog(@"windowScene = %@",windowScene);
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        if ([window.rootViewController isKindOfClass:[RootController class]]) {
                            RootController *root = (RootController*)window.rootViewController;
                            controller = [root currentController];
                        }
//                        controller = window.rootViewController;
                    }
                }
            }
        }
    } else {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([app.window.rootViewController isKindOfClass:[RootController class]]) {
            RootController *root = (RootController*)app.window.rootViewController;
            controller = [root currentController];
        }
    }
    return controller;
}

+ (UIViewController*) rootController {
    UIViewController *controller = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
//            NSLog(@"windowScene = %@",windowScene);
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        controller = window.rootViewController;
                    }
                }
            }
        }
    } else {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        controller = app.window.rootViewController;
    }
    return controller;
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:removeJSNotification object:nil userInfo:@{@"all":@YES}];
}

- (BOOL)shouldAutorotate{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

@end
