//
//  OSSUpload.h
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/OSSClient.h>

#define AliOSS  (@"AliOSS")
#define AliAccessIdKey            (@"access_id")
#define AliOssEndPointKey         (@"oss_endpoint")
#define AliAccessKeyKey           (@"access_key")
#define AliOssCnameKey            (@"oss_cname")
#define AliAccessBucketNameKey    (@"access_bucketName")
#define AliProxyHostKey           (@"proxyHost")
#define AliProxyPortKey           (@"proxyPort")
#define AliExpireDateKey          (@"expireDate")
#define AliIsProxyKey             (@"isProxy")


@interface OSSUpload : NSObject

@property (nonatomic,strong) NSString *bucketName;

@property (nonatomic, strong) OSSClient *client;

+ (instancetype)sharedInstance;


/*＊
 describe：上传OSS
 @param：imgData:数据
 @param：bucketName:存储桶
 @param：objectKey:目标路径
 @param：success:成功回调
 @param：failure:失败回调
 return：N/A
 */

- (void) uploadData:(NSData*)data objectKey:(NSString*)objectKey success:(void (^)(NSString *url))success failure:(void (^)(NSError *error))failure;


@end
