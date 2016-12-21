//
//  SJTextModel.h
//  SJTextViewDemo
//
//  Created by shenj on 16/11/22.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  记录模型

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SJTextModel : NSObject

@property (nonatomic ,retain)   UIImage     * kSJTextImage;

@property (nonatomic ,  copy)   NSString    * kSJTextInputText;

@property (nonatomic ,  copy)   NSString    * kSJTextSuperLinkTitle;        // 超链接标题

@property (nonatomic ,assign)   NSInteger     kSJTextChangeAttributeType;   // 状态类型(下面为状态)

@property (nonatomic ,assign)   CGFloat       kSJTextNextFont;              // 字体大小

@property (nonatomic ,assign)   BOOL          kSJTextIsOblique;             // 斜体

@property (nonatomic ,assign)   BOOL          kSJTextIsBold;                // 加粗

@property (nonatomic ,assign)   BOOL          kSJTextIsCenterLine;          // 中划线

@property (nonatomic ,assign)   BOOL          kSJTextIsUnderLine;           // 中划线

+(SJTextModel *)prepareDictionryChangeToModel:(NSDictionary *)dic;


@end
