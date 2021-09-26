//
//  OnnKeyLoginService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/22.
//

#import "OneKeyLoginService.h"
#import "ANFrameworks.h"
#import <ATAuthSDK/ATAuthSDK.h>

#define TX_Alert_NAV_BAR_HEIGHT      55.0
#define TX_Alert_HORIZONTAL_NAV_BAR_HEIGHT      41.0

//竖屏弹窗
#define TX_Alert_Default_Left_Padding         42
#define TX_Alert_Default_Top_Padding          115

/**横屏弹窗*/
#define TX_Alert_Horizontal_Default_Left_Padding      80.0

@implementation OneKeyLoginService

- (instancetype) init {
    self = [super init];
    if (self) {
        [self toOneKeyLogin];
    }
    return self;
}

- (void) toOneKeyLogin {
    NSString *PNSAuthString = PNSAuth;
    if (!(PNSAuthString && PNSAuthString.length > 0)) {
        [DBXToast showToast:@"PNSAuth 没有配置，请到ANDefine.h中配置" success:NO];
        return;
    }
    [[TXCommonHandler sharedInstance] setAuthSDKInfo:PNSAuth complete:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"resultDic=%@",resultDic);
        [[TXCommonHandler sharedInstance] checkEnvAvailableWithAuthType:PNSAuthTypeLoginToken complete:^(NSDictionary * _Nullable resultDic) {
            NSLog(@"resultDic=%@",resultDic);
            
            NSString *resultCodeString = [NSString stringWithFormat:@"%@",[resultDic valueForKey:@"resultCode"]];
            NSInteger resultCode = [resultCodeString integerValue];
            if (resultCode == 600000) {
                [[TXCommonHandler sharedInstance] accelerateLoginPageWithTimeout:86400 complete:^(NSDictionary * _Nonnull resultDic) {
                    NSLog(@"resultDic=%@",resultDic);
                    NSString *resultCodeString = [NSString stringWithFormat:@"%@",[resultDic valueForKey:@"resultCode"]];
                    NSInteger resultCode = [resultCodeString integerValue];
                    if (resultCode == 600000) {
                        [self showOneKeyLogin];
                    } else {
                        NSString *msg = [self tip:resultCode];
                        [DBXToast showToast:msg success:NO];
                    }
                }];
            } else {
                NSString *msg = [self tip:resultCode];
                [DBXToast showToast:msg success:NO];
            }
        }];
    }];
}

- (void) showOneKeyLogin {
    UIViewController *controller = [RootController topController];
    TXCustomModel *model = [self createCustomModel];
    __weak OneKeyLoginService *weakself = self;
    [[TXCommonHandler sharedInstance] getLoginTokenWithTimeout:86400 controller:controller model:model complete:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"resultDic=%@",resultDic);
        NSString *resultCodeString = [NSString stringWithFormat:@"%@",[resultDic valueForKey:@"resultCode"]];
        NSInteger resultCode = [resultCodeString integerValue];
        if (resultCode == 700001) {
            [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:^{
               
            }];
        } else if (resultCode == 700004 || resultCode == 700000 || resultCode == 700002 || resultCode == 700003 || resultCode == 600001) {
//                NSString *url = [resultDic valueForKey:@"isChecked"];
        } else if (resultCode == 600000) {
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(result:)]) {
                [weakself.delegate result:resultDic];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:NO complete:^{
                }];
            });
        } else{
            NSString *msg = [self tip:resultCode];
            [DBXToast showToast:msg success:NO];
        }
    }];
}

- (NSString *) tip:(NSInteger) code{
    NSString *string = nil;
    if (code == 600002) {
        string = @"唤起授权页失败";
    }
    if (code == 600004) {
        string = @"获取运营商配置信息失败";
    }
    if (code == 600007) {
        string = @"未检测到sim卡";
    }
    if (code == 600008) {
        string = @"蜂窝网络未开启";
    }
    if (code == 600009) {
        string = @"无法判断运营商";
    }
    if (code == 600010) {
        string = @"未知异常";
    }
    if (code == 600011) {
        string = @"获取token失败";
    }
    if (code == 600012) {
        string = @"预取号失败";
    }
    if (code == 600013) {
        string = @"运营商维护升级，该功能不可用";
    }
    if (code == 600014) {
        string = @"运营商维护升级，该功能不可用";
    }
    if (code == 600015) {
        string = @"一键登陆请求超时";
    }
    if (string && string.length > 0) {
        string = [NSString stringWithFormat:@"%@,请使用其他登陆方式登录",string];
    }
    return  string;
}

