//
//  CloseWebController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "CloseWebController.h"

@interface CloseWebController ()

@end

@implementation CloseWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) back {
    if (self.webView.canGoBack) {
        [self.webView goBack];
        return;
    }
    [self close];
}

- (void) close {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeJS];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) createLeftButtons {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0,0,44,44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-40,0,0);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItems = @[backButtonItem];
}

- (void) showCloseButton:(BOOL) flag {
    if (!flag) {
        [self createLeftButtons];
        return;
    }
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(0,0,44,44);
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-40,0,0);
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.navigationItem.leftBarButtonItems];
    if (array.count < 2) {
        if (closeButtonItem) {
            [array addObject:closeButtonItem];
        }
    }
    self.navigationItem.leftBarButtonItems = array;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    [self.webView evaluateJavaScript:@"JSBridge.init()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
//        NSLog(@"didFinishNavigation error=%@",error.localizedDescription);
//    }];
//
//    path = [[NSBundle mainBundle]pathForResource:@"h5_bridge.js" ofType:nil];
//    str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [self.webView evaluateJavaScript:str completionHandler:nil];
    if (self.webView.canGoBack) {
        [self showCloseButton:YES];
    } else {
        [self showCloseButton:NO];
    }
    __weak WebViewController *weakself = self;
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (object && !weakself.title && !weakself.isRootController) {
            weakself.title = object;
        }
    }];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
