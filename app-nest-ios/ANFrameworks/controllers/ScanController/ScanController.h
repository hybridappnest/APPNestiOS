//
//  ScanController.h
//  app-nest-ios
//
//  Created by brent on 2021/3/15.
//

#import "BaseController.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScanControllerDelagate <NSObject>

- (void) resultOfScan:(NSString*) value;

@end

@interface ScanController : BaseController<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (strong,nonatomic) AVCaptureDevice *device;

@property (nonatomic,assign) CGFloat regionWidth;

@property (nonatomic,assign) CGFloat regionCenterX;

@property (nonatomic,assign) CGFloat regionCenterY;

@property (nonatomic,assign) CGFloat regionRadius;

@property (nonatomic,strong) UIButton *backButton;

@property (nonatomic,strong) UIView *scanLine;

@property (nonatomic,strong,nullable) NSTimer *timer;

@property (nonatomic,weak) id<ScanControllerDelagate> delegate;



+ (void) openScan:(NSDictionary*) dic;

+ (void) dealOpenScan:(NSDictionary*) dic;

@end

NS_ASSUME_NONNULL_END
