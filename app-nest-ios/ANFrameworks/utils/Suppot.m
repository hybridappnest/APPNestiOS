//
//  Suppot.m
//  app-nest-ios
//
//  Created by brent on 2021/9/27.
//

#import "Suppot.h"
#import "ANFrameworks.h"
#import <UserNotifications/UNUserNotificationCenter.h>

@implementation Suppot

+ (UIViewController*) createRootController:(NSArray* _Nullable) guideImgNames guide:(BOOL) show {
    if (guideImgNames.count > 0 && show) {
        GuideViewController *rootController = [[GuideViewController alloc] init];
        rootController.guideImgNames = guideImgNames;
        return rootController;
    }
    RootController *rootController = [[RootController alloc] init];
    return rootController;
}

+ (void)registNotification:(id) appDelegate {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = appDelegate;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert |UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"registNotification=%@",error);
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                });
            }
        }];
    } else if (@available(iOS 8.0, *)) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

@end
