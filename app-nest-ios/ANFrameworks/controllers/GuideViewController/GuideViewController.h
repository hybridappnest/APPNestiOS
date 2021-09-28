//
//  GuideViewController.h
//  app-nest-ios
//
//  Created by brent on 2021/9/27.
//

#import "BaseController.h"

#define kFirstStartFlag @"kFirstStartFlag"  //程序第一次启动的标识

@interface GuideViewController : UIViewController

@property (nonatomic, strong) NSArray *guideImgNames;

@property (nonatomic,strong) UIPageControl *pageControl;

@end
