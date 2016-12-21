//
//  CacheListModel.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/15.
//  Copyright © 2016年 shenj. All rights reserved.
//
#define CoreDataManager [SJCacheManager coreDataManager]

#import "CacheListModel.h"
#import "SJCacheManager.h"
#import "SJCacheModel+CoreDataProperties.h"

@implementation CacheListModel

+ (NSMutableArray *)changeCoreDataArrayToArray:(NSArray *)coreDataArray{
        
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    for (SJCacheModel *cacheModel in coreDataArray) {
        
        CacheListModel *model = [[CacheListModel alloc] init];
        
        NSArray *images = [CoreDataManager changeToArrayByData:cacheModel.images];
        NSArray *links = [CoreDataManager changeToArrayByData:cacheModel.links];
        NSAttributedString *attStr = [CoreDataManager changeToAttributeStringByData:cacheModel.attributeText];
        NSString *title = attStr.string;
        if (title.length > 25) {
            title = [title substringWithRange:NSMakeRange(0, 15)];
        }
        
        [model setValue:images forKey:@"images"];
        [model setValue:links forKey:@"links"];
        [model setValue:attStr forKey:@"attributeString"];
        [model setValue:title forKey:@"title"];
        
        [mutableArray addObject:model];
        
    }
    
    return mutableArray;
    
}

@end
