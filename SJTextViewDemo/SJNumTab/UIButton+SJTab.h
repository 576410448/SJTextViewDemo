//
//  UIButton+SJTab.h
//  SJNavigationBar
//
//  Created by shenj on 16/10/31.
//  Copyright © 2016年 shenj. All rights reserved.
//  下载地址：https://github.com/576410448/SJNumTabDmeo
#import <UIKit/UIKit.h>
#import "SJTabButton.h"

typedef void (^Sj_tabRemoveEventBlock)();

@interface UIButton (SJTab)

@property (nonatomic ,strong ,readonly) SJTabButton *numTab;

/** 标签是否支持操作 */
@property (nonatomic ,readwrite) BOOL sj_tabUserInteractionEnabled;

/** 标签显示数 */
@property (nonatomic ,assign) NSInteger sj_tabNum;

/** 标签右边距 */
@property (nonatomic ,assign) CGFloat   sj_rightOfSet;

/** 标签上边距 */
@property (nonatomic ,assign) CGFloat   sj_topOfSet;

/** 标签背景色 */
@property (nonatomic ,retain) UIColor * sj_backColor;

/** 标签字体色 */
@property (nonatomic ,retain) UIColor * sj_numColor;

/**移除回调*/
@property (nonatomic ,copy) Sj_tabRemoveEventBlock sj_tabRemoveEventBlock;


@end
