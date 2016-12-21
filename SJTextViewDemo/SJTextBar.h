//
//  SJTextBar.h
//  SJTextTools
//
//  Created by shenj on 16/11/17.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  功能工具类

#import <UIKit/UIKit.h>

@interface SJTextBar : UIView

/**添加图片*/
@property (nonatomic ,copy) void(^addImageBlock)();

/**分割线*/
@property (nonatomic ,copy) void(^sepLineBlock)();

/**斜体*/
@property (nonatomic ,copy) void(^changeToObliqueBlock)(BOOL isOblique);

/**加粗*/
@property (nonatomic ,copy) void(^changeToBoldBlock)(BOOL isBold);

/**删除线（中划线）*/
@property (nonatomic ,copy) void(^changeToCenterLineBlock)(BOOL isCenterLine);

/**下划线*/
@property (nonatomic ,copy) void(^changeToUnderLineBlock)(BOOL isUnderLine);

/**字体*/
@property (nonatomic ,copy) void(^textFontBlock)(CGFloat textFont);

/**添加超链接*/
@property (nonatomic ,copy) void(^linkBlock)();

/**撤销*/
@property (nonatomic ,copy) void(^undoBlock)();

/**恢复*/
@property (nonatomic ,copy) void(^restoreBlock)();

@end
