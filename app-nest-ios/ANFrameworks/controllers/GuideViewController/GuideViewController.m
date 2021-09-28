//
//  GuideViewController.m
//  app-nest-ios
//
//  Created by brent on 2021/9/27.
//

#import "GuideViewController.h"
#import "ANFrameworks.h"

typedef enum : NSUInteger {
    type_none,
    type_left,
    type_right
} Direction;

@interface GuideViewController ()<UIScrollViewDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    [self createUI];
    // Do any additional setup after loading the view.
    
//    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 200, 40, 50)];
//    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
//    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//    _pageControl.currentPage = 1;
//    _pageControl.numberOfPages = 3;
//    [self.view addSubview:_pageControl];
}

-(void)createUI
{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KSCREENWIDTH, KSCREENHEIGHT)];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(_guideImgNames.count * KSCREENWIDTH, KSCREENHEIGHT);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    
    for (int i = 0; i < _guideImgNames.count; i++) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*KSCREENWIDTH, 0, KSCREENWIDTH, KSCREENHEIGHT)];
        imgView.image = [UIImage imageNamed:_guideImgNames[i]];
        [scrollView addSubview:imgView];
        
        if (i == _guideImgNames.count - 1) {
            imgView.userInteractionEnabled = YES;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0,imgView.frame.size.height - 45 - 50 , imgView.frame.size.width / 2, 45);
            button.layer.cornerRadius = button.frame.size.height / 2;
            button.backgroundColor = [UIColor whiteColor];
            button.alpha = 0.5;
            [button setTitle:@"立即使用" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.center = CGPointMake(imgView.frame.size.width / 2, button.center.y);
            [button addTarget:self action:@selector(dealButton:) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:button];
//            imgView.userInteractionEnabled = YES;
//            UITapGestureRecognizer *enterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImg:)];
//            [imgView addGestureRecognizer:enterTap];
        }
    }
    
    [self.view addSubview:scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, KSCREENHEIGHT - 30, KSCREENWIDTH, 20)];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithInt:0xffffff alpha:0.5];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = _guideImgNames.count;
    [self.view addSubview:_pageControl];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    if (scrollView.contentOffset.x - KSCREENWIDTH * (_guideImgNames.count - 1) == 0) {
//
//        RootController *root = [[RootController alloc] init];
//        [UIApplication sharedApplication].keyWindow.rootViewController = root;
//    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self changePage:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self changePage:scrollView];
}

- (void) changePage:(UIScrollView*) scrollView{
    NSInteger index = scrollView.contentOffset.x / KSCREENWIDTH;
//    Direction direction = type_none;
//    if (index - 1 > _pageControl.currentPage) {
//        direction = type_right;
//    }
    _pageControl.currentPage = index - 1;
//    if (direction == type_right && index == _guideImgNames.count) {
//        RootController *root = [[RootController alloc] init];
//        [UIApplication sharedApplication].keyWindow.rootViewController = root;
//    }
}

- (void) dealButton:(UIButton*) button {
    RootController *root = [[RootController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = root;
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
