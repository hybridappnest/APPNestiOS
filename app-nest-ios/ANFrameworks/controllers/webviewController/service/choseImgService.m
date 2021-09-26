//
//  choseImgService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "choseImgService.h"
#import "ANFrameworks.h"

@implementation choseImgService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [self dealAction:webview message:message];
    }
    return self;
}

- (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = [NSDictionary convertNull:[params valueForKey:@"data"]];
        NSString *needvideoString = [data valueForKey:@"needvideo"];
        BOOL defaultnNeedvideo = YES;
        if (needvideoString) {
            defaultnNeedvideo = [needvideoString boolValue];
        }
        NSNumber *needvideo = [NSNumber numberWithBool:defaultnNeedvideo];
        NSInteger maxnum = [[data valueForKey:@"maxnum"] integerValue];
        if (maxnum <= 0) {
            maxnum = 9;
        }
        __weak choseImgService *weakself = self;
        NSDictionary *dic = @{@"onlyAlum":@NO,@"allowsEditing":@NO,@"onlyTakePhone":@NO,@"isAlumHaveVideo":needvideo,@"delegate":self,@"maxSelectNum":[NSNumber numberWithInteger:maxnum]};
        DBXImagePicker *imagePicker = [[DBXImagePicker alloc] initWithData:dic withCompletion:^(NSArray * _Nonnull medias, NSArray * _Nonnull urls,NSArray * _Nonnull images) {
            if (!medias) {
                return;
            }
            [weakself uploadDatas:medias block:^(NSArray *array) {
                if (weakself && weakself.callbackName && weakself.callbackName.length > 0) {
                    [weakself callback:array];
                }
            }];
        }];
        [imagePicker showImagePicker];
    }
}

- (void) uploadDatas:(NSArray*) datas block:(void (^) (NSArray *array))cb {
    if (datas.count <= 0) {
        return;
    }
    NSDictionary *dataInfo = [datas objectAtIndex:0];
    if (![dataInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *urlString = [NSString convertNull:[dataInfo valueForKey:@"url"]];
    NSInteger type = [[dataInfo valueForKey:@"type"] integerValue];
    if (type == 0) {
        return;
    }
    if (!(urlString && urlString.length > 0)) {
        return;
    }
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] initWithDictionary:dataInfo];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    NSURL *fileURL = [NSURL fileURLWithPath:urlString];
    NSString *lastPath = fileURL.lastPathComponent;
    if (type == take_video) {
        if ([lastPath containsString:@"MOV"] || [lastPath containsString:@"mov"]) {
            [self uploadMOV:dataInfo block:^(NSDictionary *dic) {
                if (dic) {
                    [returnArray addObject:dic];
                    cb(returnArray);
                }
            }];
        } else {
            [self uploadVideo:dataInfo block:^(NSDictionary *dic) {
                if (dic) {
                    [returnArray addObject:dic];
                    cb(returnArray);
                }
            }];
        }
    } else {
        NSString *objectKey = [self createObjectKey:fileURL];
        NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
        [[OSSUpload sharedInstance] uploadData:imageData objectKey:objectKey success:^(NSString *url) {
            if (url) {
                [returnDic setValue:url forKey:@"url"];
                                                    
                if ([[NSFileManager defaultManager] fileExistsAtPath:urlString]) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:urlString error:&error];
                }
                [returnArray addObject:returnDic];
                cb(returnArray);
            }
        } failure:^(NSError *error) {
            cb(nil);
        }];
    }
}

- (NSString*) createObjectKey:(NSURL*) url {
    NSString *lastPath = url.lastPathComponent;
    NSString *suffix = [url pathExtension];
    NSString *name = [lastPath stringByReplacingOccurrencesOfString:suffix withString:@"" options:NSLiteralSearch range:NSMakeRange(0, lastPath.length)];
    NSString *objectKey = [NSString stringWithFormat:@"uploadedFiles/%@",name];
    if ([objectKey containsString:@"."]) {
        objectKey = [objectKey stringByReplacingOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, objectKey.length)];
    }
    return objectKey;
}

