//
//  showToastService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "showToastService.h"
#import "ANFrameworks.h"

@implementation showToastService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [showToastService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = [params valueForKey:@"data"];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *content = [NSString convertNull:[NSString stringWithFormat:@"%@",[data valueForKey:@"content"]]];
            NSString *success = [NSString stringWithFormat:@"%@",[data valueForKey:@"success"]];
            if (content && content.length > 0) {
                BOOL flag = NO;
                if (success && success.length > 0 && [success isEqualToString:@"1"]) {
                    flag = YES;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DBXToast showToast:content success:flag];
                });
            }
        }
    }
}

@end
