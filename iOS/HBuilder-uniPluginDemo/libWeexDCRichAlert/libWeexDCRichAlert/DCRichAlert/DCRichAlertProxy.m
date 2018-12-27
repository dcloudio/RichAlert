//
//  DCRichAlertProxy.m
//  libWeexDCRichAlert
//
//  Created by 4Ndf on 2018/12/24.
//  Copyright © 2018年 DCloud. All rights reserved.
//

#import "DCRichAlertProxy.h"

@implementation DCRichAlertProxy
-(void)onCreateUniPlugin{
    NSLog(@"TestPlugin 有需要初始化的路径可以放这里！");
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    NSLog(@"TestPlugin 有需要didFinishLaunchingWithOptions可以放这里！");
    return YES;
}
@end
