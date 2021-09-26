//
//  WebViewController.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "BaseController.h"
#import <WebKit/WebKit.h>
#import "JSService.h"
//#import "ImageController.h"
//#import "ScanController.h"
//#import "InPlaceController.h"


UIKIT_EXTERN NSString * _Nonnull const toChoseUser;
UIKIT_EXTERN NSString * _Nonnull const toStartLocation;
UIKIT_EXTERN NSString * _Nonnull const toStopLocation;
UIKIT_EXTERN NSString * _Nonnull const removeJSNotification;
UIKIT_EXTERN NSString * _Nonnull const removeLocationObserver;
UIKIT_EXTERN NSString * _Nonnull const toDetailHistory;

typedef enum : NSUInteger {
    type_popTo,
    type_toRoot,
    type_back,
    type_popNeedPush
} PopType;

@protocol WebViewControllerDelegate <NSObject>

- (void) resume:(NSDictionary*_Nullable) data;

@end

@interface DBXWebProcessPool : NSObject
+ (_Nullable instancetype)sharedInstance;

@property (nonatomic,strong) WKProcessPool * _Nullable processPool;
@end

@interface WebViewController : BaseController<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate,UIDocumentPickerDelegate>

@property (nonatomic,retain) NSString * _Nullable url;

@property (nonatomic,retain) WKWebView * _Nullable webView;

@property (nonatomic,strong) CALayer * _Nullable progressLayer;

@property (nonatomic,strong) NSString * _Nullable titleString;

@property (nonatomic,strong) NSString * _Nullable startupParams;

@property (nonatomic,weak) UIViewController * _Nullable delegate;

@property (nonatomic,strong) NSDictionary * _Nullable params;

@property (nonatomic,assign) BOOL readTitle;

@property (nonatomic,assign) BOOL needSetTitle;

@property (nonatomic,strong) NSDictionary * _Nullable resumeData;

@property (nonatomic,assign) NSInteger uploadedCount;

@property (nonatomic,strong) NSString * _Nullable popTo;

@property (nonatomic,assign) BOOL choseImgUpload;

@property (nonatomic,strong) JSService *_Nullable jsService;

- (id _Nullable )initWithParams:(NSDictionary*_Nullable) params;

- (void) setOptionMenuForWebview:(NSString * _Nonnull)title color:(unsigned int)color;

- (void) setOptionMenuForWebview:(NSString * _Nonnull)icon;

- (void) pushWindowFromWebview:(UIViewController * _Nonnull)webController;

- (void)callHandler:(NSString *_Nullable)handlerName data:(id _Nullable )data responseCallback:(void(^_Nullable)(id _Nullable responseData,NSError * _Nullable error))callback;

- (void)trigger:(NSString *_Nonnull)handlerName data:(id _Nonnull)data responseCallback:(void(^_Nonnull)(id _Nonnull responseData,NSError * _Nonnull error))callback;

- (void) removeJS;

- (void) resume:(NSDictionary* _Nullable) data;

- (void) setEnvData;

+ (void) toH5View:(NSString* _Nonnull) url  data:(NSDictionary* _Nullable) data controller:(UIViewController* _Nonnull) controller;

@end
