//
//  SJCacheModel+CoreDataProperties.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/21.
//  Copyright © 2016年 shenj. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "SJCacheModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SJCacheModel (CoreDataProperties)

+ (NSFetchRequest<SJCacheModel *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *attributeText;
@property (nullable, nonatomic, retain) NSData *images;
@property (nullable, nonatomic, retain) NSData *links;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *time;

@end

NS_ASSUME_NONNULL_END
