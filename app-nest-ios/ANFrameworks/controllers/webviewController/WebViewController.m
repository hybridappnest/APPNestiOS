//
//  WebViewController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "WebViewController.h"
#import <CoreServices/CoreServices.h>
#import "ANFrameworks.h"
#import <Photos/Photos.h>
#import "YBIBDefaultWebImageMediator.h"


NSString *const toChoseUser = @"toChoseUser";
NSString *const toStartLocation = @"toStartLocation";
NSString *const toStopLocation = @"toStopLocation";
NSString *const removeJSNotification = @"removeJSNotification";
NSString *const removeLocationObserver = @"removeLocationObserver";
NSString *const toDetailHistory = @"toDetailHistory";

@implementation DBXWebProcessPool : NSObject

+ (instancetype)sharedInstance {
    static DBXWebProcessPool *bizService;
    static dispatch_once_t llSOnceToken;
    dispatch_once(&llSOnceToken, ^{
        bizService = [[self alloc] init];
    });
    return bizService;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _processPool = [[WKProcessPool alloc] init];
    }
    return  self;
}

@end

@implementation WebViewController {
    BOOL errorPageShow;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (id)initWithParams:(NSDictionary*) params
{
    self = [super init];
    if (self) {
        NSArray *keys = [params allKeys];
        if ([keys containsObject:@"showTitleBar"]) {
            id showTitleBar = [params valueForKey:@"showTitleBar"];
            self.isNavBarHidden = ![showTitleBar boolValue];
        }
        
        if ([keys containsObject:@"readTitle"]) {
            id readTitle = [params valueForKey:@"readTitle"];
            self.readTitle = ![readTitle boolValue];;
        }
        if ([keys containsObject:@"title"]) {
            self.titleString = [NSString convertNull:[params valueForKey:@"title"]];
        }
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void) removeJS {
    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"JSBridge"];
    if (@available(iOS 14.0, *)) {
        [self.webView.configuration.userContentController removeAllScriptMessageHandlers];
    } else {
        // Fallback on earlier versions
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"JSBridge"];
    }
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void) back {
//    if (_webView.canGoBack) {
//        [_webView goBack];
//        return;
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeJS];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isRootController) {
//        self.navigationItem.title = self.titleString;
    } else {
        self.title = self.titleString;
    }
    
    
    [self createWebView];

    [self createProgress];
    // Do any additional setup after loading the view from its nib.
    
   
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.webView reload];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) createWebView {
    WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
    webConfiguration.userContentController = [WKUserContentController new];
    webConfiguration.allowsInlineMediaPlayback = YES;
    webConfiguration.processPool = [DBXWebProcessPool sharedInstance].processPool;
    
    WKPreferences *preference = [[WKPreferences alloc]init];
//        /// 最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
//        preference.minimumFontSize = 40.0;
//        /// 设置是否支持javaScript 默认是支持的
    preference.javaScriptEnabled = YES;
    preference.javaScriptCanOpenWindowsAutomatically = YES;
//        /// 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
//        preference.javaScriptCanOpenWindowsAutomatically = YES;
//        config.preferences = preference;
    
    webConfiguration.preferences = preference;

//    NSMutableString *cookieString = [[NSMutableString alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"webView.js" ofType:nil];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:str injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [webConfiguration.userContentController addUserScript:usrScript];
    
    
    NSDictionary *dic = [self envdata];
    NSString *envdata = [Tool toJSONString:dic];
    NSString *envString = [NSString stringWithFormat:@"window.dbx_envs = %@",envdata];
    WKUserScript *envScript = [[WKUserScript alloc] initWithSource:envString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [webConfiguration.userContentController addUserScript:envScript];
    
    if (_startupParams && _startupParams.length > 0) {
        NSString *startupString = [NSString stringWithFormat:@"window.startupParams = %@",_startupParams];
        WKUserScript *startupScript = [[WKUserScript alloc] initWithSource:startupString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [webConfiguration.userContentController addUserScript:startupScript];
    }
    
    [webConfiguration.userContentController addScriptMessageHandler:self name:@"JSBridge"];
    CGFloat y = 0;
    if (![Tool isBangs] && self.isNavBarHidden) {
        y = [Tool statusBarHeight];
    }
    CGFloat h = 0;
    CGFloat tabHeight = self.tabBarController.tabBar.height;
    if ([Tool isBangs] && tabHeight == 0) {
        h = [Tool safeAreaBottomHeight];
    }
   _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, y, self.container.frame.size.width, self.container.frame.size.height - y - h) configuration:webConfiguration];
   _webView.UIDelegate = self;
   _webView.navigationDelegate = self;
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)];
    [self.container addSubview:emptyView];
    [emptyView addSubview:_webView];
    
    __weak WebViewController *weakself = self;
    // 获取默认User-Agent
    [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSString *oldAgent = result;
        // 给User-Agent添加额外的信息
        NSString *newAgent = [NSString stringWithFormat:@"%@;%@", oldAgent, @"dingbaox_ios_app"];
        weakself.webView.customUserAgent = newAgent;
    }];
    
    NSString *urlStr = [_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];;
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlStr = %@",urlStr);
   NSURL *url = [NSURL URLWithString:urlStr];
   NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];//NSURLRequestReloadIgnoringLocalAndRemoteCacheData
   [_webView loadRequest:request];
    _webView.backgroundColor = [UIColor clearColor];
}

