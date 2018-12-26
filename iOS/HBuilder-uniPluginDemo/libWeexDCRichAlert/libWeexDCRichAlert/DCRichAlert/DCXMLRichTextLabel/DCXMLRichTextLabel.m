//
//  DCXMLRichTextLabel.m
//  WeexTest
//
//  Created by XHY on 2018/12/21.
//  Copyright © 2018 DCloud. All rights reserved.
//

#import "DCXMLRichTextLabel.h"

NSString *const _kDCXMLRichTextLabelLabelName = @"_kDCXMLRichTextLabelLabelName";
NSString *const _kDCXMLRichTextLabelLabelAttribute = @"_kDCXMLRichTextLabelLabelAttribute";
NSString *const _kDCXMLRichTextLabelLabelValue = @"_kDCXMLRichTextLabelLabelValue";
NSString *const _kDCXMLRichTextLabelALabelTextRange = @"_kDCXMLRichTextLabelALabelTextRange";

@interface DCXMLRichTextLabel () <DC_TTTAttributedLabelDelegate,NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray *richTextArray;
@property (nonatomic, strong) NSMutableDictionary *richTextNode;
@property (nonatomic, copy) NSString *content;

@end

@implementation DCXMLRichTextLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initDefault];
    }
    return self;
}

// 初始化默认参数
- (void)initDefault {
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    self.font = [UIFont systemFontOfSize:14];
    self.textAlignment = NSTextAlignmentCenter;
    self.lineSpacing = 5;
    self.linkAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor],NSUnderlineStyleAttributeName:@(1)};
    self.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSUnderlineStyleAttributeName:@(1)};
}

// 加载原始xml字符串
- (void)loadText {
    
    self.text = self.content;
    
    [self layoutAttributedLabel];
}

// 加载富文本
- (void)loadRichText {
    NSMutableArray *aLabelArray = [NSMutableArray array];
    NSString *result = @"";
    // 遍历所有节点
    for (NSDictionary *item in self.richTextArray) {
        NSString *labelValue = item[_kDCXMLRichTextLabelLabelValue];
        // 如果当前节点不存在文本信息则跳过
        if (!labelValue) {
            continue;
        }
        
        // 当前标签为 a 标签，计算好Range，然后保存到aLabelArray数组中
        if (item[_kDCXMLRichTextLabelLabelName] && [item[_kDCXMLRichTextLabelLabelName] isEqualToString:@"a"]) {
            NSMutableDictionary *aLabel = [NSMutableDictionary dictionaryWithDictionary:item];
            NSRange range = NSMakeRange(result.length, labelValue.length);
            [aLabel setValue:NSStringFromRange(range) forKey:_kDCXMLRichTextLabelALabelTextRange];
            [aLabelArray addObject:aLabel];
        }
        // 拼接需要显示的完整字符串
        result = [result stringByAppendingString:labelValue];
    }
    
    self.text = result;
    
    [self layoutAttributedLabel];
    
    // 遍历 aLabelArray 为所有 a 标签添加点击链接，并设置回调参数为标签对于的所有属性
    for (NSDictionary *item in aLabelArray) {
        [self addLinkToTransitInformation:item[_kDCXMLRichTextLabelLabelAttribute] withRange:NSRangeFromString(item[_kDCXMLRichTextLabelALabelTextRange])];
    }
    
}

// 根据文本内容设置Label大小
- (void)layoutAttributedLabel {
    CGSize textSize = [self systemLayoutSizeFittingSize:CGSizeMake(self.frame.size.width, MAXFLOAT)];
    CGRect rect = self.frame;
    rect.size = textSize;
    self.frame = rect;
}

#pragma mark - NSXMLParser
// 解析xml
- (void)XMLParserWithData:(NSData *)data {
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    xmlParser.delegate = self;
    [xmlParser parse];
}

//- (void)parserDidStartDocument:(NSXMLParser *)parser {
//    NSLog(@"解析开始");
//}

// xml解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self checkRichTextNodeStatus];
    [self loadRichText];
}

// 解析每个标签属性的回调方法
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    [self checkRichTextNodeStatus];
    
    // 获取标签名字及标签的所有属性
    [self.richTextNode setValue:elementName forKey:_kDCXMLRichTextLabelLabelName];
    [self.richTextNode setValue:attributeDict forKey:_kDCXMLRichTextLabelLabelAttribute];
}

// 解析标签中的文本信息回调方法
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    // 判断如果之前的标签已经存在文本信息则保存一下当前的节点
    if (self.richTextNode[_kDCXMLRichTextLabelLabelValue]) {
        [self checkRichTextNodeStatus];
    }
    
    [self.richTextNode setValue:string forKey:_kDCXMLRichTextLabelLabelValue];
}

//- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
//    NSLog(@"%@",comment);
//}

//- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value {
//    NSLog(@"%@ %@",name,value);
//}

// 每个标签解析结束回调
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [self checkRichTextNodeStatus];
}

// 如果xml解析失败则直接加载原始xml字符串
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self loadText];
}

//- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
//    NSLog(@"%@",validationError);
//}

// 检查是否需要将当前node放入 richTextArray 中，作为一个节点
- (void)checkRichTextNodeStatus {
    if (self.richTextNode.count) {
        [self.richTextArray addObject:[NSDictionary dictionaryWithDictionary:self.richTextNode]];
        // 放入后清空 self.richTextNode，给下一个节点使用
        [self.richTextNode removeAllObjects];
    }
}

#pragma mark - TTTAttributedLabelDelegate
// 点击链接文本回调方法
- (void)attributedLabel:(DC_TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    if (self.xmlDelegate && [self.xmlDelegate respondsToSelector:@selector(clickedALabelWithAttribute:)]) {
        [self.xmlDelegate clickedALabelWithAttribute:components];
    }
}

#pragma mark setter and getter
- (NSMutableArray *)richTextArray {
    if (!_richTextArray) {
        _richTextArray = [[NSMutableArray alloc] init];
    }
    return _richTextArray;
}

- (NSMutableDictionary *)richTextNode {
    if (!_richTextNode) {
        _richTextNode = [[NSMutableDictionary alloc] init];
    }
    return _richTextNode;
}

#pragma mark - Public Func
- (void)loadXMLString:(NSString *)xmlStr {
    
    // 保存原始字符串
    self.content = xmlStr;
    xmlStr = [NSString stringWithFormat:@"<hyroot>%@</hyroot>",xmlStr];
    NSData *xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [self XMLParserWithData:xmlData];
    
}

@end
