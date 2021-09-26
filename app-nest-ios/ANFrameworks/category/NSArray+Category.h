//
//  NSArray+Category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>

@interface NSArray (Category)

+(BOOL)isNull:(id)object;

+(NSArray*)convertNull:(id)object;

@end
