//
//  DCRichAlertView.h
//  libWeexDCRichAlert
//
//  Created by XHY on 2018/12/24.
//  Copyright © 2018 DCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DCAlertCallback)(NSDictionary *result);

NS_ASSUME_NONNULL_BEGIN

@interface DCRichAlertView : UIControl

+ (DCRichAlertView *)alertWithOptions:(NSDictionary *)options callback:(DCAlertCallback)callback;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
