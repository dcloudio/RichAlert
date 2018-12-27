//
//  DCRichAlertView.m
//  libWeexDCRichAlert
//
//  Created by XHY on 2018/12/24.
//  Copyright © 2018 DCloud. All rights reserved.
//

#import "DCRichAlertView.h"
#import "DCXMLRichTextLabel.h"
#import "WXConvert.h"
#import "BEMCheckBox.h"

// 弹窗的宽度
#define kDCAlertViewDefaultCenterPopupViewWidth ([UIScreen mainScreen].bounds.size.width - 80.0)
#define kDCAlertViewDefaultPopupViewRowHeight 55.0
#define kDCAlertViewDefaultPopupFooterViewHeight 50.0
#define kDCAlertViewDefaultPopupViewAnimationDuration 0.25

#define kDCAlertViewMaxHeight ([UIScreen mainScreen].bounds.size.height * 2/3)
#define kDCAlertViewTopPadding 20.0
#define kDCAlertViewTopSpace 15.0

#define kDCAlertViewCheckBoxWidth 16.0

// 文字标题、内容两边的留白宽度
#define kDCAlertViewPadding 20.0

// 默认颜色
#define kDCAlertViewDefaultTextColor [UIColor blackColor]
#define kDCAlertViewDefaultButtonTextColor [UIColor blackColor]
#define kDCAlertViewDefaultLineColor @"#dfe1eb"

// 字体大小
#define kDCAlertViewDefaultTitleFontSize 16
#define kDCAlertViewDefaultContentFontSize 14
#define kDCAlertViewDefaultButtonTitleFontSize 15

#define kDCAlertViewButtonTagAdd 2000

// calback type
NSString *const kDCAlertViewCallbackTypeA = @"a";
NSString *const kDCAlertViewCallbackTypeCheckBox = @"checkBox";
NSString *const kDCAlertViewCallbackTypeButton = @"button";


@class DCAlertView;
@interface DCAlertViewManager : NSObject

@property (nonatomic, weak) DCRichAlertView *currentAlertView;

+ (instancetype)shareInstance;

@end

@implementation DCAlertViewManager

- (void)setCurrentAlertView:(DCRichAlertView *)currentAlertView
{
    if (_currentAlertView) {
        [_currentAlertView dismiss];
    }
    _currentAlertView = currentAlertView;
}

+ (instancetype)shareInstance
{
    static DCAlertViewManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[DCAlertViewManager alloc] init];
        }
    });
    return _instance;
}
@end




@interface DCRichAlertView () <UITableViewDataSource, UITableViewDelegate, DCXMLRichTextLabelDeletate, BEMCheckBoxDelegate>
{
    NSString *_position;
    
    NSString *_title;
    NSTextAlignment _titleAlign;
    UIColor *_titleColor;
    CGFloat _titleFontSize;
    
    NSString *_content;
    NSTextAlignment _contentAlign;
    UIColor *_contentColor;
    CGFloat _contentFontSize;
    
    NSArray *_buttons;
   
    NSDictionary *_checkBox;
    BOOL _isSelected;
    
    CGFloat _height4content;
    CGFloat _height4HeaderView;
    CGFloat _height4Title;
    CGFloat _height4CheckBoxView;
}

@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, assign) BOOL mIsShowing;

@property (nonatomic, copy) DCAlertCallback callback;
@property (nonatomic, strong) DCXMLRichTextLabel *xmlRichLabel;

@end

@implementation DCRichAlertView

- (DCXMLRichTextLabel *)xmlRichLabel {
    if (!_xmlRichLabel) {
        _xmlRichLabel = [[DCXMLRichTextLabel alloc] initWithFrame:CGRectMake(0, 0, kDCAlertViewDefaultCenterPopupViewWidth - kDCAlertViewPadding * 2, 0)];
        _xmlRichLabel.xmlDelegate = self;
    }
    return _xmlRichLabel;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self defaultInit];
    }
    return self;
}


