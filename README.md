# APP-NEST 混合开发框架
APP-NEST 混合开发框架，是基于原生Webview框架，开发的一套IOS混合开发框架，可以通过配置快速搭建一个UIView+Navigation+TabBar结构的WebApp应用，支持VUE页面的渲染。使用cocospod管理第三方库。
cocospod使用，请参阅：https://guides.cocoapods.org

# 功能列表
* 支持web页面打开，关闭，支持设置标题，右上角按钮设置，页面内自定义标题栏
* 支持调起图片选择器
* 支持调起拍照
* 支持调起视频选择器
* 支持调起视频拍摄
* 支持调起icloud文件选择
* 支持OSS文件上传
* 支持二维码，条形码扫码功能
* 支持图片预览
* 支持预置Toast弹出
* 支持设置app是否自动锁屏
* 支持手机号一键登陆
* 支持微信登陆（只支持Universal Link唤起app，不再支持scheme的方式唤起app，如果需要可以自行按照苹果官方配置）
* 支持自定义JS事件

# 目录结构
```
.
├── README.md // 说明文档
└── app-nest-ios 
    └── ANFrameworks //框架核心代码
        └──controllers //包含框架实例化代码，基类，webcontroller核心代码，JS事件服务
        └──component //常用控件，图片选择器
        └──networking //网络状态工具类
        └──category //常用的分类实现
        └──utils //工具类，OSS上传工具类
        └──basemodel //数据model的基类，继承该类，自动把null根据属性类型转为对应类型的空对象
        └──protocol //常用的协议类
        └──third //无法用cocospod管理的三房库
        └──config.plist //app快速框架配置文件
└──app-nest-ios.xcodeproj
└──app-nest-ios.xcworkspace
└──Pods
```

# 使用简介

## 一，基本配置
### 1，从github下载ANFrameworks，
    （1）导入到自己的工程中，在AppDelegate中引用#import "ANFrameworks.h"头文件，并在didFinishLaunchingWithOptions中调用[JSService initDefaultJSService];初始化预置JS事件

    （2），通过cocospod，导入三房库
      pod 'AFNetworking', '~> 4.0.1'
      pod 'JSONModel'
      pod 'YBImageBrowser/NOSD'
      pod 'YBImageBrowser/VideoNOSD'
      pod 'AliyunOSSiOS'
      pod 'WechatOpenSDK'
      pod 'TXIMSDK_TUIKit_iOS' //腾讯云IMSDK，需要注掉Podfile中的use_frameworks
腾讯云IM使用，请参阅：https://cloud.tencent.com/document/product/269/37060

### 2，配置config.plist（详见demo中配置）
#### （1）base相关参数配置
```
titleColor //app的标题颜色
titleFont //app的标题颜色
navBackColor //标题栏背景色
backColor //页面背景色
translucent //标题栏是否透明
backImageName //返回按钮的图片名称，默认为back
unlink //唤起app的Universal Link
```
#### （2）tabbar相关参数配置
```
name //底部tabBar按钮和对应页面标题
imageRes //底部tabBar按钮未选中状态的图片
imageResSelected //底部tabBar按钮选中状态的图片
textColorRes //底部tabBar按钮选中的标题颜色
textColorResSelected //底部tabBar按钮选中状态的标题颜色
isSelected //是否默认选中当前tab页面
url //如果tab根页面为Web页，web页的url
className //如果tab根页面为原生页面，原生controller的类名称，请参阅demo中的“原生页面”配置
```
#### （3）oss相关参数配置（不使用oss或者图片选择功能可以不配置）
```
endpoint //oss的endpoint
authUrl //oss鉴权接口
bucketName //oss上传文件的对应bucket
```
#### （4）手机号码一键登陆参数配置（不使用可以不配置）
ANDefine.h （敏感的配置信息，建议配置在ANDefine.h中）
```
PNSAuth //一键登陆用到的密钥 （必填）
```
#### （5）微信登陆参数配置（不使用可以不配置）
ANDefine.h （敏感的配置信息，建议配置在ANDefine.h中）
```
wxappId //微信登陆的appid （必填）
wxscope //微信登陆请求的权限（必填）
wxstate //微信登陆时，标识app唯一性（防钓鱼）的字符串
```
收到微信调起app的通知配置
不兼容SceneDelegate的情况：
在AppDelegate中实现application:continueUserActivity:restorationHandler，并添加通知
```
[[NSNotificationCenter defaultCenter] postNotificationName:WeChatLoginNotification object:userActivity];
```
兼容SceneDelegate的情况下
在SceneDelegate中实现scene:continueUserActivity:方法，并添加通知
```
[[NSNotificationCenter defaultCenter] postNotificationName:WeChatLoginNotification object:userActivity];
```
#### （6）实例化rootController
不兼容SceneDelegate的情况：
在AppDelegate中的didFinishLaunchingWithOptions实现：
```
self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
self.window.backgroundColor = [UIColor blackColor];
[self.window makeKeyAndVisible]; 
RootController *rootController = [[RootController alloc] init];
self.window.rootViewController = rootController;
return YES;
```

