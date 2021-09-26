//
//  NSString+Category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Category)

///根据字体大小获取字符串宽高
-(CGSize) textSizeWithFont:(CGFloat) fontSize;

///根据加粗字体大小获取字符串宽高
-(CGSize) textBoldSizeWithFont:(CGFloat) fontSize;

///根据字体大小，和宽度，计算大段文本的高度
-(CGRect) textBoundingRectWithSize:(CGSize) aSize font:(CGFloat) fontSize;

///根据加粗字体大小，和宽度，计算大段文本的高度
-(CGRect) textBoldBoundingRectWithSize:(CGSize) aSize font:(CGFloat) fontSize;

///判断字符串是否为NSNull类型
+(BOOL)isNull:(id)object;

///把NSNull转位@“”
+(NSString*)convertNull:(id)object;

///字符串md5
-(NSString *) md5;

///从字符串中识别出链接
- (NSArray*) getLinks;

@end