/**
 初始化默认参数
 */
- (void)defaultInit {
    
    _position = @"center";
    
    _titleAlign = NSTextAlignmentCenter;
    _contentAlign = NSTextAlignmentCenter;
    
    _titleFontSize = kDCAlertViewDefaultTitleFontSize;
    _contentFontSize = kDCAlertViewDefaultContentFontSize;
  
    _titleColor = kDCAlertViewDefaultTextColor;
    _contentColor = kDCAlertViewDefaultTextColor;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height);
    self.frame = frame;
    
    // 背景遮罩颜色
    self.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
    
    [[DCAlertViewManager shareInstance] setCurrentAlertView:self];
}


/**
 解析数据

 @param option 相关设置信息
 */
- (void)parseOption:(NSDictionary *)option {
    
    if (option[@"position"]) {
        _position = [WXConvert NSString:option[@"position"]];
    }
    
    if (option[@"title"]) {
        _title = [WXConvert NSString:option[@"title"]];
    }
    
    if (option[@"titleAlign"]) {
        NSString *titleAlign = [WXConvert NSString:option[@"titleAlign"]];
        if ([titleAlign isEqualToString:@"left"]) {
            _titleAlign = NSTextAlignmentLeft;
        }
        else if ([titleAlign isEqualToString:@"right"]) {
            _titleAlign = NSTextAlignmentRight;
        }
    }
    
    if (option[@"titleColor"]) {
        _titleColor = [WXConvert UIColor:option[@"titleColor"]];
    }
    
    if (option[@"titleFontSize"]) {
        _titleFontSize = [WXConvert CGFloat:option[@"titleFontSize"]] / 2.0;
    }
    
    if (option[@"content"]) {
        _content = [WXConvert NSString:option[@"content"]];
    }
    
    if (option[@"contentAlign"]) {
        NSString *contentAlign = [WXConvert NSString:option[@"contentAlign"]];
        if ([contentAlign isEqualToString:@"left"]) {
            _contentAlign = NSTextAlignmentLeft;
        }
        else if ([contentAlign isEqualToString:@"right"]) {
            _contentAlign = NSTextAlignmentRight;
        }
    }
    
    if (option[@"contentColor"]) {
        _contentColor = [WXConvert UIColor:option[@"contentColor"]];
    }
    
    if (option[@"contentFontSize"]) {
        _contentFontSize = [WXConvert CGFloat:option[@"contentFontSize"]] / 2.0;
    }
    
    if (option[@"buttons"]) {
        if ([option[@"buttons"] isKindOfClass:[NSArray class]]) {
            _buttons = option[@"buttons"];
            if (_buttons.count > 3) {
                _buttons = [NSArray arrayWithObjects:_buttons[0],_buttons[1],_buttons[2], nil];
            }
        } else {
            WXLogError(@"buttons 参数错误 %@",option[@"buttons"]);
        }
    }
    
    if (option[@"checkBox"]) {
        if ([option[@"checkBox"] isKindOfClass:[NSDictionary class]]) {
            _checkBox = option[@"checkBox"];
        } else {
            WXLogError(@"checkBox 参数错误 %@",option[@"checkBox"]);
        }
    }
    
    [self configViews];
}


/**
 按钮的高度 按钮如果小于3个，并排，大于3个竖排

 @return 按钮的总高度
 */
- (CGFloat)heightForButtons
{
    if (_buttons) {
        return _buttons.count > 2 ? _buttons.count * kDCAlertViewDefaultPopupFooterViewHeight : kDCAlertViewDefaultPopupFooterViewHeight;
    }
    return 0;
}

