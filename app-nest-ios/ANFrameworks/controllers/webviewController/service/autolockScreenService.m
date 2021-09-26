//
//  autolockScreenService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "autolockScreenService.h"
#import "ANFrameworks.h"

@implementation autolockScreenService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [autolockScreenService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = [params valueForKey:@"data"];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *autolockValue = [data valueForKey:@"autolock"];
            BOOL autolock = [autolockValue boolValue];
            [UIApplication sharedApplication].idleTimerDisabled = !autolock;
        }
    }
}

@end
