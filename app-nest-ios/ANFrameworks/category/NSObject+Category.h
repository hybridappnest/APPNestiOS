//
//  NSObject+category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>

@interface NSObject (Category)

///根据类属性名称获取类属性的类型
- (id) getPropertyType:(NSString*) key;

///判断类属性是否数值型
- (BOOL) isNumerical:(NSString*) key;

@end
