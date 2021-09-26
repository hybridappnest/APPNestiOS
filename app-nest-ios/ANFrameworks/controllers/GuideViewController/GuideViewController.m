//
//  GuideViewController.m
//  LeShui
//
//  Created by  on 16/3/21.
//  Copyright © 2016年 com.dcits. All rights reserved.
//

#import "GuideViewController.h"
#import "ANFrameworks.h"

@interface GuideViewController ()<UIScrollViewDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    // Do any additional setup after loading the view.
}

-(void)createUI
{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KSCREENWIDTH, KSCREENHEIGHT)];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(_guideImgNames.count * KSCREENWIDTH, KSCREENHEIGHT);
    scrollView.showsHorizontalScrollIndicator = NO;
    
    for (int i = 0; i < _guideImgNames.count; i++) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*KSCREENWIDTH, 0, KSCREENWIDTH, KSCREENHEIGHT)];
        imgView.image = [UIImage imageNamed:_guideImgNames[i]];
        [scrollView addSubview:imgView];
        
        if (i == _guideImgNames.count - 1) {
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *enterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImg:)];
            [imgView addGestureRecognizer:enterTap];
        }
    }
    
    [self.view addSubview:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x - KSCREENWIDTH * (_guideImgNames.count - 1) == 0) {
        
        RootController *root = [[RootController alloc] init];
        [UIApplication sharedApplication].keyWindow.rootViewController = root;
    }
    
}

- (void)tapImg:(UITapGestureRecognizer *)tap
{
    RootController *root = [[RootController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = root;
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
