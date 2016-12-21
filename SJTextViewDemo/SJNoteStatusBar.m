//
//  SJNoteStatusBar.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/15.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJNoteStatusBar.h"
#import "SJTextHeader.h"

@interface SJNoteStatusBar ()

@property (nonatomic ,strong) UIWindow *statusBar;

@end

@implementation SJNoteStatusBar

static SJNoteStatusBar *sjNoteStatusBar;
+ (instancetype)noteStatusManager {
    
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        sjNoteStatusBar = [[self alloc] init];
    });
    return sjNoteStatusBar;
    
}

+ (void) alertWithText:(NSString *)text {
    [[self noteStatusManager] alertWithText:text];
}

- (void) alertWithText:(NSString *)text {
    
    // 通知 数据修改
    [[NSNotificationCenter defaultCenter] postNotificationName:kCacheDataHasChangeNote object:nil];
    
    CGFloat mainW = [UIScreen mainScreen].bounds.size.width;
    
    _statusBar = [[UIWindow alloc] initWithFrame:CGRectMake(0, -20, mainW, 20)];
    _statusBar.hidden = NO;
    
    _statusBar.backgroundColor = [UIColor clearColor];
    
    UIButton *statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    statusBtn.frame = CGRectMake(0, 0, mainW, 20);
    [_statusBar addSubview:statusBtn];
    
    statusBtn.backgroundColor = [UIColor colorWithRed:0.10f green:0.77f blue:0.31f alpha:1.00f];
    [statusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [statusBtn setTitle:text forState:UIControlStateNormal];
    
    _statusBar.windowLevel = UIWindowLevelStatusBar + 1;
    [_statusBar makeKeyAndVisible];
    
    // 出现
    UIBezierPath *showPath = [[UIBezierPath alloc] init];
    [showPath moveToPoint:_statusBar.center];
    [showPath addLineToPoint:CGPointMake(mainW/2.0, 10)];
    
    CAKeyframeAnimation *showAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    showAnimation.path = showPath.CGPath;
    showAnimation.fillMode = kCAFillModeBoth;
    showAnimation.removedOnCompletion = NO;
    showAnimation.duration = 0.24;
    
    [_statusBar.layer addAnimation:showAnimation forKey:nil];
    
    // 隐藏
    UIBezierPath *hiddenPath = [[UIBezierPath alloc] init];
    [hiddenPath moveToPoint:CGPointMake(mainW/2.0, 10)];
    [hiddenPath addLineToPoint:CGPointMake(mainW/2.0, -10)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*1), dispatch_get_main_queue(), ^{
        
        CAKeyframeAnimation *hiddenAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        hiddenAnimation.path = hiddenPath.CGPath;
        hiddenAnimation.fillMode = kCAFillModeBoth;
        hiddenAnimation.removedOnCompletion = NO;
        hiddenAnimation.duration = 0.24;
        hiddenAnimation.beginTime = CACurrentMediaTime()+1;
        
        [_statusBar.layer addAnimation:hiddenAnimation forKey:nil];
        
        [[UIApplication sharedApplication].windows.firstObject makeKeyAndVisible];
        
    });
    
}

@end