兼容SceneDelegate的情况下
在AppDelegate中的didFinishLaunchingWithOptions实现：
```
if (@available(iOS 13.0,*)) {
    return YES;
} else {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    RootController *rootController = [[RootController alloc] init];
    self.window.rootViewController = rootController;
    return YES;
}
```
并且在SceneDelegate中willConnectToSession方法中实现：
```
UIWindowScene *windowScene = (UIWindowScene *)scene;
self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
[self.window setWindowScene:windowScene];
self.window.backgroundColor = [UIColor blackColor];
RootController *rootController = [[RootController alloc] init];
self.window.rootViewController = rootController;    
[self.window makeKeyAndVisible];
```

## 二，web页功能使用
### （1）打开web页面
H5页面中打开web页，调JSBridge.call('pushWindow',{})
请参阅：https://github.com/hybridappnest/AppNestWeb中的封装
如果需要在H5页面中自定义标题栏，JSBridge.call('pushWindow',{showTitleBar:false}),隐藏原生的标题栏，然后在H5页面中自己实现即可

app原生页面打开web页，直接调用
```
WebViewController中toH5View方法

url //H5页面的url
data //传递到H5页面的参数，json格式
controller //要打开H5页面的controller
```
### （2）关闭H5页面
H5页面中关闭web页，JSBridge.call('popWindow',{}) 
请参阅：https://github.com/hybridappnest/AppNestWeb中的封装

## 三，JS事件
### （1）预置JS事件
```
setTitle //设置页面标题啊
setOptionMenu //设置标题栏右上角按钮
pushWindow //页面内弹出H5页
popWindow //H5页面返回
```
以上方法调用方法，在H5页面通过JSBridge.call('事件名称',{})来调用，
请参阅：https://github.com/hybridappnest/AppNestWeb中的封装

```
showGallery //图片诗篇预览
showToast //toast提示
autolockScreen //设置是否自动锁屏
choseImg //图片，视频选择器
choseFile //文件选择器
upload //oss上传
scan //扫码
socialLogin //第三方登录
```
以上方法需要异步处理的调用方法，在H5页面通过post Notification的方式调用，示例：
```
this.PostNotification(
     'choseImg',
     {
         needVideo: false,
         maxnum: 1
     },
     Math.floor(Math.random() * 10000)
)
```
### （2）自定义JS事件
1，注册JS事件

在AppDelegate中的didFinishLaunchingWithOptions方法中调用
JSService类中的registerService方法，注册JS事件到全局的事件池中
```
funName //JS事件名称
className //JS事件对应的处理类
callbackName //JS事件处理结果，回调到H5页面的回调方法名
```
示例：
```
[JSService registerService:@"scan" className:@"QRService" callback:@"scanCallback"];
```
处理JS事件的类必须要继承自JSService，并实现initWithWebview方法，
示例：
QRService.h
```
@interface QRService : JSService

@end
```
QRService.m
```
@implementation QRService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [self dealAction:webview message:message];
    }
    return self;
}

- (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    [ScanController openScan:@{@"isPush":@NO,@"delegate":self}];
}

- (void) resultOfScan:(NSString *)value {
    NSDictionary *data = @{@"data":@{@"result":value},@"announce":[NSNumber numberWithInteger:self.announce]};
    if (self.callbackName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.webController) {
                WebViewController *controller = (WebViewController*)self.webController;
                [controller callHandler:self.callbackName data:data responseCallback:^(id responseData,NSError *error) {
                    NSLog(@"%@ 前端收到事件后的回调: %@", self.callbackName,responseData);
                }];
            }
        });
    }
}

@end
```
可以通过两种使用自定义JS事件，在页面中调用
```
1，JSBridge.call('scan',{})

2， this.PostNotification(
     'scan',
     {},
     Math.floor(Math.random() * 10000)
)
```

## 加入讨论群
| 微信 | QQ |
|-----------------------|:-----------------------|
| ![微信](./Wechat.png) | ![QQ](./QQImg.png) |

## LICENSE
Apache License Version 2.0