- (void) uploadMOV:(NSDictionary*) dataInfo block:(void (^) (NSDictionary *dic))cb{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] initWithDictionary:dataInfo];
    NSString *urlString = [NSString convertNull:[returnDic valueForKey:@"url"]];
    NSURL *fileURL = [NSURL fileURLWithPath:urlString];
    BOOL is_library = [[dataInfo valueForKey:@"is_library"] boolValue];
    [AVAsset mov2mp4:fileURL needComposition:is_library block:^(BOOL flag, NSString * _Nonnull resultPath) {
        if (flag) {
            NSURL *resultUrl = [NSURL fileURLWithPath:resultPath];
            NSData *videoData = [NSData dataWithContentsOfURL:resultUrl];
            if (videoData) {
                NSString *objectKey = [self createObjectKey:resultUrl];
                [[OSSUpload sharedInstance] uploadData:videoData objectKey:objectKey success:^(NSString *url) {
                    if (url) {
                        [returnDic setValue:url forKey:@"url"];
                        
                        if ([[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
                            NSError *error = nil;
                            [[NSFileManager defaultManager] removeItemAtPath:resultPath error:&error];
                        }
                        NSString *coverUrlString = [NSString convertNull:[returnDic valueForKey:@"coverUrl"]];
                        if ((coverUrlString && coverUrlString.length > 0)) {
                            NSURL *fileUrl = [NSURL URLWithString:coverUrlString];
                            NSString *objectKey = [self createObjectKey:fileUrl];
                            NSData *imageData = [NSData dataWithContentsOfURL:fileUrl];
                            [[OSSUpload sharedInstance] uploadData:imageData objectKey:objectKey success:^(NSString *url) {
                                if (url) {
                                    [returnDic setValue:url forKey:@"coverUrl"];
                                                                        
                                    if ([[NSFileManager defaultManager] fileExistsAtPath:coverUrlString]) {
                                        NSError *error = nil;
                                        [[NSFileManager defaultManager] removeItemAtPath:coverUrlString error:&error];
                                    }
                                    
                                    cb(returnDic);
                                }
                            } failure:^(NSError *error) {
                                cb(nil);
                            }];
                        }
                    }
                } failure:^(NSError *error) {
                    cb(nil);
                }];
            }
        }
    }];
}

- (void) uploadVideo:(NSDictionary*) dataInfo block:(void (^) (NSDictionary *dic))cb{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] initWithDictionary:dataInfo];
    NSString *urlString = [NSString convertNull:[returnDic valueForKey:@"url"]];
    NSURL *fileURL = [NSURL fileURLWithPath:urlString];
    
    NSData *videoData = [NSData dataWithContentsOfURL:fileURL];
    if (videoData) {
        NSString *objectKey = [self createObjectKey:fileURL];
        [[OSSUpload sharedInstance] uploadData:videoData objectKey:objectKey success:^(NSString *url) {
            if (url) {
                [returnDic setValue:url forKey:@"url"];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:urlString]) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:urlString error:&error];
                }
                NSString *coverUrlString = [NSString convertNull:[returnDic valueForKey:@"coverUrl"]];
                if ((coverUrlString && coverUrlString.length > 0)) {
                    NSURL *fileUrl = [NSURL URLWithString:coverUrlString];
                    NSString *objectKey = [self createObjectKey:fileUrl];
                    NSData *imageData = [NSData dataWithContentsOfURL:fileUrl];
                    [[OSSUpload sharedInstance] uploadData:imageData objectKey:objectKey success:^(NSString *url) {
                        if (url) {
                            [returnDic setValue:url forKey:@"coverUrl"];
                                                                
                            if ([[NSFileManager defaultManager] fileExistsAtPath:coverUrlString]) {
                                NSError *error = nil;
                                [[NSFileManager defaultManager] removeItemAtPath:coverUrlString error:&error];
                            }
                            
                            cb(returnDic);
                        }
                    } failure:^(NSError *error) {
                        cb(nil);
                    }];
                }
            }
        } failure:^(NSError *error) {
            cb(nil);
        }];
    }
}

- (void) callback:(NSArray* _Nonnull) images {
    __weak choseImgService *weakself = self;
    NSDictionary *data = @{@"data":images,@"announce":[NSNumber numberWithInteger:self.announce]};
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
