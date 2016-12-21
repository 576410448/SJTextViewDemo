//
//  SJTextTools.m
//  SJTextTools
//
//  Created by shenj on 16/11/16.
//  Copyright © 2016年 shenj. All rights reserved.
//

/**
 * 屏幕宽高
 */
# define text_heigth [[UIScreen mainScreen]bounds].size.height
# define text_width [[UIScreen mainScreen]bounds].size.width - 34.00

#import "SJTextTools.h"
#import "SJTextManager.h"

@implementation SJTextTools

/*-----------------*/

#pragma mark changeAttributes
+ (NSAttributedString *)changeAttriButesWithString:(NSAttributedString *)frontStr
                                          withFont:(CGFloat)font
                                         withRange:(NSRange)range
                                         isOblique:(BOOL)isOblique
                                            isBold:(BOOL)isBold
                                      isCenterLine:(BOOL)isCenterLine
                                       isUnderLine:(BOOL)isUnderLine
                                        changeType:(changeAttributeType)type{
    
    /**
     NSStrikethroughStyleAttributeName 删除线
     NSStrikethroughColorAttributeName 删除线颜色
     NSExpansionAttributeName 加粗
     NSUnderlineStyleAttributeName 下划线
     NSUnderlineColorAttributeName 下划线颜色
     */
    
    NSMutableAttributedString *allStr = [[NSMutableAttributedString alloc] initWithAttributedString:frontStr];
    
    if (type == changeAttributeTypeBold) {
        [allStr addAttributes:@{NSStrokeWidthAttributeName:(isBold?@-3:@0), // 加粗
                                } range:range];
        
    }else if (type == changeAttributeTypeOblique){
        [allStr addAttributes:@{NSObliquenessAttributeName :(isOblique?@0.3:@0)//斜体
                                } range:range];
        
    }else if (type == changeAttributeTypeCenterLine){
        [allStr addAttributes:@{NSStrikethroughStyleAttributeName:(isCenterLine?@1:@0), // 删除线
                                NSStrikethroughColorAttributeName:[UIColor redColor],  // 删除线颜色
                                } range:range];
        
    }else if (type == changeAttributeTypeFont){ // font
        [allStr addAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:font]
                                } range:range];

    }else if (type == changeAttributeTypeUnderLine){
        [allStr addAttributes:@{NSUnderlineStyleAttributeName:(isUnderLine?@1:@0), // 下划线
                                NSUnderlineColorAttributeName:[UIColor blueColor],  // 下划线颜色
                                } range:range];
        
    }else if (type == changeAttributeTypeCancel){
        [allStr addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor] // 字体颜色
                                } range:range];
        
    }else{
        // 意外情况 不做操作
        return frontStr;
    }
    
    return allStr;
    
}

#pragma mark insertText
+ (NSAttributedString *)insertAttriButesWithFullText:(NSAttributedString *)fullText
                                           insertStr:(NSString *)insertStr
                                            withFont:(CGFloat)font
                                           withRange:(NSRange)range
                                           isOblique:(BOOL)isOblique
                                              isBold:(BOOL)isBold
                                        isCenterLine:(BOOL)isCenterLine
                                         isUnderLine:(BOOL)isUnderLine{
    
    NSInteger bfLength = range.location;
    NSInteger afLength = fullText.length - bfLength - range.length;
    
    // 前文
    NSMutableAttributedString *bfStr = [[NSMutableAttributedString alloc] initWithAttributedString:[fullText attributedSubstringFromRange:NSMakeRange(0, bfLength)]];
    
    // 插入文
    NSMutableAttributedString *insertAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:insertStr]];
    
    [insertAttStr addAttributes:@{NSStrokeWidthAttributeName:(isBold?@-3:@0), // 加粗
                                  NSStrokeColorAttributeName:[UIColor blackColor],
                                  NSObliquenessAttributeName :(isOblique?@0.3:@0),//斜体
                                  NSStrikethroughStyleAttributeName:(isCenterLine?@1:@0), // 删除线
                                  NSStrikethroughColorAttributeName:[UIColor redColor],  // 删除线颜色
                                  NSUnderlineStyleAttributeName:(isUnderLine?@1:@0), // 下划线
                                  NSUnderlineColorAttributeName:[UIColor blueColor],  // 下划线颜色
                                  NSFontAttributeName :[UIFont systemFontOfSize:font]
                                  }
                          range:NSMakeRange(0, insertStr.length)];
    
    // 后文
    NSAttributedString *afStr = [fullText attributedSubstringFromRange:NSMakeRange(bfLength+range.length, afLength)];
    
    // 拼接
    [bfStr insertAttributedString:insertAttStr atIndex:bfLength];
    [bfStr insertAttributedString:afStr atIndex:(bfLength + insertStr.length)];
    
    return bfStr;
    
}

