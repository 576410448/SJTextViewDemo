//
//  UIButton+SJTab.m
//  SJNavigationBar
//
//  Created by shenj on 16/10/31.
//  Copyright © 2016年 shenj. All rights reserved.
//  下载地址：https://github.com/576410448/SJNumTabDmeo

# define numFont 12
# define sizeMin [self getTextSizeBy:[UIFont systemFontOfSize:numFont] withText:@"9" withWight:0]
# define sizeMax [self getTextSizeBy:[UIFont systemFontOfSize:numFont] withText:@"999" withWight:0]


# define rightOfSetDefault 0
# define topOfSetDefault 0
# define backColorDefault [UIColor redColor]
# define numColorDefault [UIColor whiteColor]



/**
 * 使用方法：@SJWeakObj(self); // 弱化self
 *
 * sjWeakslef 代替self使用
 * 强化同理
 */
# define SJWeakObj(o) autoreleasepool{} __weak typeof(o) sjWeak##o = o;     // 弱引用
# define SJStrongObj(o) autoreleasepool{} __strong typeof(o) o = sjWeak##o; // 强引用

#import "UIButton+SJTab.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UIView (SJTab)

static const void *tabUserInteractionEnabledKey = &tabUserInteractionEnabledKey;
static const void *rightOfSetKey = &rightOfSetKey;
static const void *topOfSetKey = &topOfSetKey;
static const void *backColorKey = &backColorKey;
static const void *numColorKey = &numColorKey;
static const void *numTabKey = &numTabKey;
static const void *numTabStrKey = &numTabStrKey;

#pragma mark - 支持用户操作
- (BOOL)sj_tabUserInteractionEnabled{
    NSNumber *tabUser = objc_getAssociatedObject(self, tabUserInteractionEnabledKey);
    return tabUser.boolValue;
}

- (void)setSj_tabUserInteractionEnabled:(BOOL)sj_tabUserInteractionEnabled{
    NSNumber *boolNum = [NSNumber numberWithBool:sj_tabUserInteractionEnabled];
    objc_setAssociatedObject(self, tabUserInteractionEnabledKey, boolNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self showNumTab];
}

#pragma mark - 右边距
- (CGFloat)sj_rightOfSet{
    NSNumber *rightOfSetValue = objc_getAssociatedObject(self, rightOfSetKey);
    return rightOfSetValue.floatValue;
}

- (void)setSj_rightOfSet:(CGFloat)sj_rightOfSet{
    objc_setAssociatedObject(self, rightOfSetKey, @(sj_rightOfSet), OBJC_ASSOCIATION_ASSIGN);
    //    self.transform = CGAffineTransformMakeScale(rightOfSet, rightOfSet);
    [self showNumTab];
}

#pragma mark - 上边距
- (CGFloat)sj_topOfSet{
    NSNumber *topOfSetValue = objc_getAssociatedObject(self, topOfSetKey);
    return topOfSetValue.floatValue;
}

- (void)setSj_topOfSet:(CGFloat)sj_topOfSet{
    objc_setAssociatedObject(self, topOfSetKey, @(sj_topOfSet), OBJC_ASSOCIATION_ASSIGN);
    //    self.transform = CGAffineTransformMakeScale(topOfSet, topOfSet);
    [self showNumTab];
}

#pragma mark - tab背景色
- (UIColor *)sj_backColor{
    return objc_getAssociatedObject(self, backColorKey);
}

- (void)setSj_backColor:(UIColor *)sj_backColor{
    objc_setAssociatedObject(self, backColorKey, sj_backColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self showNumTab];
}

#pragma mark - tab数字色
- (UIColor *)sj_numColor{
    return objc_getAssociatedObject(self, numColorKey);
}

- (void)setSj_numColor:(UIColor *)sj_numColor{
    objc_setAssociatedObject(self, numColorKey, sj_numColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self showNumTab];
}


#pragma mark - numTab
- (SJTabButton *)numTab{
    return objc_getAssociatedObject(self, numTabKey);
}
- (void)setNumTab:(SJTabButton *)numTab{
    objc_setAssociatedObject(self, numTabKey, numTab, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self showNumTab];
}

#pragma mark - tanNum
- (NSInteger)sj_tabNum{
    NSNumber * tabNum = objc_getAssociatedObject(self, numTabStrKey);
    return tabNum.integerValue;
}

- (void)setSj_tabNum:(NSInteger)setSj_tabNum{
    objc_setAssociatedObject(self, numTabStrKey, @(setSj_tabNum), OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self showNumTab];
}

#pragma mark - 取消字符串相应关联
- (void)removeTab{
    objc_setAssociatedObject(self, numTabKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 计算文字长宽
- (CGSize)getTextSizeBy:(UIFont*)font withText:(NSString *)text withWight:(CGFloat)weight{
    if (weight == 0) {
        weight = 500;
    }
    CGSize size = CGSizeMake(weight, 10000);
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize textSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    return textSize;
}

- (void)showNumTab{
    
    // 等于0时 销毁
    if (self.sj_tabNum == 0) {
        [self.numTab btnRemoveClick];
        return;
    }
    
    // 不存在的时候创建
    if (!self.numTab) {
        self.numTab = [SJTabButton buttonWithType:UIButtonTypeCustom];
        
        @SJWeakObj(self);
        [self.numTab setKillBlock:^{
            [sjWeakself removeTab];
        }];
        
        [self addSubview:self.numTab];
    }
    
    self.numTab.titleLabel.font = [UIFont systemFontOfSize:numFont];
    
    // 限制numTab长度
    CGSize size = self.sj_tabNum > 999?sizeMax:[self getTextSizeBy:self.numTab.titleLabel.font withText:[NSString stringWithFormat:@"%ld",self.sj_tabNum] withWight:0];
    CGFloat defaultHeight = sizeMin.width + 10;
    
    
    if (self.sj_tabNum < 10) {  // 个位数取圆
        self.numTab.frame = CGRectMake(0, 0, defaultHeight, defaultHeight);
    }else{
        self.numTab.frame = CGRectMake(0, 0, size.width+10, defaultHeight);
    }
    
    CGFloat xOfSet = (self.sj_rightOfSet?self.sj_rightOfSet:rightOfSetDefault);
    CGFloat yOfSet = (self.sj_topOfSet?self.sj_topOfSet:topOfSetDefault);
    
    CGFloat centerX = self.frame.size.width - self.numTab.frame.size.width/2.0 - xOfSet;
    CGFloat centerY = defaultHeight/2.0 + yOfSet;
    
    self.numTab.center = CGPointMake(centerX, centerY);
    self.numTab.backgroundColor =  (self.sj_backColor?self.sj_backColor:backColorDefault);
    self.numTab.layer.cornerRadius = defaultHeight/2.0;
    [self.numTab setTitleColor:(self.sj_numColor?self.sj_numColor:numColorDefault) forState:UIControlStateNormal];
    
    // 控制显示内容长度
    [self.numTab setTitle:(self.sj_tabNum > 999?@"···":[NSString stringWithFormat:@"%ld",self.sj_tabNum]) forState:UIControlStateNormal];
    
    // numtab可操作性
    [self.numTab cancelTap:self.sj_tabUserInteractionEnabled];
}

@end
