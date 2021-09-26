//
//  TitleService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "TitleService.h"
#import "ANFrameworks.h"

@implementation TitleService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [TitleService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        webview.title = [NSString convertNull:[params valueForKey:@"title"]];
    }
}

@end