#pragma maek 插入图片
+ (NSAttributedString *)insertImageWithFullText:(NSAttributedString *)fullText
                                    insertImage:(UIImage *)image
                                      withRange:(NSRange)range{
    
    CGSize  imgSize = image.size;
    CGFloat newImgW = imgSize.width;
    CGFloat newImgH = imgSize.height;
    CGFloat textW   = text_width;
    
    NSInteger bfLength = range.location;
    NSInteger afLength = fullText.length - bfLength - range.length;
    
    if (newImgW > textW) {
        
        CGFloat ratio = textW / newImgW;
        newImgW  = textW;
        newImgH *= ratio;
    }
    
    NSAttributedString *enterStr = [[NSAttributedString alloc] initWithString:@"\n"];
    
    // 前文
    NSMutableAttributedString *bfStr = [[NSMutableAttributedString alloc] initWithAttributedString:[fullText attributedSubstringFromRange:NSMakeRange(0, bfLength)]];
    
    
    /*---------------添加内容 start-----------------*/
    // 转换图片
    NSTextAttachment *attachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, newImgW, newImgH);
    NSAttributedString *text = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *imageText = [[NSMutableAttributedString alloc] initWithAttributedString:text];
    
    // 前文换行
    [imageText insertAttributedString:enterStr atIndex:0];
    
    // 换行
    [imageText insertAttributedString:enterStr atIndex:imageText.length];
    [imageText insertAttributedString:enterStr atIndex:imageText.length];
    
    NSMutableAttributedString *paragraphStr = [[NSMutableAttributedString alloc] initWithString:@"图片来自SJTextViewDemo"];
    
    // 拼接图片注释
    [imageText insertAttributedString:paragraphStr atIndex:imageText.length];
    
    // 换行
    [imageText insertAttributedString:enterStr atIndex:imageText.length];
    
    // 描述分割线
    NSTextAttachment *lineMent = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    
    // graphincs begin
    UIImage *shortLine = [UIImage imageNamed:@"lineShort"];
    
    UIGraphicsBeginImageContext(CGSizeMake(text_width, 0.5));
    
    [shortLine drawInRect:CGRectMake(0, 0, text_width, 0.5)];
    
    UIImage *shortImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    //  graphincs end
    
    lineMent.image = shortImage;
    lineMent.bounds = CGRectMake(0, 0, text_width, 1);
    NSAttributedString *lineText = [NSAttributedString attributedStringWithAttachment:lineMent];
    
    // 拼接分割线
    [imageText insertAttributedString:lineText atIndex:imageText.length];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    // 添加段落样式
    [imageText addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, imageText.length)];
    
    [imageText addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                               NSObliquenessAttributeName :@0.3,//斜体
                               NSFontAttributeName :[UIFont systemFontOfSize:12]
                               }
                       range:NSMakeRange(0, imageText.length)];

    /*---------------添加内容 end-----------------*/
    
    // 前文拼接图片
    [bfStr insertAttributedString:imageText atIndex:bfStr.length];
    
    // 后文
    NSAttributedString *afStr = [fullText attributedSubstringFromRange:NSMakeRange(bfLength + range.length, afLength)];
    
    // 拼接转换后的attributeStirng
    [bfStr insertAttributedString:afStr atIndex:bfStr.length];
    
    return bfStr;
}

