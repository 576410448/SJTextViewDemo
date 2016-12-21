//
//  CacheListModel.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/15.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheListModel : NSObject

@property (nonatomic ,strong) NSAttributedString *attributeString;

@property (nonatomic ,strong) NSArray *images;

@property (nonatomic ,strong) NSArray *links;

@property (nonatomic ,strong) NSString *title;

+ (NSMutableArray *)changeCoreDataArrayToArray:(NSArray *)coreDataArray;

@end
