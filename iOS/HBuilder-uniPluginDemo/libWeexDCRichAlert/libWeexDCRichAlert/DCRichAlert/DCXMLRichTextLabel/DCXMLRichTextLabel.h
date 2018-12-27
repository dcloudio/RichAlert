//
//  DCXMLRichTextLabel.h
//  WeexTest
//
//  Created by XDC on 2018/12/21.
//  Copyright © 2018 DCloud. All rights reserved.
//
/**
 说明：自动解析xml生成富文本Label
 支持解析xml字符串，将 <a></a> 标签作为可点击链接处理，点击后返回 <a href='http://xxx.xxx.com' id='123'></a> 标签上所有属性的 json => {href:'',id:'123'}
 如果解析失败则将原 xml 字符串显示
 */

#import "DC_TTTAttributedLabel.h"

@protocol DCXMLRichTextLabelDeletate <NSObject>


/**
 点击A标签的链接回调方法，返回A标签上所有属性json

 @param attribute A标签属性json
 */
- (void)clickedALabelWithAttribute:(NSDictionary *)attribute;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DCXMLRichTextLabel : DC_TTTAttributedLabel

/**
 代理
 */
@property (nonatomic, weak) id<DCXMLRichTextLabelDeletate> xmlDelegate;

/**
 加载xmlStirng，解析完后会自动执行绘制文本，并根据文字自动调整frame

 @param xmlStr xml字符串
 */
- (void)loadXMLString:(NSString *)xmlStr;

@end

NS_ASSUME_NONNULL_END