- (void) createProgress {
    CGFloat y = 0;
//    if (![Tool isBangs] && self.isNavBarHidden && self.isTabBarHidden) {
//        y = [Tool appStatusBarHeight];
//    }
    UIView * progress = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.frame), 3)];
    progress.backgroundColor = [UIColor clearColor];
    [self.webView addSubview:progress];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
    // 隐式动画
    CALayer * layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor colorWithInt:0x32B8EC].CGColor;
    [progress.layer addSublayer:layer];
    self.progressLayer = layer;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"change == %@",change);
        self.progressLayer.opacity = 1;
        self.progressLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[NSKeyValueChangeNewKey] floatValue], 3);
        __weak WebViewController *weakself = self;
        if ([change[NSKeyValueChangeNewKey] floatValue] == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakself.progressLayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakself.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark js handler

- (void) rigthButton:(UIButton*) button {
    NSString *js = [NSString stringWithFormat:@"JSBridge.trigger('%@','%@');",@"optionMenu",@"{}"];
    __weak WebViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.webView evaluateJavaScript:js completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            NSLog(@"optionMenu obj=%@",data);
            NSLog(@"optionMenu error=%@",error.localizedDescription);
        }];
    });
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(void(^)(id responseData,NSError * _Nullable error))callback {
    if (data) {
        NSString *dataString = [Tool toJSONString:data];
        dataString = [self deleteChart:dataString];
        NSLog(@"%@ = %@",handlerName,dataString);
//        NSString *js = [NSString stringWithFormat:@"JSBridge.trigger('%@','%@');",handlerName,dataString];
        NSString *js = [NSString stringWithFormat:@"%@(%@);",handlerName,dataString];
//        NSString *js = [NSString stringWithFormat:@"JSBridge.trigger('%@','%@');",handlerName,dataString];
        __weak WebViewController *weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.webView evaluateJavaScript:js completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                NSLog(@"%@ obj=%@",handlerName,data);
                NSLog(@"%@ error=%@",handlerName,error.localizedDescription);
                callback(data,error);
            }];
        });
    }
}

- (void)trigger:(NSString *)handlerName data:(id)data responseCallback:(void(^)(id responseData,NSError * _Nullable error))callback {
    if (data) {
        NSString *dataString = [Tool toJSONString:data];
        dataString = [self deleteChart:dataString];
        NSLog(@"%@ = %@",handlerName,dataString);
        NSString *js = [NSString stringWithFormat:@"JSBridge.trigger('%@','%@');",handlerName,dataString];
        __weak WebViewController *weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.webView evaluateJavaScript:js completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                NSLog(@"%@ obj=%@",handlerName,data);
                NSLog(@"%@ error=%@",handlerName,error.localizedDescription);
                callback(data,error);
            }];
        });
    }
}

