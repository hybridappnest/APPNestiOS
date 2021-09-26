//
//  NetworkingStatus.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.
//

#import "NetworkingStatus.h"
#import "ANFrameworks.h"

NSString *const NetConnectionNotification = @"NetConnectionNotification";

typedef enum : NSUInteger {
    net_type_error,
    net_type_wifi,
    net_type_viaWWWAN,
    net_type_Unknown
} NetStatus;

static NetStatus networkStatus;

static BOOL isRestricted;

@implementation NetworkingStatus

+ (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
            {
                networkStatus = net_type_Unknown;
                [[NSNotificationCenter defaultCenter] postNotificationName:NetConnectionNotification object:[NSNumber numberWithInteger:networkStatus]];
                NSLog(@"AFNetworkReachabilityStatusUnknown");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
            {
                networkStatus = net_type_error;
                [[NSNotificationCenter defaultCenter] postNotificationName:NetConnectionNotification object:[NSNumber numberWithInteger:networkStatus]];
                NSLog(@"AFNetworkReachabilityStatusNotReachable");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
            {
                networkStatus = net_type_viaWWWAN;
                [[NSNotificationCenter defaultCenter] postNotificationName:NetConnectionNotification object:[NSNumber numberWithInteger:networkStatus]];
                NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
            {
                networkStatus = net_type_wifi;
                [[NSNotificationCenter defaultCenter] postNotificationName:NetConnectionNotification object:[NSNumber numberWithInteger:networkStatus]];
                NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
            }
                break;
        }
    }];
    //开始监听
    [mgr startMonitoring];
}

+ (NSInteger) networkStatus{
    return networkStatus;
}

+(BOOL) isNetError:(NSInteger) code{
    if (networkStatus == net_type_error) {
        return YES;
    }
    if (code == 400) {
        return YES;
    }
    if (code == 401) {
        return YES;
    }
    if (code == 403) {
        return YES;
    }
    if (code == 404) {
        return YES;
    }
    if (code == 405) {
        return YES;
    }
    if (code == 406) {
        return YES;
    }
    if (code == 407) {
        return YES;
    }
    if (code == 410) {
        return YES;
    }
    if (code == 410) {
        return YES;
    }
    if (code == 411) {
        return YES;
    }
    if (code == 414) {
        return YES;
    }
    if (code == 500) {
        return YES;
    }
    if (code == 501) {
        return YES;
    }
    if (code == 502) {
        return YES;
    }
    if (code == 502) {
        return YES;
    }
    if(code ==  NSURLErrorBadServerResponse){
        return NO;
    }
    if(code >= NSURLErrorAppTransportSecurityRequiresSecureConnection && code <= NSURLErrorBadURL){
        return YES;
    }
    if(code >= NSURLErrorDataLengthExceedsMaximum && code <= NSURLErrorFileDoesNotExist){
        return YES;
    }
    if(code >= NSURLErrorClientCertificateRequired && code <= NSURLErrorSecureConnectionFailed){
        return YES;
    }
    if(code == NSURLErrorCannotLoadFromNetwork || code == NSURLErrorDownloadDecodingFailedMidStream || code == NSURLErrorDownloadDecodingFailedToComplete ){
        return YES;
    }
    return NO;
}



