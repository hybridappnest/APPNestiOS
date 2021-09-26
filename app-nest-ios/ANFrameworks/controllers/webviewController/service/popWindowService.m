//
//  popWindowService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "popWindowService.h"
#import "ANFrameworks.h"

@implementation popWindowService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [popWindowService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = [params valueForKey:@"data"];
        if (webview.delegate && [webview.delegate respondsToSelector:@selector(resume:)]) {
            WebViewController *controller = (WebViewController*)webview.delegate;
            [controller resume:data];
        }
        [webview back];
    }
}



@end
