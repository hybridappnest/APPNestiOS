//
//  WeChatLoginService.h
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "JSService.h"
#import "WXApi.h"

@protocol WeChatLoginService <NSObject>

- (void) wecharCallback:(NSString*) code;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WeChatLoginService : JSService<WXApiDelegate>

@property (nonatomic,weak) id <WeChatLoginService> delegate;

@end

NS_ASSUME_NONNULL_END
