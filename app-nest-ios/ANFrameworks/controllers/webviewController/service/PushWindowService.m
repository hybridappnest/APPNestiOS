//
//  PushWindowService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "PushWindowService.h"
#import "ANFrameworks.h"

@implementation PushWindowService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [PushWindowService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSString *url = [NSString convertNull:[params valueForKey:@"url"]];
        NSString *ecodeStr= [url stringByRemovingPercentEncoding];
        NSDictionary *passData = [NSDictionary convertNull:[params valueForKey:@"passData"]];
        WebViewController *webController = [[WebViewController alloc] initWithParams:[params valueForKey:@"param"]];
        webController.url = ecodeStr;
        webController.delegate = webview;
        NSDictionary *dic = @{@"url":url,@"passData":passData};
        webController.startupParams = [Tool toJSONString:dic];
        [webview pushWindowFromWebview:webController];
    }
}

@end
