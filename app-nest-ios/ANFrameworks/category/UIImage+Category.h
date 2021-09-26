//
//  UIImage+UIImageCategory.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <UIKit/UIKit.h>

typedef void (^GIFimageBlock)(UIImage *GIFImage);

@interface UIImage (Category)

///用颜色生成图片
+(UIImage *)imageWithColor:(UIColor *)color;

///用颜色生成图片，可以设置alpha
+(UIImage *)imageWithColor:(UIColor *)color alpha:(CGFloat) a;

///用UIView生成图片
+(UIImage*)imageWithView:(UIView*) view;

///生成图片的缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

///图片加水印
+ (UIImage *)watermark:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed;

/** 根据本地GIF图片名 获得GIF image对象 */
+ (UIImage *)imageWithGIFNamed:(NSString *)name;

/** 根据一个GIF图片的data数据 获得GIF image对象 */
+ (UIImage *)imageWithGIFData:(NSData *)data;

/** 根据一个GIF图片的URL 获得GIF image对象 */
+ (void)imageWithGIFUrl:(NSString *)url and:(GIFimageBlock)gifImageBlock;

@end
