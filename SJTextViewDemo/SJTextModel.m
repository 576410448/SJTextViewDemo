//
//  SJTextModel.m
//  SJTextViewDemo
//
//  Created by shenj on 16/11/22.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SJTextModel.h"

@implementation SJTextModel

+(SJTextModel *)prepareDictionryChangeToModel:(NSDictionary *)dic{
    
    SJTextModel *model = [[SJTextModel alloc] init];
    
    [model setValuesForKeysWithDictionary:dic];
    
    return model;
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end
