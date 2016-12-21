//
//  SJTextView.h
//  SJTextViewDemo
//
//  Created by shenj on 16/11/22.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  本类 textView

#import <UIKit/UIKit.h>
#import "SJTextModel.h"
#import "SJCacheModel+CoreDataProperties.h"
#import "SJTextView+placeholder.h"


static NSString * const kSJTextChangeContentOfSetYNotefacation = @"kSJTextChangeContentOfSetYNotefacation";

@interface SJTextView : UITextView

#pragma mark 开放属性

/**缓存草稿*/
@property (nonatomic ,strong)   SJCacheModel        *cacheModel;

/**斜体*/
@property (nonatomic ,assign)   BOOL                 kSJTextIsOblique;

/**加粗*/
@property (nonatomic ,assign)   BOOL                 kSJTextIsBold;              

/**中划线*/
@property (nonatomic ,assign)   BOOL                 kSJTextIsCenterLine;        

/**下划线*/
@property (nonatomic ,assign)   BOOL                 kSJTextIsUnderLine;         

/**字体*/
@property (nonatomic ,assign)   CGFloat              kSJTextNextFont;

#pragma mark textView 赋值调用 改变selectedRange
- (void)showAttbuteText:(NSAttributedString *)attributeText withLocation:(NSInteger)location;

#pragma mark 开放方法
/**创建 传入controller*/
- (instancetype)initWithFrame:(CGRect)frame delegate:(UIViewController *)viewController;

/**插入文字*/
- (void)showModelWithInputText:(NSString *)inputText;

/**插入图片*/
- (void)showModelWithImage:(UIImage *)image;

/**插入分割线*/
- (void)showModelWithSepline;

/**插入超链接*/
- (void)alertLinkByBtnAction:(BOOL)isBtnTap;

/**单位删除*/
- (void)deleteByKeyboardWithRange:(NSRange)range;

/**撤销*/
- (void)undoToLast;

/**恢复*/
- (void)restoreToNext;

@end
