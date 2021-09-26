//
//  DBXToast.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "DBXToast.h"
#import "ANFrameworks.h"

@implementation DBXToast {
    CGFloat labelWidth;
}

-(id) initWithFrame:(CGRect)frame msg:(NSString*) msg success:(BOOL) success {
    self = [super initWithFrame:frame];
    if(self){
        UIWindow *window = [Tool appKeyWindow];
        self.frame = window.bounds;
        _alaphView = [[UIView alloc] initWithFrame:window.bounds];
        _alaphView.backgroundColor = [UIColor blackColor];
        _alaphView.alpha = 0.0;
        [self addSubview:_alaphView];
        
        UIImage *backImage = [UIImage imageNamed:@"bg_custom_toast"];
        CGFloat backWidth = backImage.size.width;
        labelWidth = backWidth - 10 * 2;
        CGRect rect = [msg textBoundingRectWithSize:CGSizeMake(labelWidth, 1000) font:18];
        NSString *imageName = @"icon_custom_toast_fail";
        if (success) {
            imageName = @"icon_custom_success";
        }
        UIImage *image = [UIImage imageNamed:imageName];
        CGFloat height = 39 + image.size.height + 29 + rect.size.height + 12 + 37;
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backWidth, height)];
        _backView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 3);
//        _backView.backgroundColor = [UIColor whiteColor];
//        _backView.layer.cornerRadius = 10.0;
        [self addSubview:_backView];
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _backView.frame.size.width, _backView.frame.size.height)];
        backImageView.image = backImage;
        [_backView addSubview:backImageView];
        
        [self createView:msg success:success];
        
//        [_alaphView registerControlBack:self selector:@"hideView"];
    }
    return self;
}

- (void) createView:(NSString*) data success:(BOOL) success {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 38, _backView.frame.size.width, 166)];
//    view.backgroundColor = [UIColor whiteColor];
//    [_backView addSubview:view];
    
    NSString *imageName = @"icon_custom_toast_fail";
    if (success) {
        imageName = @"icon_custom_success";
    }
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_backView.frame.size.width - image.size.width)/2, 39, image.size.width, image.size.height)];
    imageView.image = image;
    [_backView addSubview:imageView];
    
    CGFloat width = labelWidth;
    CGFloat titleFont = 18;
    CGRect rect = [data textBoundingRectWithSize:CGSizeMake(width, 1000) font:titleFont];
    
    UIImage *lineImage = [UIImage imageNamed:@"icon_custom_toast_line"];
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, imageView.frame.size.height + imageView.frame.origin.y + 29,width, rect.size.height + 12)];
    lineView.image = lineImage;
    [_backView addSubview:lineView];

    CGSize size = [data textSizeWithFont:titleFont];
    if (bold) {
        size = [data textBoldSizeWithFont:titleFont];
    }
    CGRect frame = CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = data;
    label.font = [UIFont systemFontOfSize:titleFont];
    label.textColor = [UIColor colorFromHexString:@"1DEBFF"];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, lineView.frame.size.width, lineView.frame.size.height);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    [lineView addSubview:label];
}

+ (void) showToast:(NSString*) msg  success:(BOOL) success {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [Tool appKeyWindow];
        DBXToast *toast = [[DBXToast alloc] initWithFrame:window.bounds msg:msg success:success];
        
        [toast showView];
    });
}

- (void)showView {
    UIWindow *window = [Tool appKeyWindow];
    [window addSubview:self];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    _alaphView.alpha = 0.7f;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    //popAnimation.delegate = self;
    [_backView.layer addAnimation:popAnimation forKey:nil];
    [self performSelector:@selector(disappear) withObject:nil afterDelay:2.0];
}

- (void) disappear{
    [UIView beginAnimations:@"HideArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.0];
//    [UIView setAnimationDelay:1.0];
    self.alpha = 0.0;
    [UIView commitAnimations];
    [self performSelector:@selector(removeView) withObject:nil afterDelay:2.0];
}

- (void) removeView{
    [self removeFromSuperview];
}


@end
