//
//  UIApplication+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.
//

#import "UIApplication+Category.h"

@implementation UIApplication (Category)

+ (BOOL)isAllowedNotification {
    //iOS8 check if user allow notification
    if (@available(iOS 8.0, *)) {// system is iOS8
         UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    }
    return NO;
}

@end
