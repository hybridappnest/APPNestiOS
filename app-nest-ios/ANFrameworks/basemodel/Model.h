//
//  Model.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>
#import "ANFrameworks.h"

NS_ASSUME_NONNULL_BEGIN

@interface Model : JSONModel

+(id)parseData:(NSDictionary*) result;

-(void) parseData:(NSDictionary*) result;

@end

NS_ASSUME_NONNULL_END
