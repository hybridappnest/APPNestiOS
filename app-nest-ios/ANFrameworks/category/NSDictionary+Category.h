//
//  NSDictionary+Category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>

@interface NSDictionary (Category)

+(BOOL)isNull:(id)object;

+(NSDictionary*)convertNull:(id)object;

@end
