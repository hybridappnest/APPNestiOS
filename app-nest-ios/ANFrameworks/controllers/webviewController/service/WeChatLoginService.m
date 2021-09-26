//
//  WeChatLoginService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "WeChatLoginService.h"
#import "ANFrameworks.h"
#import "WXApi.h"

NSString *const WeChatLoginNotification = @"WeChatLoginNotification";


@implementation WeChatLoginService

- (instancetype) init {
    self = [super init];
    if (self) {
        [self toWechat];
    }
    return self;
}

- (void) toWechat {
    if (![WXApi isWXAppInstalled]) {
        [self weixinTip:@"请先安装微信" cancel:NO];
        return;
    }
    NSString *unlinkString = [Tool unlink];
    if (!(unlinkString && unlinkString.length > 0)) {
        [DBXToast showToast:@"universalLink 没有配置，请到config.plist中配置" success:NO];
        return;
    }
    NSString *wxappIdString = wxappId;
    if (!(wxappIdString && wxappIdString.length > 0)) {
        [DBXToast showToast:@"wxappId 没有配置，请到ANDefine.h中配置" success:NO];
        return;
    }
    NSString *wxscopeString = wxscope;
    if (!(wxscopeString && wxscopeString.length > 0)) {
        [DBXToast showToast:@"wxscope 没有配置，请到ANDefine.h中配置" success:NO];
        return;
    }
    [WXApi registerApp:wxappId universalLink:[Tool unlink]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCallback:) name:WeChatLoginNotification object:nil];
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = wxscope;
    req.state = wxstate;
    [WXApi sendReq:req completion:^(BOOL success) {
    }];
}

- (void) weixinTip:(NSString*) tip cancel:(BOOL) flag  {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:tip preferredStyle:UIAlertControllerStyleAlert];
    if (flag) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                               
        }];
        [alertView addAction:cancel];
    }
    
   
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:sure];
    
    UIViewController *controller = [RootController topController];
    [controller presentViewController:alertView animated:true completion:nil];
}

- (void) loginCallback:(NSNotification*) notification {
    NSUserActivity *userActivity = notification.object;
    if (!userActivity) {
        return;
    }
    if ([userActivity isKindOfClass:[NSURL class]]) {
        NSURL *url = (NSURL*)userActivity;
        [WXApi handleOpenURL:url delegate:self];
    } else if ([userActivity isKindOfClass:[NSUserActivity class]]){
        [WXApi handleOpenUniversalLink:userActivity delegate:self];
    }
}

#pragma mark WXApiDelegate

- (void) onResp:(BaseResp *)resp {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    @try {
        SendAuthResp *suthresp = (SendAuthResp*)resp;
        if (_delegate && [_delegate respondsToSelector:@selector(wecharCallback:)]) {
            [_delegate wecharCallback:suthresp.code];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void) onReq:(BaseReq *)req {
    
}

@end
