//
//  showGalleryService.m
//  app-nest-ios
//
//  Created by brent on 2021/9/16.
//

#import "showGalleryService.h"
#import "ANFrameworks.h"
#import "YBIBDefaultWebImageMediator.h"

@implementation showGalleryService

- (instancetype) initWithWebview:(WebViewController *)webview message:(NSDictionary *)message model:(nonnull JSServiceModel *)model {
    self = [super initWithWebview:webview message:message model:model];
    if (self) {
        [showGalleryService dealAction:webview message:message];
    }
    return self;
}

+ (void) dealAction:(WebViewController *)webview message:(NSDictionary *)message {
    NSDictionary *params = [message valueForKey:@"params"];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = [params valueForKey:@"data"];
        NSDictionary *realdata = [data valueForKey:@"data"];
        if ([realdata isKindOfClass:[NSString class]]) {
            NSString *dataString = [NSString convertNull:[data valueForKey:@"data"]];
            if (dataString && dataString.length > 0) {
                realdata = [NSDictionary convertNull:[Tool toJSONData:dataString]];
            }
        }
        
        NSArray *assets = [NSArray convertNull:[realdata valueForKey:@"data"]];
        NSInteger index = [[NSString convertNull:[realdata valueForKey:@"index"]] integerValue];
        
        NSMutableArray *datas = [NSMutableArray array];
        
        for (NSDictionary *assetInfo in assets) {
            NSInteger type = [[NSString convertNull:[assetInfo valueForKey:@"type"]] integerValue];
            NSString *url = [NSString convertNull:[assetInfo valueForKey:@"url"]];
            if (type == 1) {
                //视频
                YBIBVideoData *data = [YBIBVideoData new];
                data.videoURL = [NSURL URLWithString:url];
                if (data) {
                    [datas addObject:data];
                }
            } else {
                //图片
                YBIBImageData *data = [YBIBImageData new];
                data.imageURL = [NSURL URLWithString:url];
                if (data) {
                    [datas addObject:data];
                }
            }
        }
        
        if (datas.count <= 0) {
            return;
        }
        if (index < 0 || index >= datas.count) {
            return;
        }
        id tempData = [datas objectAtIndex:index];
        if ([tempData isKindOfClass:[YBIBVideoData class]]) {
            YBIBVideoData *tempVideo = (YBIBVideoData*)tempData;
            tempVideo.autoPlayCount = 1;
        }
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.webImageMediator = [YBIBDefaultWebImageMediator new];
        browser.dataSourceArray = datas;
        browser.currentPage = index;
        // 只有一个保存操作的时候，可以直接右上角显示保存按钮
        browser.defaultToolViewHandler.topView.operationType = YBIBTopViewOperationTypeSave;
        [browser show];
    }
}

@end
