//
//  NSDate+Category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Category)

///通过日期字符串生成日期
+ (NSDate *)stringToDate:(NSString *)strdate;

///通过日期字符串生成时间戳
+ (NSTimeInterval)stringToTimestamp:(NSString *)strdate;

///时间戳转成日期字符串
+ (NSString *)timestampToString:(NSInteger)timestamp;

///日期转字符串，类似：昨天 00:00，
+ (NSString *)dateToStringForMsg:(NSDate *)strdate;

///日期转字符串
+ (NSString *)dateToString:(NSDate *)date;

///毫秒转化为小时分秒字符串
+ (NSString*) formatSecondsToDateString:(NSInteger)milliseconds;

///时间戳转字符串，描述给定时间戳距离当前时间的间隔，类似 1天前，20小时前
+ (NSString*) formatSecondsToString:(NSInteger)milliseconds;


@end

NS_ASSUME_NONNULL_END