- (void)configViews
{
    /* 根据当前字体计算 title 高度 */
    _height4Title = 0;
    if (_title != nil && _title.length > 0) {
        CGRect rect4content = [_title boundingRectWithSize:CGSizeMake(kDCAlertViewDefaultCenterPopupViewWidth - kDCAlertViewPadding * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:_titleFontSize]} context:nil];
        _height4Title = rect4content.size.height + kDCAlertViewTopSpace;
    }
    
    /* 计算content高度 */
    _height4content = 0;
    if (_content != nil && _content.length > 0) {
        self.xmlRichLabel.textColor = _contentColor;
        self.xmlRichLabel.textAlignment = _contentAlign;
        self.xmlRichLabel.font = [UIFont systemFontOfSize:_contentFontSize];
        [self.xmlRichLabel loadXMLString:_content];
        _height4content = self.xmlRichLabel.frame.size.height;
    }
    
    /* 是否存在checkBox */
    _height4CheckBoxView = 0;
    if (_checkBox) {
        _height4CheckBoxView = kDCAlertViewCheckBoxWidth  + kDCAlertViewTopSpace;
    }

    /* 计算header总高度 */
    CGFloat headerHeight = _height4Title + _height4content + _height4CheckBoxView + kDCAlertViewTopPadding * 2;
    
    /* 最大高度 */
    _height4HeaderView = headerHeight > kDCAlertViewMaxHeight ? kDCAlertViewMaxHeight : headerHeight;
    
    self.mIsShowing = NO;
    
    [self initTableView];
}

