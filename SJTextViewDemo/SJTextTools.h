//
//  SJTextTools.h
//  SJTextTools
//
//  Created by shenj on 16/11/16.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  Attrebute转换类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,changeAttributeType) {
    changeAttributeTypeBold        = 1,
    changeAttributeTypeOblique     = 2,
    changeAttributeTypeCenterLine  = 3,
    changeAttributeTypeFont        = 4,
    changeAttributeTypeUnderLine   = 5,
    changeAttributeTypeCancel      = 6
};

@interface SJTextTools : NSObject

/**改变状态*/
+ (NSAttributedString *)changeAttriButesWithString:(NSAttributedString *)frontStr
                                          withFont:(CGFloat)font
                                         withRange:(NSRange)range
                                         isOblique:(BOOL)isOblique
                                            isBold:(BOOL)isBold
                                      isCenterLine:(BOOL)isCenterLine
                                       isUnderLine:(BOOL)isUnderLine
                                        changeType:(changeAttributeType)type;

/**插入文字*/
+ (NSAttributedString *)insertAttriButesWithFullText:(NSAttributedString *)fullStr
                                           insertStr:(NSString *)insertStr
                                            withFont:(CGFloat)font
                                           withRange:(NSRange)range
                                           isOblique:(BOOL)isOblique
                                              isBold:(BOOL)isBold
                                        isCenterLine:(BOOL)isCenterLine
                                         isUnderLine:(BOOL)isUnderLine;

/**插入图片*/
+ (NSAttributedString *)insertImageWithFullText:(NSAttributedString *)fullText
                                    insertImage:(UIImage *)image
                                      withRange:(NSRange)range;

/**插入分割线*/
+ (NSAttributedString *)insertSeplineWithFullText:(NSAttributedString *)fullText
                                      withRange:(NSRange)range;

/**超链接*/
+ (NSAttributedString *)addLinkWithFullText:(NSAttributedString *)fullText
                                  insertStr:(NSString *)insertStr
                                   withFont:(CGFloat)font
                                  withRange:(NSRange)range
                                  isOblique:(BOOL)isOblique
                                     isBold:(BOOL)isBold
                               isCenterLine:(BOOL)isCenterLine
                                isUnderLine:(BOOL)isUnderLine;

/**图片内编辑*/
+ (NSAttributedString *)insertTexrInImageWithFullText:(NSAttributedString *)fullText
                                            insertStr:(NSString *)insertStr
                                            withRange:(NSRange)range
                                         withImageDic:(NSDictionary *)imageDic;
@end
