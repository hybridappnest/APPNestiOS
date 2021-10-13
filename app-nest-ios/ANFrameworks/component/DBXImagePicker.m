//
//  DBXImagePicker.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "DBXImagePicker.h"
#import "DBXImagePickerController.h"
#import "ANFrameworks.h"

static NSDictionary *uiConfig;


@implementation DBXImagePicker{
    void (^saveMedia) (NSArray *medias,NSArray *urls,NSArray *images);
}

+ (void) configUI:(NSDictionary*) dic {
    uiConfig = dic;
    if (!uiConfig) {
        uiConfig = @{@"buttonBack":@"e5e5e5",@"buttonColor":@"333333",@"buttonFont":@14,@"splitColor":@"e5e5e5",@"buttonHeight":@56};
    }
}

+ (NSDictionary*) uiConfigDic {
    return  uiConfig;
}

- (instancetype) initWithData:(NSDictionary*) data withCompletion:(void (^) (NSArray *medias,NSArray *urls,NSArray *images)) callback {
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, KSCREENWIDTH, KSCREENHEIGHT);
        id delegate = [data valueForKey:@"delegate"];
        _delegate = delegate;
        id onlyAlumString = [data valueForKey:@"onlyAlum"];
        if (onlyAlumString) {
            _isOnlyAlum = [onlyAlumString boolValue];
        }
        id allowsEditingString = [data valueForKey:@"allowsEditing"];
        if (allowsEditingString) {
            _allowsEditing = [allowsEditingString boolValue];
        }
//        _allowsEditing = NO;
        id onlyTakePhoneString = [data valueForKey:@"onlyTakePhone"];
        if (onlyTakePhoneString) {
            _isOnlyTakePhone = [onlyTakePhoneString boolValue];
        }
        id isAlumHaveVideoString = [data valueForKey:@"isAlumHaveVideo"];
        if (isAlumHaveVideoString) {
            _isAlumHaveVideo = [isAlumHaveVideoString boolValue];
        }
        _needWatermark = YES;
        id needWatermark = [data valueForKey:@"needWatermark"];
        if (needWatermark) {
            _needWatermark = [needWatermark boolValue];
        }
        
        saveMedia = [callback copy];
        [self createPickerView];
    }
    return self;
}

- (void) showImagePicker {
    __weak DBXImagePicker *weakself = self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        weakself.alphaView.alpha = 0.4;
        CGRect aRect = weakself.pickerBack.frame;
        aRect.origin.y = 0;
        weakself.pickerBack.frame = aRect;
    }completion:^(BOOL finished){
        //         _alphaView.hidden = NO;
    }];
}

