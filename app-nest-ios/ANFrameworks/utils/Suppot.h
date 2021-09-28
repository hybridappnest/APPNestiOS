//
//  Suppot.h
//  app-nest-ios
//
//  Created by brent on 2021/9/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Suppot : NSObject

+ (UIViewController*) createRootController:(NSArray* _Nullable) guideImgNames guide:(BOOL) show;

+ (void)registNotification:(id) appDelegate;

@end

NS_ASSUME_NONNULL_END