- (void)initTableView
{
    if (!self.mTableView) {
        self.mTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.mTableView.dataSource = self;
        self.mTableView.delegate = self;
        self.mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.mTableView.separatorColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0];
        self.mTableView.bounces = NO;
        
        self.mTableView.layer.masksToBounds = NO;
        self.mTableView.layer.shadowOpacity = 1.0;
        self.mTableView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        [self.mTableView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
        self.mTableView.layer.shadowRadius = 5.0;
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _height4HeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self heightForButtons];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDCAlertViewDefaultCenterPopupViewWidth, _height4HeaderView)];
    
    CGFloat scrollViewsOriginY = kDCAlertViewTopPadding;
    CGFloat scrollViewHeight = _height4HeaderView - kDCAlertViewTopPadding * 2;
    
    /* 弹窗标题 */
    if (_title != nil && _title.length > 0) {
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(kDCAlertViewPadding, kDCAlertViewTopPadding, headView.frame.size.width - kDCAlertViewPadding * 2, _height4Title - kDCAlertViewTopSpace)];
        titleLbl.text = _title;
        titleLbl.textColor = _titleColor;
        titleLbl.textAlignment = _titleAlign;
        titleLbl.font = [UIFont systemFontOfSize:_titleFontSize];
        titleLbl.numberOfLines = 0;
        [headView addSubview:titleLbl];
        
        scrollViewsOriginY = titleLbl.frame.origin.y + titleLbl.frame.size.height + kDCAlertViewTopSpace;
        scrollViewHeight -= titleLbl.frame.size.height + kDCAlertViewTopSpace;
    }
    
    /* ScrollView 内容过多滑动显示 */
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kDCAlertViewPadding, scrollViewsOriginY, headView.frame.size.width - kDCAlertViewPadding * 2,0)];
    [headView addSubview:scrollView];
    scrollView.contentInset = UIEdgeInsetsZero;
    
    /* 弹窗内容 */
    if (_content != nil && _content.length > 0) {
        
        if (_title && _title.length > 0) {
            scrollViewsOriginY += kDCAlertViewTopSpace;
        }
        
        self.xmlRichLabel.frame = CGRectMake(0, 0, scrollView.frame.size.width, _height4content);
        [scrollView addSubview:self.xmlRichLabel];
        scrollViewsOriginY = self.xmlRichLabel.frame.origin.y + self.xmlRichLabel.frame.size.height;
    }
    
    /* 选择框 */
    if (_checkBox) {
        
        scrollViewHeight -= kDCAlertViewCheckBoxWidth + kDCAlertViewTopSpace;
        
        NSString *title = _checkBox[@"title"] ? [WXConvert NSString:_checkBox[@"title"]] : @"";
        UIColor *titleColor = _checkBox[@"titleColor"] ? [WXConvert UIColor:_checkBox[@"titleColor"]] : [UIColor blackColor];
        _isSelected = [WXConvert BOOL:_checkBox[@"isSelected"]];
        
        BEMCheckBox *checkBoxView = [[BEMCheckBox alloc] initWithFrame:CGRectMake(kDCAlertViewPadding, scrollView.frame.origin.y + scrollViewHeight + kDCAlertViewTopSpace, kDCAlertViewCheckBoxWidth, kDCAlertViewCheckBoxWidth)];
        checkBoxView.boxType = BEMBoxTypeSquare;
        checkBoxView.onAnimationType = BEMAnimationTypeFade;
        checkBoxView.animationDuration = 0.15;
        checkBoxView.tintColor = [UIColor lightGrayColor];
        checkBoxView.onTintColor = [WXConvert UIColor:@"#108EE9"];
        checkBoxView.onCheckColor = [UIColor whiteColor];
        checkBoxView.onFillColor = [WXConvert UIColor:@"#108EE9"];
        checkBoxView.on = _isSelected;
        checkBoxView.delegate = self;
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(checkBoxView.frame.origin.x + checkBoxView.frame.size.width + 5, checkBoxView.frame.origin.y, scrollView.frame.size.width - (checkBoxView.frame.size.width + 5), checkBoxView.frame.size.height)];
        lbl.text = title;
        lbl.textColor = titleColor;
        lbl.font = [UIFont systemFontOfSize:_contentFontSize];
        
        [headView addSubview:checkBoxView];
        [headView addSubview:lbl];
    }
    
    CGRect scrollViewFrame = scrollView.frame;
    scrollViewFrame.size.height = scrollViewHeight;
    scrollView.frame = scrollViewFrame;
    scrollView.bounces = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, _height4content);
    return headView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (![self heightForButtons]) {
        return nil;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDCAlertViewDefaultCenterPopupViewWidth, [self heightForButtons])];
    
    BOOL vertical = _buttons.count > 2;
    CGFloat originX = 0.0;
    CGFloat originY = 0.0;
    CGFloat width4Btn = (vertical || _buttons.count == 1) ? footerView.frame.size.width : footerView.frame.size.width / 2.0;
    
    for (int i = 0; i < _buttons.count; i++) {
        
        NSDictionary *item = _buttons[i];
        NSString *title = item[@"title"] ? [WXConvert NSString:item[@"title"]] : @"";
        UIColor *titleColor = item[@"titleColor"] ? [WXConvert UIColor:item[@"titleColor"]] : [UIColor blackColor];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, width4Btn, kDCAlertViewDefaultPopupFooterViewHeight)];
        btn.tag = kDCAlertViewButtonTagAdd + i;
        btn.titleLabel.font = [UIFont systemFontOfSize:kDCAlertViewDefaultButtonTitleFontSize];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btn];
        
        /* 添加顶部分割线 */
        if (i == 0) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerView.frame.size.width, 0.5)];
            line.backgroundColor = [WXConvert UIColor:kDCAlertViewDefaultLineColor];
            [btn addSubview:line];
        }
        
        /* 两个按钮 添加中线 */
        if (i == 0 && _buttons.count == 2) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btn.frame.size.width - 0.5, 0, 0.5, btn.frame.size.height)];
            line.backgroundColor = [WXConvert UIColor:kDCAlertViewDefaultLineColor];
            [btn addSubview:line];
            originX = width4Btn;
        }
        
        /* 添加按钮分割线 */
        if (vertical && i != _buttons.count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.size.height - 0.5, footerView.frame.size.width, 0.5)];
            line.backgroundColor = [WXConvert UIColor:kDCAlertViewDefaultLineColor];
            [btn addSubview:line];
        }
        
        if (vertical) {
            originY += btn.frame.size.height;
        }
    }
    
    return footerView;
}

