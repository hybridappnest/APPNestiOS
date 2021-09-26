//
//  Tool.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tool : NSObject

///判断是否为刘海屏
+ (BOOL) isBangs;

///获取app当前keyWindow
+ (UIWindow*) appKeyWindow;

///获取app根window
+ (UIWindow*) appWindow;

///获取app状态栏高度
+ (CGFloat) statusBarHeight;

///获取安全区底部高度
+ (CGFloat) safeAreaBottomHeight;

///获取安全区顶部高度
+ (CGFloat) safeAreaTopHeight;

///JSON转字符串
+ (NSString *) toJSONString:(id)theData;

///字符串转JSON
+ (NSDictionary *)toJSONData:(NSString *)jsonString;

///获取磁盘总大小
+ (NSString *) diskTotalSize;

///获取磁盘可用大小
+ (NSString *) diskAvailableSize;

///把磁盘字节大小格式化为字符串 如：320M
+ (NSString *) fileSizeToString:(unsigned long long)fileSize;

///校验手机号码格式
+(BOOL) isMobileNumber:(NSString *)mobileNum;

///校验身份证号码格式
+(BOOL)checkIdentityCardNo:(NSString*)cardNo;

///校验邮箱格式
+ (BOOL) validateEmail:(NSString *)email;

///校验密码格式
+ (BOOL) validatePassword:(NSString *)password;

///获取手机型号
+ (NSString *)machineName;

///判断一串字符串是否是数字
+(BOOL)isPureInt:(NSString *)string;
+(BOOL)isAllNumber:(NSString *)string;

///获取app唯一标识
+(NSString *) getIdentifierForVendor;

///获取url中的参数
+ (NSDictionary *)getUrlParameterWithUrl:(NSString *)url;

+ (void) toSetting:(NSString*) title;

+ (NSString*) unlink;


@end
