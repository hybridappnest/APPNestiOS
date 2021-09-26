//
//  OnnKeyLoginService.h
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "JSService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OneKeyLoginServiceDelegate <NSObject>

- (void) result:(NSDictionary*) dic;

@end

@interface OneKeyLoginService : NSObject

@property (nonatomic,weak) id<OneKeyLoginServiceDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
