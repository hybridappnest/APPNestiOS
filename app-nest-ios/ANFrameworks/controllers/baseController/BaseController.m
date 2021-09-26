//
//  BaseController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "BaseController.h"
#import "ANFrameworks.h"
#import <AFNetworking/UIButton+AFNetworking.h>


@interface BaseController ()

@end

NSString *const ApplicationDidBecome = @"ApplicationDidBecome";

NSString *const dealLoginOut = @"dealLoginOut";

NSString *const DoneRefreshNotification = @"DoneRefreshNotification";


@implementation BaseController{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isShouldAutorotate = NO;
        self.hidesBottomBarWhenPushed = YES;
        _needBackButton = YES;
    }
    return self;
}

- (void) viewDidLoad{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *baseConfig = [NSDictionary convertNull:[dic valueForKey:@"base"]];
    if (baseConfig.count <= 0) {
        [DBXToast showToast:@"没有配置base参数，请在config.plist中配置" success:NO];
        return;
    }
    
    NSString *selectString = [baseConfig valueForKey:@"navBackColor"];
    unsigned selectColor = (unsigned)strtoul([selectString UTF8String],0,16);
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithInt:selectColor];
    BOOL flag = [[baseConfig valueForKey:@"translucent"] boolValue];
    self.navigationController.navigationBar.translucent = flag;


    NSString *titleString = [baseConfig valueForKey:@"titleColor"];
    unsigned titleColor = (unsigned)strtoul([titleString UTF8String],0,16);
    
    CGFloat titltFont = [[baseConfig valueForKey:@"titleFont"] floatValue];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithInt:titleColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:titltFont],NSFontAttributeName,nil]];
    
    NSString *backString = [baseConfig valueForKey:@"backColor"];
    unsigned backColor = (unsigned)strtoul([backString UTF8String],0,16);
    self.view.backgroundColor = [UIColor colorWithInt:backColor];
    if (_needBackButton) {
        [self setLeftButton:@selector(back) img:[baseConfig valueForKey:@"backImageName"]];
    }
    
    _isTabBarHidden = self.hidesBottomBarWhenPushed;
    
    [self createSefeView];
}

- (void) createSefeView {
    CGFloat statusHeight = [Tool statusBarHeight];
    CGFloat tabHeight = self.tabBarController.tabBar.height;
    CGFloat safeHeight = 0;
    if (_isTabBarHidden) {
        safeHeight = [Tool safeAreaBottomHeight];
    }
    if ([Tool isBangs]) {
        CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat y = 0;
        if (_isNavBarHidden) {
            navHeight = 0;
            y = [Tool safeAreaTopHeight];
        }
        if (tabHeight == 0) {
            tabHeight = 83 - [Tool safeAreaBottomHeight];
        }
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - statusHeight - navHeight - tabHeight + safeHeight + 15)];
        [self.view addSubview:_container];
    } else {
        CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
        if (_isTabBarHidden && tabHeight > 0) {
            tabHeight = 0;
        }
        if (_isNavBarHidden) {
            if (navHeight > 0) {
                navHeight = 0;
            }
            if (statusHeight > 0) {
                statusHeight = 0;
            }
        }
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - tabHeight - navHeight - statusHeight)];
//        _container.backgroundColor = [UIColor redColor];
        [self.view addSubview:_container];
    }
    
    _safeView.backgroundColor = [UIColor clearColor];
    _container.backgroundColor = [UIColor clearColor];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isNavBarHidden) {
        self.navigationController.navigationBar.hidden = YES;
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) back{
    if(self.presentingViewController){
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) setLeftButton:(SEL)action img:(NSString*)imgName{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0,0,70,44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-70,0,0);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

-(void) setRightButton:(SEL)action img:(NSString*)imgName{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [backBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateHighlighted];
    
    backBtn.frame = CGRectMake(0, 0, 70, 44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0, 0,-40);
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = backButtonItem;
}

-(void) setRightButton:(SEL)action netimg:(NSString*)imgName{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imgName]];
    [backBtn setImageForState:UIControlStateHighlighted withURL:[NSURL URLWithString:imgName]];
    
    backBtn.frame = CGRectMake(0, 0, 60, 44);
//    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0, 0,-40);
//    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, -15, -40)];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = backButtonItem;
}

-(void) setRightStringButton:(SEL)action string:(NSString*)string color:(unsigned) color{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [backBtn setTitle:string  forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithInt:color] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    backBtn.frame = CGRectMake(0, 0, 70, 44);
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = backButtonItem;
}

-(void) setLeftStringButton:(SEL)action string:(NSString*)string{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [backBtn setTitle:string  forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    backBtn.frame = CGRectMake(0, 0, 70, 44);
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

//- (id) addRefreshHeader:(MJRefreshComponentAction)refreshingBlock{
//    return _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:refreshingBlock];
//}
//
//- (id) addRefreshFooter:(MJRefreshComponentAction)refreshingBlock{
//    return _refresFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:refreshingBlock];
//}

//- (void) doneRefresh{
//    if(_refreshHeader){
//        [_refreshHeader endRefreshing];
//    }
//    
//    if(_refresFooter){
//        [_refresFooter endRefreshing];
//    }
//}

+ (UIColor *) backColor{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *baseConfig = [NSDictionary convertNull:[dic valueForKey:@"base"]];
    if (baseConfig.count <= 0) {
        [DBXToast showToast:@"没有配置base参数，请在config.plist中配置" success:NO];
        return nil;
    }
    NSString *backString = [baseConfig valueForKey:@"backColor"];
    unsigned backColor = (unsigned)strtoul([backString UTF8String],0,16);
    return [UIColor colorWithInt:backColor];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIViewController*) childViewControllerForStatusBarStyle{
    return self;
}

- (BOOL) shouldAutorotate{
    return _isShouldAutorotate;
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"Is cancelled: %i", [context isCancelled]);
    }];
}

@end
