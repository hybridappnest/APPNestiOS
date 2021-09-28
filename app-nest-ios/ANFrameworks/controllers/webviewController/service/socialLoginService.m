//
//  socialLoginService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "socialLoginService.h"
#import "ANFrameworks.h"



@implementation socialLoginService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [self dealAction:webview message:message];
    }
    return self;
}

- (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
//    __weak uploadService *weakself = self;
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSArray *data = [params valueForKey:@"data"];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *channel = [NSString convertNull:[data valueForKey:@"channel"]];
            if ([channel isEqualToString:@"phone"]) {
                [self toOneKeyLogin];
            } else if ([channel isEqualToString:@"wechat"]) {
                [self toWeChat];
            }
        }
    }
}

- (void) toWeChat {
    _weChatService = [[WeChatLoginService alloc] init];
    _weChatService.delegate = self;
}

- (void) toOneKeyLogin {
    _oneKeyService = [[OneKeyLoginService alloc] init];
    _oneKeyService.delegate = self;
}

- (void) result:(NSDictionary *)dic  {
    __weak socialLoginService *weakself = self;
    NSString *token = [dic valueForKey:@"token"];
    NSDictionary *data = @{@"data":@{@"channel":@"phone",@"status":@2,@"token":token},@"announce":[NSNumber numberWithInteger:self.announce]};
    if (!(self.callbackName && self.callbackName.length > 0)) {
        NSLog(@"没有定义回调事件");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakself && weakself.webController) {
            WebViewController *controller = (WebViewController*)weakself.webController;
            [controller callHandler:weakself.callbackName data:data responseCallback:^(id responseData,NSError *error) {
                NSLog(@"%@ 前端收到事件后的回调: %@", weakself.callbackName,responseData);
            }];
        }
    });
}

- (void) wecharCallback:(NSString *)code {
    __weak socialLoginService *weakself = self;
    NSDictionary *data = @{@"data":@{@"channel":@"wechat",@"status":@2,@"token":code},@"announce":[NSNumber numberWithInteger:self.announce]};
    if (!(self.callbackName && self.callbackName.length > 0)) {
        NSLog(@"没有定义回调事件");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakself && weakself.webController) {
            WebViewController *controller = (WebViewController*)weakself.webController;
            [controller callHandler:weakself.callbackName data:data responseCallback:^(id responseData,NSError *error) {
                NSLog(@"%@ 前端收到事件后的回调: %@", weakself.callbackName,responseData);
            }];
        }
    });
}

- (void) callback:(NSArray* _Nonnull) urls {
    
}


@end
