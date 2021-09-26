//
//  UITableViewCell+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "UITableViewCell+Category.h"

@implementation UITableViewCell (Category)

-(void) clearCellContentView {
    NSArray *subViews = self.contentView.subviews;
    for (UIView *view in subViews) {
        [view removeFromSuperview];
    }
}

@end
