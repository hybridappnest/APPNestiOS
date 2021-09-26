//
//  AVAsset+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.
//

#import "AVAsset+Category.h"
#import <UIKit/UIKit.h>
#import "ANFrameworks.h"

@implementation AVAsset (Category)

+ (NSString*) coverImageToFile:(NSString*) videoPath {
    
    UIImage *image = [AVAsset coverImage:videoPath];
    NSData *data = UIImageJPEGRepresentation(image, 0.01);
    
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    NSString *name = url.path.md5;
    NSString *targetFile =  [NSString stringWithFormat:@"%@/coverImages/",KDOCUMENTPATH];
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetFile]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:targetFile withIntermediateDirectories:YES attributes:nil error:nil];
    }
    targetFile = [NSString stringWithFormat:@"%@%@.jpg",targetFile,name];
    [data writeToFile:targetFile atomically:YES];
    return targetFile;
}

+ (UIImage*) coverImage:(NSString*) videoPath {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];

    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    NSError *error = nil;
    CMTime time = kCMTimeZero;
    CMTime actucalTime;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        NSLog(@"ERROR:获取视频图片失败,%@",error.domain);
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    NSLog(@"imageWidth=%f,imageHeight=%f",image.size.width,image.size.height);
    CGImageRelease(cgImage);
    return image;

}

+ (void)mov2mp4:(NSURL *)movUrl needComposition:(BOOL) need block:(void (^) (BOOL flag,NSString *resultPath))cb
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    /**
     AVAssetExportPresetMediumQuality 表示视频的转换质量，
     */
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        id asset = avAsset;
        if (need) {
            AVMutableComposition *composition = [AVMutableComposition composition];
                
            AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                
            AVAssetTrack *sourceVideoTrack = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            AVAssetTrack *sourceAudioTrack = [avAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
                
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:sourceVideoTrack atTime:kCMTimeZero error:nil];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:sourceAudioTrack atTime:kCMTimeZero error:nil];
            
            asset = composition;
        
        }
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        
        //转换完成保存的文件路径
        NSString *lastPath = [movUrl lastPathComponent];
        NSString *fileName = @"";
        if ([lastPath containsString:@".MOV"]) {
            fileName = [lastPath stringByReplacingOccurrencesOfString:@".MOV" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, lastPath.length)];
        }
        if ([lastPath containsString:@".mov"]) {
            fileName = [lastPath stringByReplacingOccurrencesOfString:@".mov" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, lastPath.length)];
        }
        NSString * resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/mov2mp4/output-%@.mp4",fileName];

        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        if ( [[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:resultPath error:&error];
            if (error) {
                cb(YES,resultPath);
                return;
            }
        }
        
        //要转换的格式，这里使用 MP4
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        //转换的数据是否对网络使用优化
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        if (need) {
            AVMutableVideoComposition *videoComposition = [AVAsset fixedCompositionWithAsset:asset degrees:[AVAsset degressFromVideoFileWithAsset:avAsset]];
            if (videoComposition.renderSize.width) {
                // 修正视频转向
                exportSession.videoComposition = videoComposition;
            }
        }
        
        //异步处理开始转换
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             //转换状态监控
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusFailed:
                 {
                     NSLog(@"AVAssetExportSessionStatusFailed=%@",exportSession.error);
                     cb(NO,resultPath);
                     break;
                 }
                 case AVAssetExportSessionStatusCancelled:
                     NSLog(@"AVAssetExportSessionStatusCancelled");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                 {
                     //转换完成
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     cb(YES,resultPath);
                     break;
                 }
             }
             
         }];
    }
}

//获取优化后的视频转向信息
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset degrees:(int)degrees {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}


/// 获取视频角度
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}


@end
