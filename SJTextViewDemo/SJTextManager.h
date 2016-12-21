//
//  SJTextManager.h
//  SJTextViewDemo
//
//  Created by shenj on 16/11/25.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  Link Image 数据源管理类


#import <Foundation/Foundation.h>
#import "SJTextHeader.h"

@interface SJTextManager : NSObject

+ (instancetype)managerWithSelectedRange:(NSRange)range;

/**外部调用alert判断*/
- (void)alertLinkByBtnAction:(BOOL)isBtnTap alertBlock:(void(^)(NSDictionary *linkDic))alertBlock;

/**判断此处是否有超链接 (当且仅当selectedRange完全包含于linkDicRange时)*/
- (NSArray *)isThereHaveLink;

/**调用删除*/
- (void)linkDeleteSelectedWithRange:(NSRange)range;

/**更新超链接数据源内range记录值*/
- (void)updateLinkRange:(NSRange)range withDelete:(BOOL)isDelete;

/**修改 selectedRange内 所有超链接*/
- (void)modifyLinkDicIncludedeInRangee:(NSRange)range;

/**link数据源*/
@property (nonatomic ,strong) NSMutableArray *linkDicArr;


/**判断此处是否有图片*/
- (NSArray *)isThereInImageRange;

/**调用删除*/
- (void)imageDeleteSelectedWithRange:(NSRange)range;

/**修改 selectedRange内 所有图片*/
- (void)modifyImageDicIncludedeInRangee:(NSRange)range;

/**更新image数据源内range记录值*/
- (void)updateImageRange:(NSRange)range withDelete:(BOOL)isDelete;

/**图片数据源*/
@property (nonatomic ,strong) NSMutableArray *imageDicArr;

@end
