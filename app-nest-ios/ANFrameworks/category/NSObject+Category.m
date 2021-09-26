//
//  NSObject+category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "NSObject+Category.h"
#import <objc/runtime.h>

@implementation NSObject (Category)

- (id) getPropertyType:(NSString*) key {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    BOOL foundKey = NO;
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
        if ([propName isEqualToString:key]) {
            foundKey = YES;
            NSString *propAttrName = [NSString stringWithUTF8String:property_getAttributes(property)];
            if ([propAttrName containsString:@"String"]) {
                free(properties);
                return @"";
            }
            if ([propAttrName containsString:@"Array"]) {
                free(properties);
                return @[];
            }
            if ([propAttrName containsString:@"Dictionary"]) {
                free(properties);
                return @{};
            }
        }
    }
    free(properties);
    if (!foundKey) {
        return [self getSuperPropertyType:key];
    }
    return nil;
}

- (id) getSuperPropertyType:(NSString*) key {
    unsigned int outCount, i;
    Class cls = [self class];
    Class supercls = class_getSuperclass(cls);
    objc_property_t *properties = class_copyPropertyList(supercls, &outCount);
    BOOL foundKey = NO;
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
        if ([propName isEqualToString:key]) {
            foundKey = YES;
            NSString *propAttrName = [NSString stringWithUTF8String:property_getAttributes(property)];
            if ([propAttrName containsString:@"String"]) {
                free(properties);
                return @"";
            }
            if ([propAttrName containsString:@"Array"]) {
                free(properties);
                return @[];
            }
            if ([propAttrName containsString:@"Dictionary"]) {
                free(properties);
                return @{};
            }
        }
    }
    free(properties);
    return nil;
}

- (BOOL) isNumerical:(NSString*) key {
    BOOL flag = NO;
    Class cls = [self class];
    flag = [self checkKeyIsNumerical:key class:cls];
    if (!flag) {
        cls = class_getSuperclass(cls);
        flag = [self checkKeyIsNumerical:key class:cls];
    }
    return flag;
}

- (BOOL) checkKeyIsNumerical:(NSString*) key class:(Class) cls {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
        if ([propName isEqualToString:key]) {
            NSString *propAttrName = [NSString stringWithUTF8String:property_getAttributes(property)];
//            NSLog(@"propAttrName=%@",propAttrName);
            if ([propAttrName containsString:@"Td,N"] || [propAttrName containsString:@"Tq,N"] || [propAttrName containsString:@"TB,N"]) {
                free(properties);
                return YES;
            }
        }
    }
    free(properties);
    return NO;
}


@end
