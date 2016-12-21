//
//  SJCacheModel+CoreDataProperties.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/21.
//  Copyright © 2016年 shenj. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "SJCacheModel+CoreDataProperties.h"

@implementation SJCacheModel (CoreDataProperties)

+ (NSFetchRequest<SJCacheModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SJCacheModel"];
}

@dynamic attributeText;
@dynamic images;
@dynamic links;
@dynamic title;
@dynamic time;

@end