- (TXCustomModel*) createCustomModel {
    __weak OneKeyLoginService *weakself = self;
    TXCustomModel *model = [[TXCustomModel alloc] init];
    model.alertCornerRadiusArray = @[@10, @10, @10, @10];
    //model.alertCloseItemIsHidden = YES;
    model.alertTitleBarColor = [UIColor whiteColor];
    model.alertTitle = [[NSAttributedString alloc] initWithString:@"一键登录" attributes:@{NSForegroundColorAttributeName : UIColor.blackColor, NSFontAttributeName : [UIFont systemFontOfSize:12.0]}];
    model.alertCloseImage = [UIImage imageNamed:@"icon_close_light"];
    
    model.privacyNavColor = [UIColor colorFromHexString:@"0B297E"];
    model.privacyNavBackImage = [UIImage imageNamed:@"back"];
//    model.privacyNavTitleFont = [UIFont LDFontOfSize:20.0];
    model.privacyNavTitleColor = UIColor.whiteColor;
    
    model.logoImage = [UIImage imageNamed:@"icon_setting_about_logo"];
    //model.logoIsHidden = NO;
    //model.sloganIsHidden = NO;
    model.sloganText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@提供认证服务",[TXCommonUtils getCurrentCarrierName]] attributes:@{NSForegroundColorAttributeName : [UIColor colorFromHexString:@"333333"],NSFontAttributeName : [UIFont systemFontOfSize:11.0]}];
    model.numberColor = [UIColor colorFromHexString:@"333333"];
    model.numberFont = [UIFont systemFontOfSize:17.0];
    model.loginBtnText = [[NSAttributedString alloc] initWithString:@"一键登录" attributes:@{NSForegroundColorAttributeName : UIColor.whiteColor, NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    NSArray *backImage = @[[self oneKeyBack],[self oneKeyBackNot],[self oneKeyBack]];
    model.loginBtnBgImgs = backImage;
    //model.autoHideLoginLoading = NO;
    //model.privacyOne = @[@"《隐私1》",@"https://www.taobao.com/"];
    //model.privacyTwo = @[@"《隐私2》",@"https://www.taobao.com/"];
    model.privacyColors = @[UIColor.lightGrayColor, [UIColor colorFromHexString:@"333333"]];
    model.privacyAlignment = NSTextAlignmentCenter;
    model.privacyFont = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0];
    model.privacyOperatorPreText = @"《";
    model.privacyOperatorSufText = @"》";
    model.checkBoxIsChecked = YES;
    model.checkBoxWH = 17.0;
    model.changeBtnTitle = [[NSAttributedString alloc] initWithString:@"切换到其他方式" attributes:@{NSForegroundColorAttributeName : [UIColor colorFromHexString:@"333333"],NSFontAttributeName : [UIFont systemFontOfSize:11.0]}];
    model.changeBtnIsHidden = NO;
    //model.prefersStatusBarHidden = NO;
    //model.preferredStatusBarStyle = UIStatusBarStyleDefault;
    //model.presentDirection = PNSPresentationDirectionBottom;
    
    CGFloat ratio = MAX(KSCREENWIDTH, KSCREENHEIGHT) / 667.0;
    
    //实现该block，并且返回的frame的x或y大于0，则认为是弹窗谈起授权页
    model.contentViewFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        CGFloat alertX = 0;
        CGFloat alertY = 0;
        CGFloat alertWidth = 0;
        CGFloat alertHeight = 0;
        if ([weakself isHorizontal:screenSize]) {
            alertX = ratio * TX_Alert_Horizontal_Default_Left_Padding;
            alertWidth = screenSize.width - alertX * 2;
            alertY = (screenSize.height - alertWidth * 0.5) * 0.5;
            alertHeight = screenSize.height - 2 * alertY;
        } else {
            alertX = TX_Alert_Default_Left_Padding * ratio;
            alertWidth = screenSize.width - alertX * 2;
            alertY = TX_Alert_Default_Top_Padding * ratio;
            alertHeight = screenSize.height - alertY * 2.9;
        }
        return CGRectMake(alertX, alertY, alertWidth, alertHeight);
    };
    
    //授权页默认控件布局调整
    //model.alertTitleBarFrameBlock =
    //model.alertTitleFrameBlock =
    //model.alertCloseItemFrameBlock =
    model.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([weakself isHorizontal:screenSize]) {
            return CGRectZero; //横屏时模拟隐藏该控件
        } else {
            frame.origin.y = 10;
            frame.size.width = frame.size.width / 1.3;
            frame.size.height =  frame.size.height / 1.3;
            frame.origin.x = (superViewSize.width - frame.size.width) / 2;
            return frame;
        }
    };
    model.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([weakself isHorizontal:screenSize]) {
            return CGRectZero; //横屏时模拟隐藏该控件
        } else {
            frame.origin.y = 110;
            return frame;
        }
    };
    model.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([weakself isHorizontal:screenSize]) {
            frame.origin.y = 20;
            frame.origin.x = (superViewSize.width * 0.5 - frame.size.width) * 0.5 + 18.0;
        } else {
            frame.origin.y = 140;
        }
        return frame;
    };
    model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([weakself isHorizontal:screenSize]) {
            frame.origin.y = 60;
            frame.size.width = superViewSize.width * 0.5; //登录按钮最小宽度是其父视图的一半，再小就不生效了
        } else {
            frame.origin.y = 180;
        }
        return frame;
    };
    model.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([weakself isHorizontal:screenSize]) {
            return CGRectZero; //横屏时模拟隐藏该控件
        } else {
//            return CGRectMake(10, 240, superViewSize.width - 20, 30);
            return CGRectZero;
        }
    };
    return model;
}

/// 是否是横屏 YES:横屏 NO:竖屏
- (BOOL)isHorizontal:(CGSize)size {
    return size.width > size.height;
}

- (UIImage*) oneKeyBackNot {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 325, 50)];
    view.backgroundColor = [UIColor colorFromHexString:@"e5e5e5"];
    view.layer.cornerRadius = view.frame.size.height / 2;
    view.layer.masksToBounds = YES;
    UIImage *image = [UIImage imageWithView:view];
    return image;
}

- (UIImage*) oneKeyBack {
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, 325, 54);
    view.alpha = 1;
    // Background Code
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = view.bounds;
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 0);
    gl.colors = @[
    (__bridge id)[UIColor colorWithRed:0/255.0 green:222/255.0 blue:255/255.0 alpha:1.0].CGColor,
    (__bridge id)[UIColor colorWithRed:1/255.0 green:112/255.0 blue:210/255.0 alpha:1.0].CGColor,
    ];
//    gl.locations = @[@(0),@(1)];
    [view.layer addSublayer:gl];
    view.layer.cornerRadius = 27;
    view.layer.masksToBounds = YES;
    UIImage *image = [UIImage imageWithView:view];
    return image;
}



@end
