//
//  SJCacheManager.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/9.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  缓存、草稿管理

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SJCacheModel+CoreDataProperties.h"

static NSString *const mainManagerObjectModelFileName = @"SJCacheCoreData";
static NSString *const ManagerObjectModelFileName     = @"SJCacheCoreData";
static NSString *const EntityName                     = @"SJCacheModel";
static NSString *const sortKey                        = @"time";

@interface SJCacheManager : NSObject
//@property (nonatomic ,strong) SJCacheModel *cacheModel;

+ (instancetype) coreDataManager;

// 读取数据库中所有数据
- (NSArray *)showAllObjInCoreData;

// 数据库中是否存在
- (BOOL)isExistInCoredataFor:(NSDate *)time;

// 存入数据库
- (void)saveCoreData:(NSAttributedString *)attStr
               links:(NSArray *)links
              images:(NSArray *)images
                time:(NSDate *)time;

// 从数据库中删除
- (void)deleteFromeCoreData:(SJCacheModel *)model;

// data转换Array
- (NSArray *)changeToArrayByData:(NSData *)data;

// data转换attribute
- (NSAttributedString *)changeToAttributeStringByData:(NSData *)data;

@end
