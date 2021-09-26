//
//  Tool.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "Tool.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <sys/utsname.h>
#import "ANFrameworks.h"
#import "AppDelegate.h"

@implementation Tool

#pragma mark app UI Info
+ (UIWindow*) appKeyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
//            NSLog(@"windowScene = %@",windowScene);
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            } else if (windowScene.activationState == UISceneActivationStateForegroundInactive) {
                for (UIWindow *window in windowScene.windows) {
                    return window;
                }
            }
        }
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
    return nil;
}

+ (UIWindow*) appWindow {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
//            NSLog(@"windowScene = %@",windowScene);
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            } else if (windowScene.activationState == UISceneActivationStateForegroundInactive) {
                for (UIWindow *window in windowScene.windows) {
                    return window;
                }
            }
        }
    } else {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        return app.window;
    }
    return nil;
}

+ (BOOL) isBangs {
    if (@available(iOS 11.0,*)) {
        UIWindow *keyWindow = [Tool appKeyWindow];
        CGFloat height = keyWindow.safeAreaInsets.bottom;
        return (height > 0);
    }
    return  NO;
}

+ (CGFloat) safeAreaBottomHeight {
    if (@available(iOS 11.0,*)) {
        UIWindow *keyWindow = [Tool appKeyWindow];
        CGFloat height = keyWindow.safeAreaInsets.bottom;
        return height;
    }
    return 0;
}

+ (CGFloat) safeAreaTopHeight {
    if (@available(iOS 11.0,*)) {
        UIWindow *keyWindow = [Tool appKeyWindow];
        CGFloat height = keyWindow.safeAreaInsets.top;
        return height;
    }
    return 0;
}

