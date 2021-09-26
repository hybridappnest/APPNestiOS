//
//  UIColor+category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "UIColor+Category.h"

@implementation UIColor (Category)

+(nullable UIColor*)colorWithInt:(unsigned)colorValue;
{
    unsigned r = (colorValue&0x00ff0000)>>16;
    unsigned g = (colorValue&0x0000ff00)>>8;
    unsigned b = colorValue&0x000000ff;
    UIColor* color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    return color;
}

+(nullable UIColor*)colorWithInt:(unsigned)colorValue alpha:(CGFloat) a
{
    unsigned r = (colorValue&0x00ff0000)>>16;
    unsigned g = (colorValue&0x0000ff00)>>8;
    unsigned b = colorValue&0x000000ff;
    UIColor* color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
    return color;
}

+ (nullable UIColor *)colorFromHexString:(nullable NSString *)hexString {
    unsigned colorValue = (unsigned)strtoul([hexString UTF8String],0,16);
    unsigned r = (colorValue&0x00ff0000)>>16;
    unsigned g = (colorValue&0x0000ff00)>>8;
    unsigned b = colorValue&0x000000ff;
    UIColor* color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    return color;
}

+ (nullable UIColor *)colorFromHexString:(nullable NSString *)hexString alpha:(CGFloat)alpha {
    unsigned colorValue = (unsigned)strtoul([hexString UTF8String],0,16);
    unsigned r = (colorValue&0x00ff0000)>>16;
    unsigned g = (colorValue&0x0000ff00)>>8;
    unsigned b = colorValue&0x000000ff;
    UIColor* color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
    return color;
}

//+ (UIColor*) whiteColor {
//    return [UIColor colorWithInt:0xfefffe];
//}

@end
