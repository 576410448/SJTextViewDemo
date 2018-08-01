//
//  SJTextView.m
//  SJTextViewDemo
//
//  Created by shenj on 16/11/22.
//  Copyright © 2016年 shenj. All rights reserved.
//

#define textManager [SJTextManager managerWithSelectedRange:[self selectedRange]]
#define allArrayManeger [SJAllArrayManager allArrayManager]

#import "SJTextView.h"
#import "SJTextTools.h"
#import "SJTextManager.h"
#import "SJAllArrayManager.h"

#import <objc/runtime.h>
#import <objc/message.h>

static const int insertImageLength = 24; // "图片来自SJTextViewDemo"18 + 图片1 + 2*换行1 + 分割线1 +前后换行2

@interface SJTextView ()

@property (nonatomic ,strong) SJTextModel *model;

@property (nonatomic ,weak) UIViewController *rootController;

@property (nonatomic ,weak) UITextField *linkUrlTF;

@property (nonatomic ,weak) UITextField *linkTitleTF;

@property (nonatomic ,assign) NSInteger arrIndex; //大数据源里当前数据源位置

@end

@implementation SJTextView

static const void *kSJTextNextFontKey = &kSJTextNextFontKey;

#pragma mark 开放接口
- (instancetype)initWithFrame:(CGRect)frame delegate:(UIViewController *)viewController{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.kSJTextNextFont = 17;
        self.font = [UIFont systemFontOfSize:self.kSJTextNextFont];
        _rootController = viewController;
        
        _arrIndex = 0;
        
        /**
         * 注册通知，监听键盘的弹出和收回
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark 开放接口 各操作调用
- (void)showModelWithInputText:(NSString *)inputText{
    SJTextModel *model = [[SJTextModel alloc] init];
    model.kSJTextIsBold = self.kSJTextIsBold;
    model.kSJTextIsOblique = self.kSJTextIsOblique;
    model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
    model.kSJTextNextFont = self.kSJTextNextFont;
    
    if ([inputText isEqualToString:@"\n"]) {
        inputText = @"\n\n";
    }
    model.kSJTextInputText = inputText;
    
    self.model = model;
}

- (void)showModelWithImage:(UIImage *)image{
    SJTextModel *model = [[SJTextModel alloc] init];
    model.kSJTextIsBold = self.kSJTextIsBold;
    model.kSJTextIsOblique = self.kSJTextIsOblique;
    model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
    model.kSJTextNextFont = self.kSJTextNextFont;
    
    model.kSJTextImage = image; //替换或者插入图片
    
    self.model = model;
    
    if ([textManager isThereInImageRange]) {
        return;
    }
    // 图片数据源
    
    NSDictionary *newImageDic = @{kImageNameKey:image,
                                  kImageRangeLocationKey:@([self selectedRange].location - insertImageLength),
                                  kImageRangeLengthKey:@(insertImageLength)};
    
    [textManager.imageDicArr addObject:newImageDic];
    NSLog(@"*----------------*\n%@",textManager.imageDicArr);
    
    // 更新大数据源
    [self relodataAllArray];
    
    // 换行
    [self showModelWithInputText:@"\n\n"];
}

- (void)showModelWithSepline {
    
    if ([textManager isThereInImageRange]) {
        return;
    }
    
    NSRange oldRange = [self selectedRange];
    
    // 超链接
    [textManager linkDeleteSelectedWithRange:oldRange];
    // 图片
    [textManager imageDeleteSelectedWithRange:oldRange];
    
    // 计算插入attribute length
    NSInteger length = 2;
    // 计算Range
    NSRange range = NSMakeRange(oldRange.location, length);
    // 改变数据源超链接range
    [textManager updateLinkRange:range withDelete:NO];
    // 改变图片数据源range
    [textManager updateImageRange:range withDelete:NO];
    //
    NSAttributedString *showAttbuteText = [SJTextTools insertSeplineWithFullText:self.attributedText withRange:[self selectedRange]];
    
    // 显示
    [self showAttbuteText:showAttbuteText withLocation:oldRange.location + oldRange.length + insertImageLength];
    
    // 换行
    [self showModelWithInputText:@"\n\n"];
    
}

- (void)showModelWithLink{
    SJTextModel *model = [[SJTextModel alloc] init];
    model.kSJTextIsBold = self.kSJTextIsBold;
    model.kSJTextIsOblique = self.kSJTextIsOblique;
    model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
    model.kSJTextNextFont = self.kSJTextNextFont;
    
    model.kSJTextSuperLinkTitle = _linkTitleTF.text;
    
    self.model = model;
}

- (void)deleteByKeyboardWithRange:(NSRange)range{
    
    if (range.length == 0) {  // 单位删除
        
        if (range.location == 0) { // 起点
            return;
        }
        
        NSInteger location = range.location - 1;
        NSInteger length = 1;
        range = NSMakeRange(location, length);
        
        // 超链接
        [textManager linkDeleteSelectedWithRange:range];
        
        // 图片
        [textManager imageDeleteSelectedWithRange:range];
        
    }else{
        
        // 超链接
        [textManager linkDeleteSelectedWithRange:range];
        // 图片
        [textManager imageDeleteSelectedWithRange:range];
    }
    
    // 显示
    NSAttributedString *attributedText =
    [SJTextTools insertAttriButesWithFullText:self.attributedText
                                    insertStr:@""
                                     withFont:self.kSJTextNextFont
                                    withRange:range
                                    isOblique:self.kSJTextIsOblique
                                       isBold:self.kSJTextIsBold
                                 isCenterLine:self.kSJTextIsCenterLine
                                  isUnderLine:self.kSJTextIsUnderLine];
    [self showAttbuteText:attributedText withLocation:range.location];
    
    // 更新大数据源
    [self relodataAllArray];
}

#pragma mark 所有外部操作处理
- (void)setModel:(SJTextModel *)model{
    
    _model = model;
    
    NSRange oldRange = [self selectedRange];
    NSAttributedString *showAttbuteText;
    
    if (model.kSJTextImage) { // 插入图片
        
        if ([textManager isThereInImageRange]) {
            return;
        }
        
        // 超链接
        [textManager linkDeleteSelectedWithRange:oldRange];
        // 图片
        [textManager imageDeleteSelectedWithRange:oldRange];
        
        // 计算插入attribute length
        NSInteger length = insertImageLength;
        // 计算Range
        NSRange range = NSMakeRange(oldRange.location, length);
        // 改变数据源超链接range
        [textManager updateLinkRange:range withDelete:NO];
        // 改变图片数据源range
        [textManager updateImageRange:range withDelete:NO];
        //
        showAttbuteText = [SJTextTools insertImageWithFullText:self.attributedText
                                                   insertImage:model.kSJTextImage
                                                     withRange:[self selectedRange]];
        
        // 显示
        [self showAttbuteText:showAttbuteText withLocation:oldRange.location + oldRange.length + insertImageLength];
        
    }else if (model.kSJTextSuperLinkTitle){ // 插入超链接
        
        if ([textManager isThereInImageRange]) {
            return;
        }
        
        // 超链接
        [textManager linkDeleteSelectedWithRange:oldRange];
        // 图片
        [textManager imageDeleteSelectedWithRange:oldRange];

        
        // 计算插入attribute length
        NSInteger length = model.kSJTextSuperLinkTitle.length;
        // 计算Range
        NSRange range = NSMakeRange(oldRange.location, length);
        // 改变数据源超链接range
        [textManager updateLinkRange:range withDelete:NO];
        // 改变图片数据源range
        [textManager updateImageRange:range withDelete:NO];
        
        // 数据源添加link字典
        showAttbuteText = [SJTextTools addLinkWithFullText:self.attributedText
                                                 insertStr:model.kSJTextSuperLinkTitle
                                                  withFont:self.kSJTextNextFont
                                                 withRange:[self selectedRange]
                                                 isOblique:self.kSJTextIsOblique
                                                    isBold:_kSJTextIsBold
                                              isCenterLine:_kSJTextIsCenterLine
                                               isUnderLine:_kSJTextIsUnderLine];
        // 显示
        [self showAttbuteText:showAttbuteText withLocation:oldRange.location + model.kSJTextSuperLinkTitle.length];

        
    }else if (model.kSJTextInputText){ // 插入文字
        
        if ([textManager isThereInImageRange].count == 2) {
            return;
        }
        
        // 超链接
        [textManager linkDeleteSelectedWithRange:oldRange];
        // 图片
        [textManager imageDeleteSelectedWithRange:oldRange];

        // 计算插入attribute length
        NSInteger length = model.kSJTextInputText.length;
        // 计算Range
        NSRange range = NSMakeRange(oldRange.location, length);
        // 改变数据源超链接range
        [textManager updateLinkRange:range withDelete:NO];
        // 改变图片数据源range
        [textManager updateImageRange:range withDelete:NO];

        
        if ([textManager isThereInImageRange].count == 1) { // 表示在图片范围内编辑
            
            //
            showAttbuteText = [SJTextTools insertTexrInImageWithFullText:self.attributedText
                                                               insertStr:model.kSJTextInputText
                                                               withRange:[self selectedRange] withImageDic:[textManager isThereInImageRange].firstObject];
            // 显示
            [self showAttbuteText:showAttbuteText withLocation:oldRange.location + model.kSJTextInputText.length];
            
            return;
        }
        
        //
        showAttbuteText = [SJTextTools insertAttriButesWithFullText:self.attributedText
                                                          insertStr:model.kSJTextInputText
                                                           withFont:self.kSJTextNextFont
                                                          withRange:[self selectedRange]
                                                          isOblique:self.kSJTextIsOblique
                                                             isBold:self.kSJTextIsBold
                                                       isCenterLine:self.kSJTextIsCenterLine
                                                        isUnderLine:self.kSJTextIsUnderLine];
        // 显示
        [self showAttbuteText:showAttbuteText withLocation:oldRange.location + model.kSJTextInputText.length];
        
        // 更新大数据源
        [self relodataAllArray];
        
    }else{ // 改变状态
        
        if ([textManager isThereInImageRange]) {
            return;
        }
        
        showAttbuteText = [SJTextTools changeAttriButesWithString:self.attributedText
                                                         withFont:model.kSJTextNextFont
                                                        withRange:[self selectedRange]
                                                        isOblique:model.kSJTextIsOblique
                                                           isBold:model.kSJTextIsBold
                                                     isCenterLine:model.kSJTextIsCenterLine
                                                      isUnderLine:model.kSJTextIsUnderLine
                                                       changeType:model.kSJTextChangeAttributeType];
        // 显示
        [self showAttbuteText:showAttbuteText withLocation:oldRange.location + oldRange.length];
        
        // 更新大数据源
        [self relodataAllArray];
        
    }
    
}

#pragma mark textView 赋值调用 改变selectedRange
- (void)showAttbuteText:(NSAttributedString *)attributeText withLocation:(NSInteger)location{
    self.attributedText = attributeText;
    
    NSRange newSelectedRang = NSMakeRange(location, 0);
    [self setSelectedRange:newSelectedRang];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservePlaceholderShowNote object:@(self.attributedText.length)];
    [[NSNotificationCenter defaultCenter] postNotificationName:kObserveEndPlaceholderNote object:@(self.attributedText.length)];
    
    // 运行时，私有变量
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([UITextView class], &count);
//    
//    for (int i = 0; i < count; i++) {
//        Ivar ivar = ivars[i];
//        const char *name = ivar_getName(ivar);
//        NSString *objcName = [NSString stringWithUTF8String:name];
//        NSLog(@"%d : %@",i,objcName);
//    }
//    
//    // 显示文本 _tontainerView
//    UIView *view = [self valueForKey:@"_containerView"];
//    Ivar *ivars1 = class_copyIvarList([view class], &count);
//    
//    for (int i = 0; i < count; i++) {
//        Ivar ivar = ivars1[i];
//        const char *name = ivar_getName(ivar);
//        NSString *objcName = [NSString stringWithUTF8String:name];
//        NSLog(@"%d : %@",i,objcName);
//    }
//    
//    UIView *view1 = [view valueForKey:@"_invalidationSeqNo"];
//    Ivar *ivars2 = class_copyIvarList([view1 class], &count);
//    
//    for (int i = 0; i < count; i++) {
//        Ivar ivar = ivars2[i];
//        const char *name = ivar_getName(ivar);
//        NSString *objcName = [NSString stringWithUTF8String:name];
//        NSLog(@"%d : %@",i,objcName);
//    }
    
}

#pragma mark 开放接口 外部调用存值与赋值 改变状态 不改变range

- (void)setKSJTextIsBold:(BOOL)kSJTextIsBold{
    
    if ([self selectedRange].length == 0) {
        _kSJTextIsBold = kSJTextIsBold;
        
    }else{
        
        _kSJTextIsBold = kSJTextIsBold;
        
        SJTextModel *model = [[SJTextModel alloc] init];
        model.kSJTextIsBold = kSJTextIsBold;
        model.kSJTextIsOblique = self.kSJTextIsOblique;
        model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
        model.kSJTextIsUnderLine = self.kSJTextIsUnderLine;
        model.kSJTextNextFont = self.kSJTextNextFont;
        
        model.kSJTextChangeAttributeType = changeAttributeTypeBold;
        self.model = model;
    }
    
}

- (void)setKSJTextIsOblique:(BOOL)kSJTextIsOblique{
    
    if ([self selectedRange].length == 0) {
        _kSJTextIsOblique = kSJTextIsOblique;
    }else{
        
        _kSJTextIsOblique = kSJTextIsOblique;
        
        SJTextModel *model = [[SJTextModel alloc] init];
        model.kSJTextIsBold = self.kSJTextIsBold;
        model.kSJTextIsOblique = kSJTextIsOblique;
        model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
        model.kSJTextIsUnderLine = self.kSJTextIsUnderLine;
        model.kSJTextNextFont = self.kSJTextNextFont;
        
        model.kSJTextChangeAttributeType = changeAttributeTypeOblique;
        self.model = model;
    }

}

- (void)setKSJTextIsCenterLine:(BOOL)kSJTextIsCenterLine{
    
    if ([self selectedRange].length == 0) {
        _kSJTextIsCenterLine = kSJTextIsCenterLine;
        
    }else{
        
        _kSJTextIsCenterLine = kSJTextIsCenterLine;
        
        SJTextModel *model = [[SJTextModel alloc] init];
        model.kSJTextIsBold = self.kSJTextIsBold;
        model.kSJTextIsOblique = self.kSJTextIsOblique;
        model.kSJTextIsCenterLine = kSJTextIsCenterLine;
        model.kSJTextIsUnderLine = self.kSJTextIsUnderLine;
        model.kSJTextNextFont = self.kSJTextNextFont;
        
        model.kSJTextChangeAttributeType = changeAttributeTypeCenterLine;
        self.model = model;
    }
    
}

- (void)setKSJTextIsUnderLine:(BOOL)kSJTextIsUnderLine{
    
    if ([self selectedRange].length == 0) {
        _kSJTextIsUnderLine = kSJTextIsUnderLine;
        
    }else{
        
        _kSJTextIsUnderLine = kSJTextIsUnderLine;
        
        SJTextModel *model = [[SJTextModel alloc] init];
        model.kSJTextIsBold = self.kSJTextIsBold;
        model.kSJTextIsOblique = self.kSJTextIsOblique;
        model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
        model.kSJTextIsUnderLine = kSJTextIsUnderLine;
        model.kSJTextNextFont = self.kSJTextNextFont;
        
        model.kSJTextChangeAttributeType = changeAttributeTypeUnderLine;
        self.model = model;
    }
    
}

- (void)setKSJTextNextFont:(CGFloat)kSJTextNextFont{
    
    if ([self selectedRange].length == 0) {
        _kSJTextNextFont = kSJTextNextFont;
        
    }else{
        
        _kSJTextNextFont = kSJTextNextFont;
        
        SJTextModel *model = [[SJTextModel alloc] init];
        model.kSJTextIsBold = self.kSJTextIsBold;
        model.kSJTextIsOblique = self.kSJTextIsOblique;
        model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
        model.kSJTextIsUnderLine = self.kSJTextIsUnderLine;
        model.kSJTextNextFont = kSJTextNextFont;
        
        model.kSJTextChangeAttributeType = changeAttributeTypeFont;
        self.model = model;
    }
    
}

#pragma mark 开放接口 外部调用alert判断
- (void)alertLinkByBtnAction:(BOOL)isBtnTap{
    
    [textManager alertLinkByBtnAction:isBtnTap alertBlock:^(NSDictionary *linkDic) {
        
        if ([textManager isThereInImageRange]) {
            return;
        }
        [self alertlinkActionWithLinkDic:linkDic];
        
        
    }];
    
    
}
#pragma mark 点击与监控调用alert
- (void)alertlinkActionWithLinkDic:(NSDictionary *)linkDic{
    
    NSString *title = linkDic?@"编辑超链接":@"插入超链接";
    NSRange oldRange = [self selectedRange];
    
    UIAlertController *editableAlert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // 输入超链接地址
    [editableAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        _linkUrlTF = textField;
        _linkUrlTF.placeholder = @"超链接地址";
        _linkUrlTF.clearButtonMode = UITextFieldViewModeAlways;
        
        if (linkDic) {
            _linkUrlTF.text = linkDic[kLinkUrlKey];
        }
        
    }];
    
    // 输入超链接显示
    [editableAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        _linkTitleTF = textField;
        _linkTitleTF.placeholder = @"超链接标题";
        _linkTitleTF.clearButtonMode = UITextFieldViewModeAlways;
        
        if (linkDic) {
            _linkTitleTF.text = linkDic[kLinkTitleKey];
            
        }else if ([self selectedRange].length != 0){
            _linkTitleTF.text = [self.text substringWithRange:[self selectedRange]];
        }
        
    }];
    
    // 确定
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ((!_linkTitleTF.text || [_linkTitleTF.text isEqualToString:@""]) &&
            (!_linkUrlTF.text || [_linkUrlTF.text isEqualToString:@""])) {
            return ;
            
        }else if (!_linkTitleTF.text || [_linkTitleTF.text isEqualToString:@""]){
            _linkTitleTF.text = _linkUrlTF.text;
            
        }else if (!_linkUrlTF.text || [_linkUrlTF.text isEqualToString:@""]){
            _linkUrlTF.text = _linkTitleTF.text;
        }
        
        [self showModelWithLink];
        
        if (!linkDic) { // 增加超链接数据源数据
            
            NSDictionary *newLinkDic = @{kLinkTitleKey:_linkTitleTF.text,
                                         kLinkUrlKey:_linkUrlTF.text,
                                         kLinkRangLocationKey:@(oldRange.location),
                                         KLinkRangLengthKey:@(_linkTitleTF.text.length)};
        
            [textManager.linkDicArr addObject:newLinkDic];
            
        }else{
            
            NSDictionary *newLinkDic = @{kLinkTitleKey:_linkTitleTF.text,
                                         kLinkUrlKey:_linkUrlTF.text,
                                         kLinkRangLocationKey:linkDic[kLinkRangLocationKey],
                                         KLinkRangLengthKey:@(_linkTitleTF.text.length)};
            [textManager.linkDicArr addObject:newLinkDic];
            
        }
        
        // 更新大数据源
        [self relodataAllArray];
        
        // 防止多选
//        UIView *view = [self valueForKey:@"_containerView"];
//        [view.subviews.firstObject removeFromSuperview];
        NSLog(@"%ld-%ld",self.selectedRange.location,self.selectedRange.length);
        
    }];
    
    [editableAlert addAction:okAction];
    
    // 删除超链接
    if (linkDic) {
        
        UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"删除超链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
            // 从数据源中删除
            for (NSDictionary *subLinkDic in textManager.linkDicArr) {
                if (subLinkDic == linkDic) {
                    [textManager.linkDicArr removeObject:linkDic];
                    break;
                }
            }
            
            // 更新样式
            SJTextModel *model = [[SJTextModel alloc] init];
            model.kSJTextIsBold = self.kSJTextIsBold;
            model.kSJTextIsOblique = self.kSJTextIsOblique;
            model.kSJTextIsCenterLine = self.kSJTextIsCenterLine;
            model.kSJTextIsUnderLine = self.kSJTextIsUnderLine;
            model.kSJTextNextFont = self.kSJTextNextFont;
            
            model.kSJTextChangeAttributeType = changeAttributeTypeCancel;
            self.model = model;
            
        }];
        
        [editableAlert addAction:delAction];
        
        // 防止多选
//        UIView *view = [self valueForKey:@"_containerView"];
//        [view.subviews.firstObject removeFromSuperview];
        
    }
    
    // 取消编辑
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // 防止多选
//        UIView *view = [self valueForKey:@"_containerView"];
//        [view.subviews.firstObject removeFromSuperview];
        self.selectedRange = NSMakeRange(self.selectedRange.location+self.selectedRange.length, 0);
    }];
    
    [editableAlert addAction:cancelAction];
    
    
    if (linkDic) { // 设置新的selectedRange
        
        NSRange newSelectedRang = NSMakeRange([linkDic[kLinkRangLocationKey] integerValue], [linkDic[KLinkRangLengthKey] integerValue]);
        [self setSelectedRange:newSelectedRang];
    }
    
    [_rootController presentViewController:editableAlert animated:YES completion:nil];
    
}

#pragma mark -- 键盘显示的监听方法
-(void) keyboardWillShow:(NSNotification *) note
{
    // 获取键盘的位置和大小
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // 时间
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    // 曲线
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    CGFloat keyboardH = keyboardBounds.size.height;
    
    [self setFrame:CGRectMake(10, self.frame.origin.y, MAIN_WIDTH - 20, MAIN_HEIGHT - (kDevice_Is_iPhoneX?88:64) - keyboardH - self.frame.origin.y - 50)]; // 50为工具栏高度
    
    NSLog(@"keyboard show %@ %@",duration,curve);
    
}

#pragma mark -- 键盘隐藏的监听方法
-(void) keyboardWillHide:(NSNotification *) note
{
    // 获取键盘的位置和大小
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // 时间
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    // 曲线
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
    [self setFrame:CGRectMake(10, self.frame.origin.y, MAIN_WIDTH - 20, MAIN_HEIGHT - (kDevice_Is_iPhoneX?88:64) - self.frame.origin.y)];
    
    NSLog(@"keyboard show %@ %@",duration,curve);
    
}

#pragma mark 全局数据源更新

- (void)relodataAllArray {
    
    _arrIndex ++;
    
    NSDictionary *postDic = @{kAllArrayTextKey:self.attributedText,
                              kAllArrayLinksKey:textManager.linkDicArr.mutableCopy,
                              kAllArrayImagesKey:textManager.imageDicArr.mutableCopy};
    
    [allArrayManeger addObject:postDic atIndex:_arrIndex];
    
}

/**撤销*/
- (void)undoToLast{
    
    if (_arrIndex <= 0) {
        return;
    }
    _arrIndex --;
    
    NSDictionary *subAllDic = allArrayManeger.allArray[_arrIndex];
    
    if ([subAllDic[kAllArrayLinksKey] isEqual:@[]] ||
        !subAllDic[kAllArrayLinksKey]) {
        textManager.linkDicArr = [[NSMutableArray alloc] init];
    }else{
        textManager.linkDicArr = subAllDic[kAllArrayLinksKey];
    }
    
    if ([subAllDic[kAllArrayImagesKey] isEqual:@[]] ||
        !subAllDic[kAllArrayImagesKey]) {
        textManager.imageDicArr = [[NSMutableArray alloc] init];
    }else{
        textManager.imageDicArr = subAllDic[kAllArrayImagesKey];
    }
    
    NSAttributedString *attStr = subAllDic[kAllArrayTextKey];
    
    [self showAttbuteText:attStr withLocation:attStr.length];
}

/**恢复*/
- (void)restoreToNext{
    
    NSArray *dataArr = allArrayManeger.allArray;
    
    if (_arrIndex >= dataArr.count - 1) {
        return;
    }
    _arrIndex ++;
    
    
    NSDictionary *subAllDic = allArrayManeger.allArray[_arrIndex];
    
    if ([subAllDic[kAllArrayLinksKey] isEqual:@[]] ||
        !subAllDic[kAllArrayLinksKey]) {
        textManager.linkDicArr = [[NSMutableArray alloc] init];
    }else{
        textManager.linkDicArr = subAllDic[kAllArrayLinksKey];
    }
    
    if ([subAllDic[kAllArrayImagesKey] isEqual:@[]] ||
        !subAllDic[kAllArrayImagesKey]) {
        textManager.imageDicArr = [[NSMutableArray alloc] init];
    }else{
        textManager.imageDicArr = subAllDic[kAllArrayImagesKey];
    }
    
    NSAttributedString *attStr = subAllDic[kAllArrayTextKey];
    
    [self showAttbuteText:attStr withLocation:attStr.length];
    
}

- (void)dealloc {
    NSLog(@"texeview 执行delloc");
    textManager.linkDicArr = nil;
    textManager.imageDicArr = nil;
    allArrayManeger.allArray = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kObserveEndPlaceholderNote
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kObservePlaceholderShowNote
                                                  object:nil];
}

@end
