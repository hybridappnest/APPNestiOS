//
//  choseFileService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "choseFileService.h"
#import "ANFrameworks.h"
#import <CoreServices/CoreServices.h>

@implementation choseFileService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [self dealAction:webview message:message];
    }
    return self;
}

- (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeContent,(NSString*)kUTTypeItem,(NSString*)kUTTypeCompositeContent,(NSString*)kUTTypeData,(NSString*)kUTTypeDiskImage,(NSString*)kUTTypeArchive] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    [webview presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    __weak choseFileService *weakself = self;
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [url lastPathComponent];
        NSString *objectKey = [NSString stringWithFormat:@"uploadedFiles/%@",fileName];
//        if ([objectKey containsString:@"."]) {
//            objectKey = [objectKey stringByReplacingOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, objectKey.length)];
//        }
        [[OSSUpload sharedInstance] uploadData:fileData objectKey:objectKey success:^(NSString *url) {
            if (weakself && weakself.callbackName && weakself.callbackName.length > 0) {
                [weakself callback:url fileName:fileName];
            }
        } failure:^(NSError *error) {
            [DBXToast showToast:error.localizedDescription success:NO];
        }];
        
//        NSString *oldName = fileName;
//        NSString *suffix = [url pathExtension];
//        fileName = fileName.md5;
//        fileName = [NSString stringWithFormat:@"files/%@.%@",fileName,suffix];
//        NSString *filePath = [KDOCUMENTPATH stringByAppendingString:fileName];
//        [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
//        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
//            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//            NSString *lastPath = fileURL.lastPathComponent;
//            __block NSString *suffix = [fileURL pathExtension];
//            NSString *name = [lastPath stringByReplacingOccurrencesOfString:suffix withString:@"" options:NSLiteralSearch range:NSMakeRange(0, lastPath.length)];
//            NSString *objectKey = [NSString stringWithFormat:@"uploadedFiles/%@",name];
//            if ([objectKey containsString:@"."]) {
//                objectKey = [objectKey stringByReplacingOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, objectKey.length)];
//            }
//            [[OSSUpload sharedInstance] uploadData:fileData objectKey:objectKey success:^(NSString *url) {
//                if (weakself && weakself.callbackName && weakself.callbackName.length > 0) {
//                    [weakself callback:url fileName:oldName];
//                }
//            } failure:^(NSError *error) {
//                [DBXToast showToast:error.localizedDescription success:NO];
//            }];
//        }
    }];
    [url stopAccessingSecurityScopedResource];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) callback:(NSString* _Nonnull) filePath fileName:(NSString* _Nonnull) fileName {
    __weak choseFileService *weakself = self;
    NSDictionary *data = @{@"data":@[@{@"filePath":filePath,@"fileName":fileName}],@"announce":[NSNumber numberWithInteger:self.announce]};
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakself && weakself.webController) {
            WebViewController *controller = (WebViewController*)weakself.webController;
            [controller callHandler:weakself.callbackName data:data responseCallback:^(id responseData,NSError *error) {
                NSLog(@"%@ 前端收到事件后的回调: %@", weakself.callbackName,responseData);
            }];
        }
    });
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
