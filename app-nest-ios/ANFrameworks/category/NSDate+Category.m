//
//  NSDate+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "NSDate+Category.h"

@implementation NSDate (Category)

+ (NSDate *)stringToDate:(NSString *)strdate
{
    NSString *string = strdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([strdate containsString:@"T"]) {
        string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        if (![string containsString:@" +"]) {
            string = [string stringByReplacingOccurrencesOfString:@"+" withString:@" +"];
        }
    }
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.S zzz"];
//    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
//    [dateFormatter setTimeZone:localTimeZone];
    NSDate *retdate = [dateFormatter dateFromString:string];
    return retdate;
}

+ (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *string = [dateFormatter stringFromDate:date];
    
    return string;
}

+ (NSTimeInterval)stringToTimestamp:(NSString *)strdate
{
    NSString *string = strdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([strdate containsString:@"T"]) {
        string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        if (![string containsString:@" +"]) {
            string = [string stringByReplacingOccurrencesOfString:@"+" withString:@" +"];
        }
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.S zzz"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *retdate = [dateFormatter dateFromString:string];
    return [retdate timeIntervalSince1970];
}

+ (NSString*)dateToStringForMsg:(NSDate *)strdate
{
    NSDate *nowDate = [NSDate date];
//    NSTimeInterval now = nowDate.timeIntervalSince1970;
//    NSTimeInterval time  = strdate.timeIntervalSince1970;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    BOOL flag = NO;
    NSString *temp = @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday;
    
    NSDateComponents *components = [calendar components:calendarUnit fromDate:nowDate];
    NSInteger day = components.day;
    
    NSDateComponents *componentsIn = [calendar components:calendarUnit fromDate:strdate];
    
    NSInteger inDay = componentsIn.day;
    NSTimeInterval difference = day - inDay;
//    if (difference <= 60 * 60 * 24 * 2) {
    if (components.month - componentsIn.month == 0) {
        if (difference <= 1) {
            flag = YES;
            temp = @"昨天";
            [dateFormatter setDateFormat:@"HH:mm"];
        }
    //    if (difference <= 60 * 60 * 24) {
        if (difference <= 0) {
            flag = YES;
            temp = @"";
            [dateFormatter setDateFormat:@"HH:mm"];
        }
    }
    NSString *string = [dateFormatter stringFromDate:strdate];
    if (flag) {
        string = [NSString stringWithFormat:@"%@ %@",temp,string];
    }
    
    return string;
}

+ (NSString *)timestampToString:(NSInteger)timestamp{
    
    NSInteger theTimestamp = timestamp;
    NSString *timestampString = [NSString stringWithFormat:@"%ld",(long)timestamp];
    NSInteger now = [NSDate date].timeIntervalSince1970;
    NSString *nowString = [NSString stringWithFormat:@"%ld",now];
    if (timestampString.length - nowString.length >= 3) {
        theTimestamp = theTimestamp / 1000;
    }

    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:theTimestamp];

    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];

    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString* string=[dateFormat stringFromDate:confromTimesp];

    return string;
}

+ (NSString *)formatSecondsToDateString:(NSInteger)milliseconds{
    NSString *hhmmss = nil;
    if (milliseconds < 0) {
        return @"00:00";
    }
    int h = (int)round((milliseconds%86400)/3600);
    int m = (int)round((milliseconds%3600)/60);
    int s = (int)round(milliseconds%60);
    //%02d  如果数据不够两位数补0
    
    if (h==0) {
        hhmmss = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }else {
        hhmmss = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    }
    return hhmmss;
}

+ (NSString*) formatSecondsToString:(NSInteger) time {
    NSInteger theTimestamp = time;
    NSInteger now = [NSDate date].timeIntervalSince1970;
    NSString *timestampString = [NSString stringWithFormat:@"%ld",theTimestamp];
    NSString *nowString = [NSString stringWithFormat:@"%ld",now];
    if (timestampString.length - nowString.length >= 3) {
        theTimestamp = theTimestamp / 1000;
    }
    NSInteger seconds = now - theTimestamp;
    if (seconds < 0) {
        return @"0秒钟前";
    }
    int d = (int)round((seconds/86400));
    if (d > 0) {
        return [NSString stringWithFormat:@"%d天前",d];
    }
    int h = (int)round((seconds%86400)/3600);
    if (h > 0) {
        return [NSString stringWithFormat:@"%d小时前",h];
    }
    int m = (int)round((seconds%3600)/60);
    if (m > 0) {
        return [NSString stringWithFormat:@"%d分钟前",m];
    }
    int s = (int)round(seconds%60);
    if (s > 0) {
        return [NSString stringWithFormat:@"%d秒钟前",s];
    }
    
    return @"0秒钟前";
}

@end
