//
//  RootController.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const NOLoginNotification;

@interface RootController : UITabBarController

@property(nonatomic,strong)NSMutableArray *buttons;

@property(nonatomic,assign)NSInteger beforeLoginIndex;


+ (UIViewController*) topController;

+ (UIViewController*) rootController;

- (void) switchController:(NSInteger) index;


@end
