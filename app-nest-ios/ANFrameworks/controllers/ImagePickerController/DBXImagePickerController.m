//
//  DBXImagePickerController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "DBXImagePickerController.h"
#import "ANFrameworks.h"

@interface DBXImagePickerController ()

@end

@implementation DBXImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [BaseController backColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void) back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