#pragma mark 插入分割线
+ (NSAttributedString *)insertSeplineWithFullText:(NSAttributedString *)fullText
                                        withRange:(NSRange)range {
    
    UIImage *image = [UIImage imageNamed:@"line"];
    
    NSInteger bfLength = range.location;
    NSInteger afLength = fullText.length - bfLength - range.length;
    
    NSAttributedString *enterStr = [[NSAttributedString alloc] initWithString:@"\n"];
    
    // 前文
    NSMutableAttributedString *bfStr = [[NSMutableAttributedString alloc] initWithAttributedString:[fullText attributedSubstringFromRange:NSMakeRange(0, bfLength)]];
    
    
    /*---------------添加内容 start-----------------*/
    // 转换图片
    NSTextAttachment *attachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, text_width, 0.5);
    NSAttributedString *text = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *imageText = [[NSMutableAttributedString alloc] initWithAttributedString:text];
    
    // 前文换行
    [imageText insertAttributedString:enterStr atIndex:0];
    
    /*---------------添加内容 end-----------------*/
    
    // 前文拼接图片
    [bfStr insertAttributedString:imageText atIndex:bfStr.length];
    
    // 后文
    NSAttributedString *afStr = [fullText attributedSubstringFromRange:NSMakeRange(bfLength + range.length, afLength)];
    
    // 拼接转换后的attributeStirng
    [bfStr insertAttributedString:afStr atIndex:bfStr.length];
    
    return bfStr;
    
}

#pragma mark 超链接
+ (NSAttributedString *)addLinkWithFullText:(NSAttributedString *)fullText
                                  insertStr:(NSString *)insertStr
                                   withFont:(CGFloat)font
                                  withRange:(NSRange)range
                                  isOblique:(BOOL)isOblique
                                     isBold:(BOOL)isBold
                               isCenterLine:(BOOL)isCenterLine
                                isUnderLine:(BOOL)isUnderLine{
    
    NSInteger bfLength = range.location;
    NSInteger afLength = fullText.length - bfLength - range.length;
    
    // 前文
    NSMutableAttributedString *bfStr = [[NSMutableAttributedString alloc] initWithAttributedString:[fullText attributedSubstringFromRange:NSMakeRange(0, bfLength)]];
    
    // 插入文
    NSMutableAttributedString *insertAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:insertStr]];
    
    [insertAttStr addAttributes:@{NSStrokeWidthAttributeName:(isBold?@-3:@0), // 加粗
                                  NSObliquenessAttributeName :(isOblique?@0.3:@0),//斜体
                                  NSStrikethroughStyleAttributeName:(isCenterLine?@1:@0), // 删除线
                                  NSStrikethroughColorAttributeName:[UIColor redColor],  // 删除线颜色
                                  NSUnderlineStyleAttributeName:(isUnderLine?@1:@0), // 下划线
                                  NSUnderlineColorAttributeName:[UIColor blueColor],  // 下划线颜色
                                  NSFontAttributeName :[UIFont systemFontOfSize:font],
                                  NSForegroundColorAttributeName : [UIColor blueColor], // 字体颜色
                                  }
                          range:NSMakeRange(0, insertStr.length)];
    
    // 后文
    NSAttributedString *afStr = [fullText attributedSubstringFromRange:NSMakeRange(bfLength+range.length, afLength)];
    
    // 拼接
    [bfStr insertAttributedString:insertAttStr atIndex:bfLength];
    [bfStr insertAttributedString:afStr atIndex:(bfLength + insertStr.length)];
    
    return bfStr;
    
}

#pragma mark insertTextInImageDic
+ (NSAttributedString *)insertTexrInImageWithFullText:(NSAttributedString *)fullText
                                           insertStr:(NSString *)insertStr
                                            withRange:(NSRange)range
                                         withImageDic:(NSDictionary *)imageDic{
    NSInteger bfLength = range.location;
    NSInteger afLength = fullText.length - bfLength - range.length;
    
    // 前文
    NSMutableAttributedString *bfStr = [[NSMutableAttributedString alloc] initWithAttributedString:[fullText attributedSubstringFromRange:NSMakeRange(0, bfLength)]];
    
    // 插入文
    NSMutableAttributedString *insertAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:insertStr]];
    
    [insertAttStr addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                  NSObliquenessAttributeName :@0.3,//斜体
                                  NSFontAttributeName :[UIFont systemFontOfSize:12]
                                  }
                          range:NSMakeRange(0, insertStr.length)];
    
    // 后文
    NSAttributedString *afStr = [fullText attributedSubstringFromRange:NSMakeRange(bfLength+range.length, afLength)];
    
    // 拼接
    [bfStr insertAttributedString:insertAttStr atIndex:bfLength];
    [bfStr insertAttributedString:afStr atIndex:(bfLength + insertStr.length)];
    
    // 段落样式
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    [bfStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange([imageDic[kImageRangeLocationKey] integerValue], [imageDic[kImageRangeLengthKey] integerValue])];
        
    return bfStr;
}

@end
