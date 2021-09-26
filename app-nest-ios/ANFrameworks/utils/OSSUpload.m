//
//  OSSUpload.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "OSSUpload.h"
#import "ANFrameworks.h"

@implementation OSSUpload

+ (instancetype)sharedInstance{
    static OSSUpload *bizService;
    static dispatch_once_t llSOnceToken;
    dispatch_once(&llSOnceToken, ^{
        bizService = [[self alloc] init];
    });
    return bizService;
}

- (BOOL) initOSSClient{
    if (_client) {
        return YES;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *ossConfig = [NSDictionary convertNull:[dic valueForKey:@"oss"]];
    if (ossConfig.count <= 0) {
        [DBXToast showToast:@"没有配置oss参数，请在config.plist中配置" success:NO];
        return NO;
    }
    
    _bucketName = [NSString convertNull:[ossConfig valueForKey:@"bucketName"]];
    if (!(_bucketName && _bucketName.length > 0)) {
        [DBXToast showToast:@"没有配置bucketName，请在config.plist中配置" success:NO];
        return NO;
    }
    NSString *endpoint = [NSString convertNull:[ossConfig valueForKey:@"endpoint"]];
    if (!(endpoint && endpoint.length > 0)) {
        [DBXToast showToast:@"没有配置endpoint，请在config.plist中配置" success:NO];
        return NO;
    }
    NSString *authUrl = [NSString convertNull:[ossConfig valueForKey:@"authUrl"]];
    if (!(authUrl && authUrl.length > 0)) {
        [DBXToast showToast:@"没有配置authUrl，请在config.plist中配置" success:NO];
        return NO;
    }
    
    id<OSSCredentialProvider> credential = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:authUrl];
    _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    return YES;
}

- (void) uploadData:(NSData*)data objectKey:(NSString*)objectKey success:(void (^)(NSString *url))success failure:(void (^)(NSError *error))failure{
    __weak OSSUpload *weakself = self;
    if(![self initOSSClient]) {
        return;
    }
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = _bucketName;
    put.objectKey = objectKey;
    put.uploadingData = data; // 直接上传NSData
    
    OSSTask * putTask = [_client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
            OSSTask *presignTask = [weakself.client presignPublicURLWithBucketName:weakself.bucketName withObjectKey:objectKey];
            [presignTask continueWithBlock:^id(OSSTask *tempTask) {
                if (!tempTask.error) {
                    NSString *publicURL = tempTask.result;
                    NSLog(@"publicURL %@",publicURL);
                    if(success){
                        success(publicURL);
                    }
                } else {
                    NSLog(@"sign url error: %@", tempTask.error);
                    if(failure){
                        failure(tempTask.error);
                    }
                }
                return nil;
            }];
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
            if(failure){
                failure(task.error);
            }
        }
        return nil;
    }];
}

@end