-(void) createPickerView{
    _pickerBack = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    //    _pickerBack.backgroundColor = [UIColor redColor];
    _alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pickerBack.frame.size.width, _pickerBack.frame.size.height)];
    _alphaView.backgroundColor = [UIColor blackColor];
    _alphaView.alpha = 0.0;
    [self addSubview:_alphaView];
    [self addSubview:_pickerBack];
    //    _alphaView.hidden = YES;
    
    
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pickerBack.frame.size.width, _pickerBack.frame.size.height)];
    secondView.backgroundColor = [UIColor clearColor];
    [_pickerBack addSubview:secondView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewImage:)];
    tap.numberOfTapsRequired = 1;
    [secondView addGestureRecognizer:tap];
    
    
    NSArray *array = @[@"拍照",@"从手机相册选择"];
    if (_isOnlyAlum) {
        array = @[@"从手机相册选择"];
    }
    if (_isOnlyTakePhone) {
        array = @[@"拍照"];
    }
    //@{@"buttonBack":@"e5e5e5",@"buttonColor":@"333333",@"buttonFont":@14,@"splitColor":@"e5e5e5",@"buttonHeight":@56};
    NSDictionary *dic = [DBXImagePicker uiConfigDic];
    CGFloat height = [[dic valueForKey:@"buttonHeight"] floatValue];
    if (height <= 0) {
        height = 56;
    }
    CGFloat allHeight = height * array.count + height + 10;
    UIView *buttonBack = [[UIView alloc] initWithFrame:CGRectMake(0, secondView.frame.size.height - allHeight, secondView.frame.size.width, allHeight)];
    NSString *buttonBackColor = [NSString convertNull:[dic valueForKey:@"buttonBack"]];
    if (!(buttonBackColor && buttonBackColor.length > 0)) {
        buttonBackColor = @"e5e5e5";
    }
    buttonBack.backgroundColor = [UIColor colorFromHexString:buttonBackColor];
    [buttonBack topCorner:10];
    [secondView addSubview:buttonBack];
    
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *string = [array objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        if (_isOnlyAlum) {
            button.tag = 1;
        }
        if (_isOnlyTakePhone) {
            button.tag = 0;
        }
        button.backgroundColor = [UIColor whiteColor];
//        if (i == 0) {
//            [button topCorner:10];
//        }
        button.frame = CGRectMake(0, i * height, buttonBack.frame.size.width, height);
        [button setTitle:string forState:UIControlStateNormal];
        NSString *buttonColor = [NSString convertNull:[dic valueForKey:@"buttonColor"]];
        if (!(buttonColor && buttonColor.length > 0)) {
            buttonColor = @"333333";
        }
        [button setTitleColor:[UIColor colorFromHexString:buttonColor] forState:UIControlStateNormal];
        CGFloat buttonFont = [[dic valueForKey:@"buttonFont"] floatValue];
        if (buttonFont <= 0) {
            buttonFont = 14;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:buttonFont];
        [button addTarget:self action:@selector(dealButton:) forControlEvents:UIControlEventTouchUpInside];
        [buttonBack addSubview:button];
        
        if (i < array.count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height - 0.5, button.frame.size.width, 0.5)];
            NSString *splitColor = [NSString convertNull:[dic valueForKey:@"splitColor"]];
            if (!(splitColor && splitColor.length > 0)) {
                splitColor = @"e5e5e5";
            }
            line.backgroundColor = [UIColor colorFromHexString:splitColor];
            [button addSubview:line];
        }
    }
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0,buttonBack.frame.size.height - height, buttonBack.frame.size.width, height);
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    NSString *buttonColor = [NSString convertNull:[dic valueForKey:@"buttonColor"]];
    if (!(buttonColor && buttonColor.length > 0)) {
        buttonColor = @"333333";
    }
    [cancelButton setTitleColor:[UIColor colorFromHexString:buttonColor] forState:UIControlStateNormal];
    CGFloat buttonFont = [[dic valueForKey:@"buttonFont"] floatValue];
    if (buttonFont <= 0) {
        buttonFont = 14;
    }
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:buttonFont];
    [cancelButton addTarget:self action:@selector(dealCancel) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack addSubview:cancelButton];

}

- (void) openCamera {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = _allowsEditing;;
    picker.sourceType = sourceType;
    
    
    if (_isAlumHaveVideo) {
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
    }

    
    [picker setVideoMaximumDuration:60];
    
    UIViewController *controller = [RootController topController];
    __weak DBXImagePicker *weakself = self;
    [controller presentViewController:picker animated:YES completion:^{

    }];
    _imagePickerType = dbxtakePhoto;
}

-(void) toTakePhoto{
    [self previewImage:nil];
    __weak DBXImagePicker *weakself = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusAuthorized) {
            [self openCamera];
            return;
        } else  { // 用户拒绝当前应用访问相机
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                       // 用户接受
                    dispatch_async(dispatch_get_main_queue(),^{
                        [weakself openCamera];
                    });
                    return;
                } else {
                    [weakself toSetting:@"需要授权相机，请检查设置"];
                }
            }];
        }
    }else {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:@"不支持拍照，请检查您的设备" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertView addAction:sure];
        UIViewController *controller = [RootController topController];
        [controller presentViewController:alertView animated:true completion:nil];
    }
}

-(void) toAlbum{
    [self previewImage:nil];
    __weak DBXImagePicker* weakself = self;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    DBXImagePickerController * picker = [[DBXImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = _allowsEditing;;
    picker.sourceType = sourceType;
    picker.mediaTypes = @[@"public.image"];
    if (_isAlumHaveVideo) {
        picker.mediaTypes = @[@"public.movie",@"public.image"];
    }
    _imagePickerType = dbx_alum;
    
    UIViewController *controller = [RootController topController];
    [controller presentViewController:picker animated:YES completion:nil];
}

- (void) toSetting:(NSString*) title {
    __weak DBXImagePicker *weakself = self;
    dispatch_async(dispatch_get_main_queue(),^{
       UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                               
        }];
        [alertView addAction:cancel];
       UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
           NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
           if ([[UIApplication sharedApplication] canOpenURL:appSettings]) {
               if (@available(iOS 10.0, *)) {
                   [[UIApplication sharedApplication] openURL:appSettings options:@{} completionHandler:^(BOOL success) {
                       
                   }];
               } else {
                   // Fallback on earlier versions
               }
           }
       }];
       [alertView addAction:sure];
        
       UIViewController *controller = [RootController topController];
       [controller presentViewController:alertView animated:true completion:nil];
   });
}

