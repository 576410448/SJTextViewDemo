//
//  SJTextView+placeholder.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/5.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SJTextView+placeholder.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define placeholderFont [UIFont systemFontOfSize:14]

static const void *placeholderKey         = &placeholderKey;
static const void *endPlaceholderKey      = &endPlaceholderKey;
static const int   placeholderLabelKey    = 10;
static const int   endPlaceholderLabelKey = 11;

@implementation SJTextView (placeholder)

- (NSString *)placeholder {
    return objc_getAssociatedObject(self, placeholderKey);
}

- (void)setPlaceholder:(NSString *)placeholder {
    objc_setAssociatedObject(self, placeholderKey, placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self placeholderLabelConfig];
}

- (NSString *)endPlaceholder {
    return objc_getAssociatedObject(self, endPlaceholderKey);
}

- (void)setEndPlaceholder:(NSString *)endPlaceholder {
    objc_setAssociatedObject(self, endPlaceholderKey, endPlaceholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self endPlaceholderLabelConfig];
}

#pragma mark placeholder
- (void)placeholderLabelConfig {
    
    /**
     * 添加监听 
     * 监听placeholder hidden or not
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceHolderShow:) name:kObservePlaceholderShowNote object:nil];
    
    UILabel *placeholderLabel = [[UILabel alloc] init];
    [self addSubview:placeholderLabel];
        
    CGSize placeholderSize =  [self getTextSizeBy:placeholderFont withText:self.placeholder withWight:400];
    placeholderLabel.frame = CGRectMake(5, 10, placeholderSize.width, placeholderSize.height);
    placeholderLabel.textColor = [UIColor lightGrayColor];
    placeholderLabel.font = placeholderFont;
    placeholderLabel.tag = placeholderLabelKey;
    placeholderLabel.text = self.placeholder;
    
    
    if (self.placeholder == nil ||
        [self.placeholder isEqualToString:@""]) {
        [placeholderLabel removeFromSuperview];
    }
    
}

- (void)didPlaceHolderShow:(NSNotification *)note {
    
    if ([note.object integerValue] > 0) {
        if ([self viewWithTag:placeholderLabelKey]) {
            [self viewWithTag:placeholderLabelKey].hidden = YES;
        }
    }else{
        if ([self viewWithTag:placeholderLabelKey]) {
            [self viewWithTag:placeholderLabelKey].hidden = NO;
        }
    }
    
}

#pragma mark endPlaceholder
- (void)endPlaceholderLabelConfig {
    
    /**
     * 监听键盘
     * change endPlaceholderLabel frame
     *
     * 监听输入
     * 实时更新输入字数
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeEndText:)
                                                 name:kObserveEndPlaceholderNote
                                               object:nil];
    
    UILabel *endLabel = [[UILabel alloc] init];
    [self.superview addSubview:endLabel];
    
    CGSize  endSize =  [self getTextSizeBy:placeholderFont withText:self.endPlaceholder withWight:400];
    CGFloat endH = endSize.height;
    CGFloat endY = self.frame.origin.y + self.frame.size.height;
    
    endLabel.frame = CGRectMake(self.frame.origin.x, endY, self.frame.size.width, endH);
    endLabel.textColor = [UIColor lightGrayColor];
    endLabel.font = placeholderFont;
    endLabel.tag = endPlaceholderLabelKey;
    endLabel.text = [NSString stringWithFormat:@"0/∞ %@",self.endPlaceholder];
    endLabel.textAlignment = NSTextAlignmentRight;
    
    if (self.endPlaceholder == nil ||
        [self.endPlaceholder isEqualToString:@""]) {
        [endLabel removeFromSuperview];
    }
}

- (void)observeEndText:(NSNotification *)note {
    
    UILabel *label = [self.superview viewWithTag:endPlaceholderLabelKey];
    
    NSString *numStr = [NSString stringWithFormat:@"%ld",[note.object integerValue]];
    label.text = [NSString stringWithFormat:@"%@/∞ %@",numStr,self.endPlaceholder];
    
}

#pragma mark -- 键盘显示的监听方法
-(void) keyboardShow:(NSNotification *) note
{
    // 时间
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    // 曲线
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    UIView *ephView = [self.superview viewWithTag:endPlaceholderLabelKey];
    
    // 获取输入框的位置和大小
    CGRect containerFrame = ephView.frame;
    containerFrame.origin.y = self.frame.origin.y + self.frame.size.height - ephView.frame.size.height - 5;
    
    // 动画改变位置
    [UIView animateWithDuration:[duration floatValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        // 更改输入框的位置
        [self.superview viewWithTag:endPlaceholderLabelKey].frame = containerFrame;
        
    }];
    
}

#pragma mark -- 键盘隐藏的监听方法
-(void) keyboardHide:(NSNotification *) note
{
    // 时间
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    // 曲线
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    
    UIView *ephView = [self.superview viewWithTag:endPlaceholderLabelKey];
    
    // 获取输入框的位置和大小
    CGRect containerFrame = ephView.frame;
    containerFrame.origin.y = self.frame.origin.y + self.frame.size.height - ephView.frame.size.height - 5;
    
    // 动画改变位置
    [UIView animateWithDuration:[duration floatValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        // 更改输入框的位置
        [self.superview viewWithTag:endPlaceholderLabelKey].frame = containerFrame;
        
    }];
}

- (CGSize)getTextSizeBy:(UIFont*)font withText:(NSString *)text withWight:(CGFloat)weight{
    if (weight == 0) {
        weight = 500;
    }
    CGSize size = CGSizeMake(weight, 10000);
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize textSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    return textSize;
}

@end
