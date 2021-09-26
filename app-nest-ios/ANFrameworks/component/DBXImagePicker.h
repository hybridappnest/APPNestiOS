//
//  DBXImagePicker.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>
#import <UIKit/UIImagePickerController.h>

typedef enum : NSUInteger {
    dbx_alum = 0,
    dbxtakePhoto = 1
} DBXImagePickerType;

typedef enum : NSUInteger {
    take_video = 1,
    take_photo = 2,
}PhotoType;

NS_ASSUME_NONNULL_BEGIN

@interface DBXImagePicker : UIView<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) UIViewController *delegate;

@property (nonatomic, strong) UIView *pickerBack;

@property (nonatomic, strong) UIView *alphaView;

@property (nonatomic,assign) BOOL allowsEditing;

@property (nonatomic,strong) UIViewController *picker;

@property (nonatomic, assign) BOOL isOnlyAlum;

@property (nonatomic, assign) BOOL isOnlyTakePhone;

@property (nonatomic, assign) BOOL isAlumHaveVideo;

@property (nonatomic,assign) DBXImagePickerType imagePickerType;

@property (nonatomic,assign) BOOL needWatermark;

- (instancetype) initWithData:(NSDictionary*) data withCompletion:(void (^) (NSArray *medias,NSArray *urls,NSArray *images)) callback;

- (void) showImagePicker;




@end

NS_ASSUME_NONNULL_END
