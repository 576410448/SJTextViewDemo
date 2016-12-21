//  SJTabButton.h
//  SJNavigationBar
//
//  Created by shenj on 16/11/1.
//  Copyright © 2016年 shenj. All rights reserved.
//  下载地址：https://github.com/576410448/SJNumTabDmeo

#import <UIKit/UIKit.h>

@interface SJTabButton : UIButton

/** 消除角标回调（取消字符串关联）*/
@property (nonatomic ,copy) void(^killBlock)();

/** 消除角标掉用 */
- (void)btnRemoveClick;

/** 是否交互调用 */
- (void)cancelTap:(BOOL)isCancel;

@end