+ (CGFloat) statusBarHeight {
    if (@available(iOS 13.0,*)) {
        UIWindow *keyWindow = [Tool appKeyWindow];
        UIStatusBarManager *statusBarManager = keyWindow.windowScene.statusBarManager;
        return statusBarManager.statusBarFrame.size.height;
    } else {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
}

#pragma mark JSON

+ (NSString *)toJSONString:(id)theData{
    if(theData == nil || [theData isEqual:[NSNull null]] || [theData isKindOfClass:[NSNull class]]){
        return @"";
    }
    NSString *jsonString;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

+ (NSDictionary *)toJSONData:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark File disk
//总磁盘
+ (NSString *)diskTotalSize{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return [self fileSizeToString:freeSpace];
}

//获取可用磁盘容量
+ (NSString *)diskAvailableSize{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return [self fileSizeToString:freeSpace];
}

+ (NSString *)fileSizeToString:(unsigned long long)fileSize{
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)
    {
        return @"0 B";
        
    }else if (fileSize < KB)
    {
        return @"< 1 KB";
        
    }else if (fileSize < MB)
    {
        return [NSString stringWithFormat:@"%.2fK",((CGFloat)fileSize)/KB];
        
    }else if (fileSize < GB)
    {
        return [NSString stringWithFormat:@"%.2fM",((CGFloat)fileSize)/MB];
        
    }else
    {
        return [NSString stringWithFormat:@"%.2fG",((CGFloat)fileSize)/GB];
    }
}

#pragma mark user info format chaeck
+ (BOOL)isMobileNumber:(NSString *)mobileNum{
    
    if (mobileNum.length < 11) {
        return NO;
    }
    NSString *subString = [mobileNum substringToIndex:1];
    if (![subString isEqualToString:@"1"]) {
        return NO;
    }
    subString = [mobileNum substringToIndex:2];
    if ([subString isEqualToString:@"11"] || [subString isEqualToString:@"12"]) {
        return NO;
    }
    
    return YES;
}

+(BOOL)checkIdentityCardNo:(NSString*)cardNo
{
    if (cardNo.length != 18) {
        return  NO;
    }
    
    NSString *region = [NSString stringWithFormat:@"%@",[cardNo substringWithRange:NSMakeRange(0,1)]];
    
    if([region isEqualToString:@"0"] || [region isEqualToString:@"9"])
    {
        return NO;
    }
    //    cardNo = [cardNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int year =0;
    int month = 0;
    int day = 0;
    
//    year = [cardNo substringWithRange:NSMakeRange(6,4)].intValue;
    month = [cardNo substringWithRange:NSMakeRange(10,2)].intValue;
    day = [cardNo substringWithRange:NSMakeRange(12,2)].intValue;
    
    if( (month > 12) || (month < 1) )
    {
        return NO;
    }
    if( (day > 31) || (day < 1) )
    {
        return NO;
    }
    
    NSArray* codeArray = [NSArray arrayWithObjects:@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2", nil];
    NSDictionary* checkCodeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2", nil]  forKeys:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil]];
    
    NSScanner* scan = [NSScanner scannerWithString:[cardNo substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) {
        return NO;
    }
    int sumValue = 0;
    
    for (int i =0; i<17; i++) {
        sumValue+=[[cardNo substringWithRange:NSMakeRange(i , 1) ] intValue]* [[codeArray objectAtIndex:i] intValue];
    }
    
    NSString* strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    
    if ([strlast isEqualToString: [[cardNo substringWithRange:NSMakeRange(17, 1)]uppercaseString]])
    {
        return YES;
    }
    return  NO;
}

+ (BOOL) validateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (BOOL)validatePassword:(NSString *)password{
    NSString *regex = @"[^\u4e00-\u9fa5\\s]";
    NSPredicate *passRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [passRegex evaluateWithObject:password];
}

+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+(BOOL) isAllNumber:(NSString *) string{
    NSString *temp = [string stringByTrimmingCharactersInSet: [NSCharacterSet decimalDigitCharacterSet]];
    if(temp.length > 0){
        return NO;
    }
    return YES;
}

+(NSString *)getIdentityCardSex:(NSString *)numberStr
{
    int sexInt = [[numberStr substringWithRange:NSMakeRange(16,1)] intValue];
    
    if(sexInt%2 == 0) {
        return @"女";
    } else {
        return @"男";
    }
}

+(NSString *)birthdayStrFromIdentityCard:(NSString *)numberStr
{
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    NSString *year = nil;
    NSString *month = nil;
    
    BOOL isAllNumber = YES;
    NSString *day = nil;
    if([numberStr length]<14)
        return result;
    
    //**截取前14位
    NSString *fontNumer = [numberStr substringWithRange:NSMakeRange(0, 13)];
    
    //**检测前14位否全都是数字;
    const char *str = [fontNumer UTF8String];
    const char *p = str;
    while (*p!='\0') {
        if(!(*p>='0'&&*p<='9'))
            isAllNumber = NO;
        p++;
    }
    if(!isAllNumber)
        return result;
    
    year = [numberStr substringWithRange:NSMakeRange(6, 4)];
    month = [numberStr substringWithRange:NSMakeRange(10, 2)];
    day = [numberStr substringWithRange:NSMakeRange(12,2)];
    
    [result appendString:year];
    [result appendString:@"-"];
    [result appendString:month];
    [result appendString:@"-"];
    [result appendString:day];
    return result;
}


#pragma mark sys/app info

+ (NSString *)machineName{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
    
    //    NSLog(@"=== 设备型号 ===  %@",platform);
    //    NSString* phoneNickName = [[UIDevice currentDevice] name];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone12";
    if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone12 Pro max";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

+(NSString *) getIdentifierForVendor{
    NSString *idfv = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"idfv %@",idfv);
    return idfv;
}

#pragma mark H5
+ (NSDictionary *)getUrlParameterWithUrl:(NSString *)url {
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url];
    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm;
}

+ (void) toSetting:(NSString*) title {
    dispatch_async(dispatch_get_main_queue(),^{
       UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertView addAction:cancel];
        
       UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
           NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
           if ([[UIApplication sharedApplication] canOpenURL:appSettings]) {
               if (@available(iOS 10.0, *)) {
                   [[UIApplication sharedApplication] openURL:appSettings options:@{} completionHandler:^(BOOL success) {
                       if (success) {
                           exit(0);
                       }
                   }];
               } else {
                   [[UIApplication sharedApplication] openURL:appSettings];
                   // Fallback on earlier versions
               }
           }
       }];
       [alertView addAction:sure];
       
        UIWindow *window = [Tool appWindow];
       [window.rootViewController presentViewController:alertView animated:true completion:nil];
   });
}

+ (NSString*) unlink {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *baseConfig = [NSDictionary convertNull:[dic valueForKey:@"base"]];
    NSString *unlinkString = [NSString convertNull:[baseConfig valueForKey:@"unlink"]];
    return unlinkString;
}

@end
