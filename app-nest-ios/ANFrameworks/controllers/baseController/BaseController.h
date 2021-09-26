//
//  BaseController.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <UIKit/UIKit.h>


@interface BaseController : UIViewController<UINavigationControllerDelegate>

///是否支持旋转
@property(nonatomic,assign)BOOL isShouldAutorotate;

@property (nonatomic,strong) UIView *safeView;

@property (nonatomic,strong) UIView *container;

@property (nonatomic,assign) BOOL isTabBarHidden;

@property (nonatomic,assign) BOOL isNavBarHidden;

@property (nonatomic,assign) BOOL needBackButton;

@property (nonatomic,assign) BOOL isRootController;

-(void) back;



/*＊
 describe：设置导航栏左边按钮，
 @param：action:按钮响应方法
 @param：imgName:图片名称
 return：N/A
 */
- (void) setLeftButton:(SEL)action img:(NSString *)imgName;

/*＊
 describe：设置导航栏右边按钮，
 @param：action:按钮响应方法
 @param：imgName:图片名称
 return：N/A
 */
- (void) setRightButton:(SEL)action img:(NSString *) imgName;

-(void) setRightButton:(SEL)action netimg:(NSString*)imgName;

/*＊
 describe：设置导航栏左边按钮，
 @param：action:按钮响应方法
 @param：string:按钮标题
 return：N/A
 */
-(void) setRightStringButton:(SEL)action string:(NSString*)string color:(unsigned) color;

/*＊
 describe：设置导航栏右边按钮，
 @param：action:按钮响应方法
 @param：string:按钮标题
 return：N/A
 */
- (void) setLeftStringButton:(SEL)action string:(NSString *)string;

+ (UIColor *) backColor;

@end
