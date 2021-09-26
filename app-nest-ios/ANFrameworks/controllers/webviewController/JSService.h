//
//  JSService.h
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "ANFrameworks.h"
//#import "WebViewController.h"

//@class WebViewController;

NS_ASSUME_NONNULL_BEGIN

@interface JSServiceModel : NSObject

@property (nonatomic,strong) NSString *funName;

@property (nonatomic,strong) NSString *className;

@property (nonatomic,strong) NSString *callbackName;

@end


@protocol JSServiceDelegate <NSObject>

- (void) setTitleForWebview:(NSString*) title;

- (void) setOptionMenuForWebview:(NSString*) title color:(unsigned) color;

- (void) setOptionMenuForWebview:(NSString *)icon;

- (void) pushWindowFromWebview:(UIViewController*) webController;


@end

@interface JSService : NSObject

@property (nonatomic,weak) UIViewController *webController;

@property (nonatomic,strong) NSString *funName;

@property (nonatomic,strong) NSString *callbackName;

@property (nonatomic,assign) NSInteger announce;

@property (nonatomic,strong) NSDictionary *params;

+ (void) initDefaultJSService;

+ (JSService*) createJSService:(NSDictionary*) message webview:(UIViewController*) webview;

- (instancetype) initWithWebview:(UIViewController*) webview message:(NSDictionary*) message model:(JSServiceModel*) model;

+ (void) registerService:(NSString*) funName className:(NSString*) className callback:(NSString*) callbackName;

@end

NS_ASSUME_NONNULL_END
