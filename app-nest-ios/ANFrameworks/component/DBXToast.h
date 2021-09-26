//
//  DBXToast.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXToast : UIView

@property(nonatomic,strong)UIView *alaphView;

@property(nonatomic,strong)UIView *backView;

@property(nonatomic,strong)NSDictionary *data;

+ (void) showToast:(NSString*) msg  success:(BOOL) success;

@end

NS_ASSUME_NONNULL_END
