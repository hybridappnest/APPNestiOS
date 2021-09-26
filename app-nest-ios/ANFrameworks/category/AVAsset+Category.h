//
//  AVAsset+Category.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (Category)

+ (void)mov2mp4:(NSURL *)movUrl needComposition:(BOOL) need block:(void (^) (BOOL flag,NSString *resultPath))cb;

+ (NSString*) coverImageToFile:(NSString*) videoPath;

+ (UIImage*) coverImage:(NSString*) videoPath;

@end

NS_ASSUME_NONNULL_END
