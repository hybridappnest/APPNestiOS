//
//  OptionMenuService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "OptionMenuService.h"
#import "ANFrameworks.h"

@implementation OptionMenuService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [OptionMenuService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSString *title = [params valueForKey:@"title"];
        NSString *icon = [params valueForKey:@"icon"];
        if (title && title.length > 0) {
            NSString *colorString = [params valueForKey:@"color"];
            unsigned color = 0xffffff;
            if (colorString && colorString.length > 0) {
                if ([colorString containsString:@"#"]) {
                    colorString = [colorString substringFromIndex:1];
                }
                if (![colorString containsString:@"0x"]) {
                    colorString = [NSString stringWithFormat:@"0x%@",colorString];
                }
                if (colorString && colorString.length > 0) {
                    color = (unsigned)strtoul([colorString UTF8String],0,16);
                }
            }
            [webview setOptionMenuForWebview:[NSString convertNull:title] color:color];
        } else if (icon && icon.length > 0) {
            [webview setOptionMenuForWebview:[NSString convertNull:icon]];
        }
    }
}

@end