+(NSString*) netErrorTip:(NSInteger) code{
    if (networkStatus == net_type_error) {
        return @"当前网络不可用";
    }
    if (code == 400) {
        return @"无效请求";
    }
    if (code == 401) {
        return @"未授权：登录失败";
    }
    if (code == 403) {
        return @"请求资源不可用";
    }
    if (code == 404) {
        return @"请求资源不存在";
    }
    if (code == 405) {
        return @"请求资源不支持该请求方式";
    }
    if (code == 406) {
        return @"请求资源类型不被允许";
    }
    if (code == 407) {
        return @"要求代理身份验证";
    }
    if (code == 410) {
        return @"请求资源不可用";
    }
    if (code == 410) {
        return @"请求资源不可用";
    }
    if (code == 411) {
        return @"服务器不能处理该请求";
    }
    if (code == 414) {
        return @"请求路径太长";
    }
    if (code == 500) {
        return @"服务器内部错误";
    }
    if (code == 501) {
        return @"服务器不支持请求所需要的功能";
    }
    if (code == 502) {
        return @"网管错误";
    }
    if (code == 502) {
        return @"网管错误";
    }
   
    if(code == NSURLErrorUnknown){
        return @"未知错误";
    }
    if(code == NSURLErrorCancelled){
        return @"网络连接已取消";
    }
    if(code == NSURLErrorBadURL){
        return @"错误的URl";
    }
    if(code == NSURLErrorTimedOut){
        return @"网络连接超时";
    }
    if(code == NSURLErrorUnsupportedURL){
        return @"不支持的URl";
    }
    if(code == NSURLErrorCannotFindHost){
        return @"找不到主机";
    }
    if(code == NSURLErrorCannotConnectToHost){
        return @"无法连接到主机";
    }
    if(code == NSURLErrorNetworkConnectionLost){
        return @"网络连接丢失";
    }
    if(code == NSURLErrorDNSLookupFailed){
        return @"DNS解析错误";
    }
    if(code == NSURLErrorHTTPTooManyRedirects){
        return @"HTTP重定向太多";
    }
    if(code == NSURLErrorResourceUnavailable){
        return @"资源不可用";
    }
    if(code == NSURLErrorNotConnectedToInternet){
        return @"无法连接到网络";
    }
    if(code == NSURLErrorRedirectToNonExistentLocation){
        return @"重定向到不存在的位置";
    }
    if(code == NSURLErrorBadServerResponse){
        return @"错误的服务器响应";
    }
    if(code == NSURLErrorUserCancelledAuthentication){
        return @"用户取消授权";
    }
    if(code == NSURLErrorUserAuthenticationRequired){
        return @"需要用户授权";
    }
    if(code == NSURLErrorZeroByteResource){
        return @"零字节资源";
    }
    if(code == NSURLErrorCannotDecodeRawData){
        return @"原始数据解码错误";
    }
    if(code == NSURLErrorCannotDecodeContentData){
        return @"内容数据解码错误";
    }
    if(code == NSURLErrorCannotParseResponse){
        return @"无法解析响应";
    }
    if(code == NSURLErrorAppTransportSecurityRequiresSecureConnection){
        return @"需要HTTPS安全连接";
    }
    if(code == NSURLErrorFileDoesNotExist){
        return @"文件不存在";
    }
    if(code == NSURLErrorFileIsDirectory){
        return @"不是文件格式";
    }
    if(code == NSURLErrorNoPermissionsToReadFile){
        return @"没有权限读文件";
    }
    if(code == NSURLErrorDataLengthExceedsMaximum){
        return @"数据长度超过最大值";
    }

    if(code == NSURLErrorDataLengthExceedsMaximum){
        return @"数据长度超过最大值";
    }
    if (@available(iOS 10.3, *)) {
        if(code == NSURLErrorFileOutsideSafeArea){
            return @"安全区外文件";
        }
    } else {
        // Fallback on earlier versions
        return @"安全区外文件";
    }
    if(code == NSURLErrorSecureConnectionFailed){
        return @"SSL安全连接失败";
    }
    if(code == NSURLErrorServerCertificateHasBadDate){
        return @"服务器证书时间错误";
    }
    if(code == NSURLErrorServerCertificateUntrusted){
        return @"服务器证书不被信任";
    }
    if(code == NSURLErrorServerCertificateHasUnknownRoot){
        return @"服务器证书找不到根证书";
    }
    if(code == NSURLErrorServerCertificateNotYetValid){
        return @"服务器证书不再有效";
    }
    if(code == NSURLErrorServerCertificateNotYetValid){
        return @"服务器证书不再有效";
    }
    if(code == NSURLErrorClientCertificateRejected){
        return @"客户端证书被拒绝";
    }
    if(code == NSURLErrorClientCertificateRequired){
        return @"需要客户端证书";
    }
    if(code == NSURLErrorCannotLoadFromNetwork){
        return @"无法从网络加载内容";
    }
    if(code == NSURLErrorCannotCreateFile){
        return @"无法创建文件";
    }
    if(code == NSURLErrorCannotOpenFile){
        return @"无法打开文件";
    }
    if(code == NSURLErrorCannotCloseFile){
        return @"无法关闭文件";
    }
    if(code == NSURLErrorCannotWriteToFile){
        return @"无法写文件";
    }
    if(code == NSURLErrorCannotRemoveFile){
        return @"无法删除文件";
    }
    if(code == NSURLErrorCannotMoveFile){
        return @"无法移动文件";
    }
    if(code == NSURLErrorDownloadDecodingFailedMidStream || code == NSURLErrorDownloadDecodingFailedToComplete){
        return @"下载解码错误";
    }
    
    if(code == NSURLErrorInternationalRoamingOff){
        return @"国际漫游关闭";
    }
    if(code == NSURLErrorCallIsActive){
        return @"呼叫被激活";
    }
    if(code == NSURLErrorDataNotAllowed){
        return @"数据不备允许";
    }
    if(code == NSURLErrorRequestBodyStreamExhausted){
        return @"请求正文流耗尽";
    }
    if(code == NSURLErrorBackgroundSessionRequiresSharedContainer){
        return @"后台会话需要共享容器";
    }
    if(code == NSURLErrorBackgroundSessionInUseByAnotherProcess){
        return @"在另一进程中使用的后台会话";
    }
    if(code == NSURLErrorBackgroundSessionWasDisconnected){
        return @"后台会话被关闭";
    }
    return @"网络异常";
}


@end
