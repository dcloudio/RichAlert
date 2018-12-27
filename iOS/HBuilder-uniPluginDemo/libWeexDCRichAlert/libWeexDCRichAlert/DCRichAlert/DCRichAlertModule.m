//
//  DCRichAlertModule.m
//  libWeexDCRichAlert
//
//  Created by XHY on 2018/12/21.
//  Copyright © 2018 DCloud. All rights reserved.
//

#import "DCRichAlertModule.h"
#import "WXUtility.h"
#import "DCRichAlertView.h"

@interface DCRichAlertModule ()
@property (nonatomic, weak) DCRichAlertView *alertView;
@end

@implementation DCRichAlertModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(show:callback:))
WX_EXPORT_METHOD(@selector(dismiss))

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        /* 监听App停止运行事件，如果alert存在，调一下dismiss方法移除 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"PDRCoreAppDidStopedKey" object:nil];
    }
    return self;
}

- (void)_show:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    DCRichAlertView *alertView = [DCRichAlertView alertWithOptions:options
                                                          callback:^(NSDictionary *result) {
                                                              if (callback) {
                                                                  callback(result,YES);
                                                              }
                                                          }];
    self.alertView = alertView;
    [alertView show];
}


#pragma mark - Export Method

- (void)show:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    [self _show:options callback:callback];
}

- (void)dismiss
{
    [self.alertView dismiss];
}

@end