- (NSString*) deleteChart:(NSString*) string {
    NSString *dataString = string;
    if ([dataString containsString:@"\n"]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    if ([dataString containsString:@"\r"]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    if ([dataString containsString:@" "]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@"  " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    if ([dataString containsString:@" "]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    if ([dataString containsString:@"    "]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@"    " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    if ([dataString containsString:@"\t"]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@"\t" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    if ([dataString containsString:@"\\t"]) {
        dataString = [dataString stringByReplacingOccurrencesOfString:@"\\t" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, dataString.length)];
    }
    return dataString;
}

- (void) resume:(NSDictionary*) data {
    NSString *dataString = @"{}";
    if (data && data.count > 0) {
        dataString = [Tool toJSONString:data];
        dataString = [self deleteChart:dataString];
    }
    
    NSLog(@"resume = %@",dataString);
    NSString *js = [NSString stringWithFormat:@"JSBridge.trigger('%@','%@');",@"resume",dataString];
    __weak WebViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.webView evaluateJavaScript:js completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            NSLog(@"resume obj=%@",data);
            NSLog(@"resume error=%@",error.localizedDescription);
        }];
    });
}

+ (void) toH5View:(NSString*) url  data:(NSDictionary*) data controller:(UIViewController*) controller {
    NSDictionary *dic = @{
        @"url":url,
        @"passData":@{
            @"data":[NSDictionary convertNull:data]
        }
    };
    WebViewController *webController = [[WebViewController alloc] init];
    if (webController) {
        webController.url = url;
        webController.startupParams = [Tool toJSONString:dic];
        [controller.navigationController pushViewController:webController animated:YES];
    }
}

#pragma mark JSServiceDelegate

- (void) setTitleForWebview:(NSString *)title {
    self.title = title;
}

- (void) setOptionMenuForWebview:(NSString *)title color:(unsigned int)color {
    [self setRightStringButton:@selector(rigthButton:) string:title color:color];
}

- (void) setOptionMenuForWebview:(NSString *)icon {
    [self setRightButton:@selector(rigthButton:) netimg:icon];
}

- (void) pushWindowFromWebview:(UIViewController *)webController {
    if (!webController) {
        return;
    }
    [self.navigationController pushViewController:webController animated:YES];
}

#pragma mark WKNavigationAction

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"WKScriptMessage body= %@",message.body);
    NSLog(@"WKScriptMessage name= %@",message.name);
    if ([message.name isEqualToString:@"JSBridge"]) {
        NSDictionary *dic = message.body;
        NSString *action = [dic valueForKey:@"func"];
        if ([action isEqualToString:@"init"]) {
            if (_startupParams && _startupParams.length > 0) {
                NSString *startupString = [NSString stringWithFormat:@"setStartupParams(%@)",_startupParams];
                [self.webView evaluateJavaScript:startupString completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                    NSLog(@"init obj=%@",obj);
                    NSLog(@"init error=%@",error.localizedDescription);
                }];
            }
            [self setEnvData];
        } else {
            _jsService = [JSService createJSService:dic webview:self];
        }
    }
}

- (NSDictionary *) envdata {
    
    NSDictionary *dic = @{};
    
    return dic;
}

- (void) setEnvData {
    
    NSDictionary *dic = [self envdata];
    [self callHandler:@"setEnvs" data:dic responseCallback:^(id  _Nullable responseData, NSError * _Nullable error) {
            
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    errorPageShow = NO;
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler  API_AVAILABLE(ios(13.0)){
    errorPageShow = NO;
    decisionHandler(WKNavigationActionPolicyAllow,preferences);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationResponse = %@",navigationResponse.response);
    NSString *url = navigationResponse.response.URL.absoluteString;
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    errorPageShow = NO;
    NSLog(@"didStartProvisionalNavigation = %@",navigation);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    errorPageShow = NO;
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation = %@",navigation);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation = %@",error);
    [self loadErrorPage:@"页面加载出错，请稍后重试。" code:error.code];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    errorPageShow = NO;
    NSLog(@"didCommitNavigation = %@",navigation);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    __weak WebViewController *weakself = self;
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (weakself.isRootController) {
            return;
        }
        if (weakself.title) {
            return;
        }
        if (object) {
            weakself.title = object;
        }
    }];
    
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            
    }];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailNavigation = %@",error);
    [self loadErrorPage:@"页面加载出错，请稍后重试。" code:error.code];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"WebViewController didReceiveMemoryWarning");
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self loadErrorPage:@"页面意外终止，请稍后重试。" code:0];
}

- (void) loadErrorPage:(NSString *) tip code:(NSInteger) code {
    if (errorPageShow) {
        return;
    }
    errorPageShow = YES;
    BOOL netError = [NetworkingStatus isNetError:code];
    if (netError) {
        tip = [NSString stringWithFormat:@"%@,请稍后重试。",[NetworkingStatus netErrorTip:code]];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"error_dbx.html" ofType:nil];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    str = [str stringByReplacingOccurrencesOfString:@"&&&&" withString:tip options:NSLiteralSearch range:NSMakeRange(0, str.length)
           ];
    NSString *urlStr = [_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];;
    [self.webView loadHTMLString:str baseURL:[NSURL URLWithString:urlStr]];
}

#pragma mark WKNavigationAction

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView {

}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"runJavaScriptAlertPanelWithMessage message= %@",message);
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {

}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {

}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {

}

- (void) dealloc {
    [self removeJS];
}


@end
