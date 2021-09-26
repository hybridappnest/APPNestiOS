//
//  ScanController.m
//  app-nest-ios
//
//  Created by brent on 2021/3/15.
//

#import "ScanController.h"
#import "ANFrameworks.h"

@interface ScanController ()

@end

@implementation ScanController

+ (void) openScan:(NSDictionary*) dic {
    BOOL camera = [UIImagePickerController
                   isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!camera) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:@"不支持拍照，请检查您的设备" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertView addAction:sure];
        UIViewController *controller = [RootController topController];;
        [controller presentViewController:alertView animated:true completion:nil];
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [ScanController dealOpenScan:dic];
        return;
    } else  { // 用户拒绝当前应用访问相机
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                   // 用户接受
                dispatch_async(dispatch_get_main_queue(),^{
                    [ScanController dealOpenScan:dic];
                });
                return;
            } else {
                [Tool toSetting:@"需要授权相机，请检查设置"];
            }
        }];
    }
}

+ (void) dealOpenScan:(NSDictionary*) dic {
    ScanController *cameraController = [[ScanController alloc] init];
    cameraController.title = [dic valueForKey:@"title"];
    cameraController.delegate = [dic valueForKey:@"delegate"];
    UIViewController *topController = [RootController topController];
    id isPush = [dic valueForKey:@"isPush"];
    if (isPush && [isPush boolValue]) {
        [topController.navigationController pushViewController:cameraController animated:YES];
    } else {
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:cameraController];
        if (@available(iOS 13.0,*)) {
            cameraController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        [topController presentViewController:nav animated:YES completion:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isShouldAutorotate = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    
    _regionWidth = self.view.frame.size.width - 100;
    _regionCenterX = self.view.frame.size.width / 2;
    _regionCenterY = self.view.frame.size.height / 3;
    _regionRadius = _regionWidth / 2;
    
    [self initCapture];//启动摄像头
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    imageView.image = [UIImage imageNamed:@"ScanKuang.png"];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self.view addSubview:imageView];
    // Do any additional setup after loading the view.

    [self createScanRegion];
//    [self createBack];
}

- (void) createBack {
    CGFloat y = 20;
    if ([Tool isBangs]) {
        y = 44;
    }
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(0, y, 60, 44);
    [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
}

- (void) back {
    [super back];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
}

- (void) startRunning {
    if (self.captureSession) {
        [self.captureSession startRunning];
    }
    [self startTimer];
}

- (void) stopRunning {
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
    [self stopTimer];
}

- (void) startTimer {
    [self stopTimer];
    if (@available(iOS 10.0, *)) {
        __weak ScanController *weakself = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakself dealScan];
        }];
    } else {
        // Fallback on earlier versions
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(dealScan) userInfo:nil repeats:YES];
    }
}

- (void) stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void) dealScan {
    CGRect rect = [self scanRegion];
    CGFloat y = _scanLine.frame.origin.y;
    if (y >= rect.origin.y + rect.size.height){
        y = rect.origin.y;
    }
    y++;
    _scanLine.frame = CGRectMake(rect.origin.x, y, rect.size.height,_scanLine.frame.size.height);
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void) createScanRegion {
    CGFloat centerX = _regionCenterX;
    CGFloat centerY = _regionCenterY;
    CGFloat radius = _regionRadius;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, centerY - radius)];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.5;
    [self.view addSubview:topView];
    

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, centerY + radius, self.view.frame.size.width, self.view.frame.size.height - centerY - radius)];
    bottomView.alpha = 0.5;
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];

    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.frame.size.height, centerX - radius, bottomView.frame.origin.y - topView.frame.size.height)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(centerX + radius, topView.frame.size.height, centerX - radius, bottomView.frame.origin.y - topView.frame.size.height)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    UIView *leftTop = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width + leftView.frame.origin.x, topView.frame.size.height + topView.frame.origin.y, 30, 2)];
    leftTop.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:leftTop];
    
    UIView *leftTopLeft = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width + leftView.frame.origin.x, topView.frame.size.height + topView.frame.origin.y, 2, 30)];
    leftTopLeft.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:leftTopLeft];
    
    UIView *leftBottom = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width + leftView.frame.origin.x, bottomView.frame.origin.y - 2, 30, 2)];
    leftBottom.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:leftBottom];
    
    UIView *leftBottomLeft = [[UIView alloc] initWithFrame:CGRectMake(leftView.frame.size.width + leftView.frame.origin.x, bottomView.frame.origin.y - 30, 2, 30)];
    leftBottomLeft.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:leftBottomLeft];
    
    UIView *rightTop = [[UIView alloc] initWithFrame:CGRectMake(rightView.frame.origin.x - 30, topView.frame.size.height + topView.frame.origin.y, 30, 2)];
    rightTop.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:rightTop];
    
    UIView *rightTopRight = [[UIView alloc] initWithFrame:CGRectMake(rightView.frame.origin.x - 2, topView.frame.size.height + topView.frame.origin.y, 2, 30)];
    rightTopRight.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:rightTopRight];
    
    UIView *rightBottom = [[UIView alloc] initWithFrame:CGRectMake(rightView.frame.origin.x - 30, bottomView.frame.origin.y - 2, 30, 2)];
    rightBottom.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:rightBottom];
    
    UIView *rightBottomRight = [[UIView alloc] initWithFrame:CGRectMake(rightView.frame.origin.x - 2, bottomView.frame.origin.y - 30, 2, 30)];
    rightBottomRight.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    [self.view addSubview:rightBottomRight];
    
    CGRect rect = [self scanRegion];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width,1.5)];
    line.backgroundColor = [UIColor colorFromHexString:@"0B297E"];
    _scanLine = line;
    [self.view addSubview:line];
}

- (CGRect) scanRegion {
    return CGRectMake(_regionCenterX - _regionRadius, _regionCenterY - _regionRadius, _regionWidth, _regionWidth);
}

- (CGRect) rectOfInterestsByScanViewRect:(CGRect) rect {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat x = rect.origin.y/height;
    CGFloat y = rect.origin.x/width;
    CGFloat w = rect.size.height/height;
    CGFloat h = rect.size.width/width;
    return  CGRectMake(x, y, w, h);
}

- (void)initCapture {
    CGRect rect = [self scanRegion];
    
//    UIView *view = [[UIView alloc] initWithFrame:rect];
//    view.backgroundColor = [UIColor redColor];
//    view.alpha = 0.5;
//    [self.view addSubview:view];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.device = [[AVCaptureDevice devices] firstObject];
    
    [self.device lockForConfiguration:nil];
    if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    [self.device unlockForConfiguration];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    [self.captureSession addInput:captureInput];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    AVCaptureMetadataOutput *output=[[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
   
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [self.captureSession addOutput:output];
    output.metadataObjectTypes =@[AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode];
    
    if (!self.captureVideoPreviewLayer) {
        self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    }
    self.captureVideoPreviewLayer.frame = CGRectMake(0,0,KSCREENWIDTH,KSCREENHEIGHT);
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    output.rectOfInterest =  [_captureVideoPreviewLayer metadataOutputRectOfInterestForRect:rect];
    [self.view.layer addSublayer: self.captureVideoPreviewLayer];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate//IOS7下触发
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"didOutputMetadataObjects = %@",metadataObjects);
    if (metadataObjects.count > 0) {
        [self stopRunning];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1007);
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        NSLog(@"------result------ = %@",metadataObject.stringValue);
        if (_delegate && [_delegate respondsToSelector:@selector(resultOfScan:)]) {
            [_delegate resultOfScan:metadataObject.stringValue];
        }
        [self back];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
