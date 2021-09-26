//
//  socialLoginService.h
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "JSService.h"
#import "OneKeyLoginService.h"
#import "WeChatLoginService.h"

NS_ASSUME_NONNULL_BEGIN

@interface socialLoginService : JSService<OneKeyLoginServiceDelegate,WeChatLoginService>

@property (nonatomic,strong) OneKeyLoginService *oneKeyService;

@property (nonatomic,strong) WeChatLoginService *weChatService;

@end

NS_ASSUME_NONNULL_END