- (void)buttonClicked:(UIButton *)button
{
    if (self.callback) {
        NSDictionary *result = @{
                                 @"type": @"button",
                                 @"index": @(button.tag - kDCAlertViewButtonTagAdd)
                                 };
        self.callback(result);
    }
    
    [self dismiss];
}

- (void)otherBtnClicked
{
//    if (self.clickedButtonBlock) {
//        self.clickedButtonBlock(_otherButtonTitle);
//    }
    
    [self dismiss];
}

- (UIWindow *)findVisibleWindow {
    UIWindow *visibleWindow = nil;
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (!window.hidden && !visibleWindow) {
            visibleWindow = window;
        }
        if ([UIWindow instancesRespondToSelector:@selector(rootViewController)]) {
            if ([window rootViewController]) {
                visibleWindow = window;
                break;
            }
        }
    }
    
    return visibleWindow?:[[UIApplication sharedApplication].delegate window];
}

#pragma mark - DCXMLRichTextLabelDeletate
- (void)clickedALabelWithAttribute:(NSDictionary *)attribute
{
    
    if (self.callback) {
        NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:attribute];
        [res setValue:kDCAlertViewCallbackTypeA forKey:@"type"];
        self.callback(res);
    }
}

#pragma mark - BEMCheckBoxDelegate
- (void)didTapCheckBox:(BEMCheckBox *)checkBox
{
    _isSelected = checkBox.on;
    if (self.callback) {
        NSDictionary *res = @{
                              @"type": @"checkBox",
                              @"isSelected": @(_isSelected)
                              };
        self.callback(res);
    }
}

#pragma mark - Public method

+ (DCRichAlertView *)alertWithOptions:(NSDictionary *)options callback:(DCAlertCallback)callback
{
    DCRichAlertView *alert = [[DCRichAlertView alloc] init];
    alert.callback = callback;
    [alert parseOption:options];
    return alert;
}

- (void)show
{
    [self showInView:nil];
}

- (void)showInView:(UIView *)view
{
    if (self.mIsShowing) {
        return;
    }
    
    if (!view) {
        view = [self findVisibleWindow];
    }

    [view addSubview:self];
    
    self.mIsShowing = YES;
    
    CGSize __winSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat __popupViewHeight = _height4HeaderView + [self heightForButtons];
    CGFloat __originY = (__winSize.height - __popupViewHeight) / 2.0;
    
    if ([_position isEqualToString:@"bottom"]) {
        __originY = __winSize.height - __popupViewHeight - 35;
    }
    
    
    self.mTableView.frame = CGRectMake((__winSize.width - kDCAlertViewDefaultCenterPopupViewWidth) / 2.0,
                                       __originY,
                                       kDCAlertViewDefaultCenterPopupViewWidth,
                                       __popupViewHeight);
    [self addSubview:self.mTableView];
    
    self.mTableView.transform = CGAffineTransformMakeScale(.5, .5);
    self.mTableView.alpha = .0;
    [UIView animateWithDuration:kDCAlertViewDefaultPopupViewAnimationDuration
                     animations:^{
                         self.mTableView.alpha = 1.0;
                         self.mTableView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }];
    
    self.mTableView.clipsToBounds = YES;
    self.mTableView.layer.cornerRadius = 4.0;
    
    [self.mTableView reloadData];
}

- (void)dismiss
{
    self.mIsShowing = NO;
    
    [self.mTableView removeFromSuperview];
    self.callback = nil;
    [self removeFromSuperview];
    
    /* 取消隐藏时的动画 */
//    [UIView animateWithDuration:0.15
//                     animations:^{
//                         self.mTableView.transform = CGAffineTransformMakeScale(1.2, 1.2);
//                         self.mTableView.alpha = .0;
//                     }
//                     completion:^(BOOL finished) {
//                         self.mTableView.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                         [self.mTableView removeFromSuperview];
//                         self.clickedButtonBlock = nil;
//                         [self removeFromSuperview];
//                     }];
}

@end
