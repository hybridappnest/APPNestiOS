//
//  QRService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "QRService.h"
#import "ANFrameworks.h"

@implementation QRService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [self dealAction:webview message:message];
    }
    return self;
}

- (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    [ScanController openScan:@{@"isPush":@NO,@"delegate":self}];
}

- (void) resultOfScan:(NSString *)value {
    NSDictionary *data = @{@"data":@{@"result":value},@"announce":[NSNumber numberWithInteger:self.announce]};
    if (self.callbackName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.webController) {
                WebViewController *controller = (WebViewController*)self.webController;
                [controller callHandler:self.callbackName data:data responseCallback:^(id responseData,NSError *error) {
                    NSLog(@"%@ 前端收到事件后的回调: %@", self.callbackName,responseData);
                }];
            }
        });
    }
}

@end
