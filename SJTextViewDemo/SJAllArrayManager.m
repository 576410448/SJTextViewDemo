//
//  SJAllArrayManager.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/6.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SJAllArrayManager.h"

@implementation SJAllArrayManager

+ (instancetype)allArrayManager{
    
    static SJAllArrayManager *_a = nil;
    if (!_a) {
        _a = [[SJAllArrayManager alloc] init];
        
        _a.allArray = [[NSMutableArray alloc] init];
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:@""];
        [_a.allArray addObject:@{kAllArrayTextKey:att}];
    }
    
    return _a;
    
}

- (void)setAllArray:(NSMutableArray *)allArray {
    
    if (!_allArray) {
        
        _allArray = [[NSMutableArray alloc] init];
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:@""];
        [_allArray addObject:@{kAllArrayTextKey:att}];
    }
    
    if (!allArray) {
        
        _allArray = [[NSMutableArray alloc] init];
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:@""];
        [_allArray addObject:@{kAllArrayTextKey:att}];
        
    }else {
        
        [_allArray addObjectsFromArray:allArray];
    }
    
}

//- (NSMutableArray *)allArray {
//    if (!_allArray) {
//        
//        _allArray = [[NSMutableArray alloc] init];
//        NSAttributedString *att = [[NSAttributedString alloc] initWithString:@""];
//        [_allArray addObject:@{kAllArrayTextKey:att}];
//    }
//    return _allArray;
//}

+ (void) addObject:(id)object atIndex:(NSInteger)index {
    [[self allArrayManager] addObject:object atIndex:index];
}

- (void) addObject:(id)object atIndex:(NSInteger)index {
        
    NSMutableArray *beforeArr = [NSMutableArray arrayWithArray:[_allArray subarrayWithRange:NSMakeRange(0, index)]];
    
    [beforeArr addObject:object];
    
    _allArray = beforeArr.mutableCopy;
    
}

@end
