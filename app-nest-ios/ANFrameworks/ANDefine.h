//
//  ANDefine.h
//  app-nest-ios
//
//  Created by brent on 2021/9/14.
//

#ifndef ANDefine_h
#define ANDefine_h

#if DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...) /* */
#endif

#pragma mark 设备信息

///获取系统版本号 float
#define GETVERSION  ([[[UIDevice currentDevice] systemVersion] floatValue])

///获取系统版本号 string
#define GETSTRINGVERSION  ([[UIDevice currentDevice] systemVersion])

///屏幕高
#define KSCREENHEIGHT [UIScreen mainScreen].bounds.size.height

///屏幕宽
#define KSCREENWIDTH  [UIScreen mainScreen].bounds.size.width

#pragma mark 系统沙盒路径

///DocumentPath
#define KDOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

///CachesPath
#define KCACHESPATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#pragma mark APP信息

///获取APP版本号
#define GETAPPVERSION  ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])

///获取APP构建版本号
#define GETAPPBUILDVERSION  ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

///获取APP包名
#define APPIdentifier ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"])

///获取APP名称
#define APPName ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])

#define PNSAuth (@"")

#define wxappId (@"")
#define wxscope (@"")
#define wxstate (@"")



#endif /* ANDefine_h */
