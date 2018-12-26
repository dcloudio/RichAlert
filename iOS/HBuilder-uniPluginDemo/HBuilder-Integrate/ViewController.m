//
//  ViewController.m
//  Pandora
//
//  Created by Mac Pro_C on 12-12-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "ViewController.h"
#import "WebViewController.h"
#import "WebAppController.h"
#import "PDRCore.h"

@interface ViewController ()
{
    WebViewController* pWebViewController;
    WebAppController* pWebAppController;
}

@end


@implementation ViewController


#pragma mark 应用集成


-(IBAction)ShowWebViewPageOne:(id)sender
{
    if ( PDRCoreRunModeWebviewClient != [PDRCore Instance].runMode ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"请在appdelegate切换启动模式为PDRCoreRunModeWebviewClient"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    pWebViewController = [[WebViewController alloc] init];
    if (pWebViewController)
    {
        [self.navigationController pushViewController:pWebViewController animated:YES];
        [pWebViewController release];
    }
    
    // 添加一个原生层的消息监听，可以监听页面中通过NJS发送的消息，并获取附带的数据
    // NJS 发送消息请参考Pandora/apps/HelloH5/plugin.html 文件的PostNotification方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotiFunction:) name:@"SendDataToNative" object:nil];
}


- (void)NotiFunction:(NSNotification*)pNoti
{
    if (pNoti) {
        NSString* pRecData = pNoti.object;
        if (pRecData) {
            NSLog(@"Native Receive Data:%@", pRecData);
            UIAlertView* pAlertView = [[UIAlertView alloc] initWithTitle:@"原生层收到消息" message:pRecData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            if (pAlertView) {
                [pAlertView show];
                [pAlertView release];
            }
        }
    }
}



-(IBAction)ShowWebViewPageTwo:(id)sender
{
    if ( PDRCoreRunModeAppClient != [PDRCore Instance].runMode ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"请在appdelegate切换启动模式为PDRCoreRunModeAppClient"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // Webivew集成不能同时WebApp集成，需要修改AppDelegate文件的PDRCore的启动参数
    pWebAppController = [[WebAppController alloc] init];
    if (pWebAppController) {
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:pWebAppController animated:YES];
        [pWebAppController release];
    }
}



- (void)didReceiveMemoryWarning{
    [[PDRCore Instance] handleSysEvent:PDRCoreSysEventReceiveMemoryWarning withObject:nil];
}

- (void)dealloc {
    [super dealloc];
}


@end
