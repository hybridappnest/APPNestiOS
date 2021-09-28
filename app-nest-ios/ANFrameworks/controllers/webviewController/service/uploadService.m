//
//  uploadService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "uploadService.h"
#import "ANFrameworks.h"

@implementation uploadService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [self dealAction:webview message:message];
    }
    return self;
}

- (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    __weak uploadService *weakself = self;
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSArray *data = [params valueForKey:@"data"];
        if (data && [data isKindOfClass:[NSArray class]]) {
            [self uploadDatas:data block:^(NSArray *urls, NSError *error) {
                if (urls) {
                    if (weakself && weakself.callbackName && weakself.callbackName.length > 0) {
                        [weakself callback:urls];
                    }
                }
            }];
        }
    }
}

- (void) uploadDatas:(NSArray*) array block:(void (^) (NSArray *urls,NSError *error))cb {
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *urlString = [array objectAtIndex:i];
        NSData *data = [NSData dataWithContentsOfFile:urlString];
        if (data) {
            NSURL *fileURL = [NSURL fileURLWithPath:urlString];
            NSString *lastPath = fileURL.lastPathComponent;
            __block NSString *suffix = [fileURL pathExtension];
            NSString *name = [lastPath stringByReplacingOccurrencesOfString:suffix withString:@"" options:NSLiteralSearch range:NSMakeRange(0, lastPath.length)];
            NSString *objectKey = [NSString stringWithFormat:@"uploadedFiles/%@",name];
            if ([objectKey containsString:@"."]) {
                objectKey = [objectKey stringByReplacingOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, objectKey.length)];
            }
            [[OSSUpload sharedInstance] uploadData:data objectKey:objectKey success:^(NSString *url) {
                [urls addObject:url];
                if (urls.count >= array.count) {
                    cb(urls,nil);
                }
            } failure:^(NSError *error) {
                cb(nil,error);
            }];
        }
    }
}

- (void) callback:(NSArray* _Nonnull) urls {
    __weak uploadService *weakself = self;
    NSDictionary *data = @{@"data":urls,@"announce":[NSNumber numberWithInteger:self.announce]};
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakself && weakself.webController) {
            WebViewController *controller = (WebViewController*)weakself.webController;
            [controller callHandler:weakself.callbackName data:data responseCallback:^(id responseData,NSError *error) {
                NSLog(@"%@ 前端收到事件后的回调: %@", weakself.callbackName,responseData);
            }];
        }
    });
}

@end