- (void) dealButton:(UIButton *) button {
    if (button.tag == 0) {
        [self toTakePhoto];
    } else if (button.tag == 1) {
        [self toAlbum];
    }
}

-(void) dealCancel{
    [self previewImage:nil];
}


- (void)previewImage:(UITapGestureRecognizer *)tap{
    __weak DBXImagePicker *weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakself.alphaView.alpha = 0.0;
        CGRect aRect = weakself.pickerBack.frame;
        aRect.origin.y = weakself.pickerBack.frame.size.height;
        weakself.pickerBack.frame = aRect;
    } completion:^(BOOL flag){
        weakself.hidden = YES;
//        [self removeFromSuperview];
    }];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.movie"]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSString *referenceURL = info[UIImagePickerControllerReferenceURL];
        BOOL is_library = NO;
        if (referenceURL) {
            is_library = YES;
        }
//        NSString *dateString = [NSDate dateToString:[NSDate date]];
//        NSString *string = [NSString stringWithFormat:@"%@ 从相册选择于 %@",[UserService getUserName],dateString];
//        if (!is_library) {
//            string = [NSString stringWithFormat:@"%@ 拍摄于 %@",[UserService getUserName],dateString];
//        }
        NSString *path = [AVAsset coverImageToFile:url.path];
        UIImage *image = [AVAsset coverImage:url.path];
        NSDictionary *dic = @{@"type":[NSNumber numberWithInteger:take_video],@"coverUrl":path,@"url":url.path,@"is_library":[NSNumber numberWithBool:is_library],@"text":@""};
        NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        if (saveMedia) {
            saveMedia(@[muDic],@[url],@[image]);
        }
        [self removeFromSuperview];
        return;
    }
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!_allowsEditing) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
//    if (_needWatermark) {
//        NSString *dateString = [NSDate dateToString:[NSDate date]];
//        NSString *string = [NSString stringWithFormat:@"%@ 从相册选择于 %@",[UserService getUserName],dateString];
//        if (_imagePickerType == dbxtakePhoto) {
//            string = [NSString stringWithFormat:@"%@ 拍摄于 %@",[UserService getUserName],dateString];
//        }
//        CGFloat rate = image.size.width / [UIScreen mainScreen].bounds.size.width ;
//        CGFloat font = 15 * rate;
//        if (font < 15) {
//            font = 15;
//        }
//        image = [Tool imageSetString_image:image text:string textPoint:CGPointMake(10, image.size.height - 400) attributedString:@{NSForegroundColorAttributeName:[UIColor colorWithInt:0xffffff alpha:1.0], NSFontAttributeName:[UIFont systemFontOfSize:font]}];
//    }
    
    NSString *path = @"";
    if (@available(iOS 11.0, *)) {
//        if (_imagePickerType == alum) {
//            NSURL *url = info[UIImagePickerControllerImageURL];
//            path = url.path;
//        } else {
        NSString *string = [NSDate dateToString:[NSDate date]];
        string = string.md5;
        NSData *imgData = UIImageJPEGRepresentation(image, 0.01);
        path = [NSString stringWithFormat:@"%@/photo_%@.jpg",KDOCUMENTPATH,string];
        [imgData writeToFile:path atomically:YES];
//        }
    } else {
        NSString *string = [NSDate dateToString:[NSDate date]];
        string = string.md5;
        NSData *imgData = UIImageJPEGRepresentation(image, 0.01);
        path = [NSString stringWithFormat:@"%@/photo_%@.jpg",KDOCUMENTPATH,string];
        [imgData writeToFile:path atomically:YES];
        // Fallback on earlier versions
    }
    NSDictionary *dic = @{@"type":[NSNumber numberWithInteger:take_photo],@"coverUrl":@"",@"url":path};
    NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    if (saveMedia) {
        saveMedia(@[muDic],@[path],@[image]);
    }
    
    [self removeFromSuperview];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
    [self removeFromSuperview];
    NSLog(@"do cancel");
}

@end
