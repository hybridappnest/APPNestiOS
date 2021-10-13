//
//  DBXToast+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/29.
//

#import "DBXToast+Category.h"
#import "ANFrameworks.h"

@implementation DBXToast (Category)

+ (void) showToast:(NSString *)msg success:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(),^{
       UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertView addAction:cancel];
        
       UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
       }];
       [alertView addAction:sure];
       
        UIWindow *window = [Tool appWindow];
       [window.rootViewController presentViewController:alertView animated:true completion:nil];
   });
}

@end
