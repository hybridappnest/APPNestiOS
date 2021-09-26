//
//  JSService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "JSService.h"
#import "ANFrameworks.h"

static NSMutableArray *services;

@implementation JSServiceModel

@end

@implementation JSService

+ (void) initDefaultJSService {
    [JSService registerService:@"setTitle" className:@"TitleService" callback:@""];
    [JSService registerService:@"setOptionMenu" className:@"OptionMenuService" callback:@""];
    [JSService registerService:@"popWindow" className:@"popWindowService" callback:@""];
    [JSService registerService:@"pushWindow" className:@"PushWindowService" callback:@""];
    [JSService registerService:@"popTo" className:@"" callback:@""];
    [JSService registerService:@"showGallery" className:@"showGalleryService" callback:@""];
    [JSService registerService:@"showToast" className:@"showToastService" callback:@""];
    [JSService registerService:@"autolockScreen" className:@"autolockScreenService" callback:@""];
    
    [JSService registerService:@"choseImg" className:@"choseImgService" callback:@"choseImgCallback"];
    [JSService registerService:@"choseFile" className:@"choseFileService" callback:@"choseFileCallback"];
    [JSService registerService:@"upload" className:@"uploadService" callback:@"uploadCallback"];
    [JSService registerService:@"scan" className:@"QRService" callback:@"scanCallback"];
    [JSService registerService:@"socialLogin" className:@"socialLoginService" callback:@"socialLoginCallback"];
}

+ (JSService*) createJSService:(NSDictionary*) message webview:(id) webview {
    
    NSString *action = [message valueForKey:@"func"];
    if ([action isEqualToString:@"postNotification"]) {
        NSDictionary *params = [message valueForKey:@"params"];
        if (params && [params isKindOfClass:[NSDictionary class]]) {
            NSString *notificationName = [params valueForKey:@"name"];
            if ([notificationName containsString:@"_"]) {
                NSArray *array = [notificationName componentsSeparatedByString:@"_"];
                if (array.count > 0) {
                    action = [array objectAtIndex:0];;
                }
            } else {
                action = [params valueForKey:@"name"];
            }
        }
    }
    JSService *service = nil;
    for (NSInteger i = 0; i < services.count; i++) {
        JSServiceModel *model = [services objectAtIndex:i];
        if ([model.funName isEqualToString:action]) {
            if (!(model.className && model.className.length > 0)) {
                return nil;
            }
            Class class = NSClassFromString(model.className);
            service = [[class alloc] initWithWebview:webview message:message model:model];
            return service;
        }
    }
    return service;
}

- (instancetype) initWithWebview:(id)webview message:(NSDictionary *)message model:(JSServiceModel*) model{
    self = [super init];
    if (self) {
        NSString *action = [message valueForKey:@"func"];
        self.funName = action;
        self.callbackName = model.callbackName;
        self.webController = webview;
        NSDictionary *params = [message valueForKey:@"params"];
        if (params && [params isKindOfClass:[NSDictionary class]]) {
            self.announce = [[params valueForKey:@"announce"] integerValue];
        }
    }
    return self;
}

+ (void) registerService:(NSString*) funName className:(NSString*) className callback:(NSString*) callbackName {
    JSServiceModel *model = [[JSServiceModel alloc] init];
    model.funName = funName;
    model.className = className;
    model.callbackName = callbackName;
    if (services == nil) {
        services = [[NSMutableArray alloc] init];
    }
    [services addObject:model];
}

@end
