//
//  SJAllArrayManager.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/6.
//  Copyright © 2016年 shenj. All rights reserved.
//
// 大数据源管理（撤销、恢复）

#import <Foundation/Foundation.h>
#import "SJTextHeader.h"

@interface SJAllArrayManager : NSObject

/**大数据源*/
@property (nonatomic ,strong) NSMutableArray *allArray;

+ (instancetype)allArrayManager;

+ (void) addObject:(id)object atIndex:(NSInteger)index;

- (void) addObject:(id)object atIndex:(NSInteger)index;

@end
