//
//  NetworkingStatus.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXTERN NSString *const NetConnectionNotification;

@interface NetworkingStatus : NSObject

+(BOOL) isNetError:(NSInteger) code;

+(NSString*) netErrorTip:(NSInteger) code;

+ (NSInteger) networkStatus;

+ (void)startMonitoring;

@end

NS_ASSUME_NONNULL_END
