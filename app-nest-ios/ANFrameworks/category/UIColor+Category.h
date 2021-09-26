//
//  UIColor+category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <UIKit/UIKit.h>

@interface UIColor (Category)

+ (nullable UIColor*)colorWithInt:(unsigned)colorValue;

+ (nullable UIColor*)colorWithInt:(unsigned)colorValue alpha:(CGFloat) a;

+ (nullable UIColor *)colorFromHexString:(nullable NSString *)hexString;

+ (nullable UIColor *)colorFromHexString:(nullable NSString *)hexString alpha:(CGFloat)alpha;
@end
