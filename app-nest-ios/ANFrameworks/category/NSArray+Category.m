//
//  NSArray+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "NSArray+Category.h"

@implementation NSArray (Category)

+(BOOL)isNull:(id)object
{
    if ([object isEqual:[NSNull null]]) {
        return YES;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else if (object==nil){
        return YES;
    }
    
    return NO;
}

+(NSArray*)convertNull:(id)object
{
    if ([object isEqual:[NSNull null]]) {
        return @[];
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return @[];
    }
    else if (object==nil){
        return @[];
    }
    return object;
}


@end
