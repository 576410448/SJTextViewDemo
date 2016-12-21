//
//  SJTextManager.m
//  SJTextViewDemo
//
//  Created by shenj on 16/11/25.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SJTextManager.h"

@interface SJTextManager ()

@property (nonatomic ,assign) NSRange textSelectedRange;

@end

@implementation SJTextManager

+ (instancetype)managerWithSelectedRange:(NSRange)range{
    
    static SJTextManager *_p = nil;
    if (!_p) {
        _p = [[SJTextManager alloc] init];
        _p.linkDicArr = [[NSMutableArray alloc] init];
        _p.imageDicArr = [[NSMutableArray alloc] init];
        
    }
    _p.textSelectedRange = range;
    return _p;
    
}

/*------------link数据源 start--------------*/

- (void) setLinkDicArr:(NSMutableArray *)linkDicArr {
    
    if (!linkDicArr) {
        linkDicArr = [[NSMutableArray alloc] init];
    }
    _linkDicArr = linkDicArr.mutableCopy;
    
}

#pragma mark -- 开放接口 外部调用alert判断
- (void)alertLinkByBtnAction:(BOOL)isBtnTap alertBlock:(void (^)(NSDictionary *))alertBlock{
    
    if (isBtnTap) {  // 点击超链接调用
        
        if (![self isThereHaveLink]) {
            if (alertBlock) {
                alertBlock(nil);
            }
            
        }else{
            
            if ([self isThereHaveLink].count == 1) {
                if (alertBlock) {
                    alertBlock([self isThereHaveLink].firstObject);
                }
                
            }else{
                NSLog(@"添加超链接失败");
            }
        }
        
    }else{  // 通过光标调用
        
        if ([self isThereHaveLink].count == 1) {
            if (alertBlock) {
                alertBlock([self isThereHaveLink].firstObject);
            }
            
        }else{
            NSLog(@"添加超链接失败");
        }
        
    }

}

#pragma mark - 判断此处是否有超链接 (当且仅当selectedRange完全包含于linkDicRange时)
- (NSArray *)isThereHaveLink{
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    NSRange selectedRange = _textSelectedRange;
    
    NSInteger index = 0;
    for (NSDictionary *dic in _linkDicArr) {
        
        @autoreleasepool {
        
            index ++;
            
            NSNumber *rangLocation = dic[kLinkRangLocationKey];
            NSNumber *rangLength = dic[KLinkRangLengthKey];
            
            if (selectedRange.length == 0) {
                
                if ((selectedRange.location > rangLocation.integerValue &&
                     selectedRange.location < rangLocation.integerValue + rangLength.integerValue)) {
                    
                    [mutableArr addObject:dic];
                    break;
                    
                }
                
            }else{
                
                // 6种情况
                if ((selectedRange.location >= rangLocation.integerValue &&
                     selectedRange.location + selectedRange.length <= rangLocation.integerValue + rangLength.integerValue)) {
                    
                    [mutableArr addObject:dic];
                    break;
                    
                }else if ((selectedRange.location >= rangLocation.integerValue &&
                          selectedRange.location < rangLocation.integerValue + rangLength.integerValue)
                          ||
                          (selectedRange.location + selectedRange.length > rangLocation.integerValue &&
                           selectedRange.location + selectedRange.length < rangLocation.integerValue + rangLength.integerValue))
                {
                    continue;
                    
                }else if (selectedRange.location + selectedRange.length <= rangLocation.integerValue
                          ||
                          selectedRange.location >= rangLocation.integerValue + rangLength.integerValue){
                    
                    continue;
                    
                }
    //            else{
    //                
    //                    [mutableArr addObject:@"失败"];
    //                    [mutableArr addObject:@"失败"];
    //                    break;
    //                
    //                
    //            }
                
            }
        }
        
    }
    
    // 返回rang范围内存在的超链接数组
    if (mutableArr.count == 0) {
        return nil;
    }else{
        return mutableArr;
    }
    
}

#pragma mark - 调用删除
- (void)linkDeleteSelectedWithRange:(NSRange)range{
    
    if (range.length == 0) {
        return;
    }
    
    // 修改与删除link
    [self modifyLinkDicIncludedeInRangee:range];
    
    // 改变数据源超链接range
    [self updateLinkRange:range withDelete:YES];
}

#pragma mark - 更新超链接数据源内range记录值
- (void)updateLinkRange:(NSRange)range withDelete:(BOOL)isDelete{
    
    NSInteger location = range.location;
    NSInteger length   = range.length;
    NSLog(@"%ld--%ld",location,length);
    
    
    NSMutableArray *linkDicArr = _linkDicArr.mutableCopy;
    NSMutableArray *needModifyArr = [NSMutableArray array];
    // 提取所有需修改的linkDic
    for (NSDictionary *linkDic in linkDicArr) {
        
        @autoreleasepool {
            
            NSInteger linkLocation = [linkDic[kLinkRangLocationKey] integerValue];
            if (linkLocation >= location) {
                [_linkDicArr removeObject:linkDic];
                [needModifyArr addObject:linkDic];
            }
        }
        
    }
    
    
    if (isDelete) {
        // 减运算
        for (NSDictionary *linkDic in needModifyArr) {
            
            @autoreleasepool {
                NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:linkDic];
                NSNumber *newLocation = @([linkDic[kLinkRangLocationKey] integerValue] - length);
                [mutableDic setValue:newLocation forKey:kLinkRangLocationKey];
                [_linkDicArr addObject:mutableDic];
            }
            
        }
        
    }else{
        // 加运算
        for (NSDictionary *linkDic in needModifyArr) {
            
            @autoreleasepool {
                NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:linkDic];
                NSNumber *newLocation = @([linkDic[kLinkRangLocationKey] integerValue] + length);
                [mutableDic setValue:newLocation forKey:kLinkRangLocationKey];
                [_linkDicArr addObject:mutableDic
                 ];
            }
            
        }
    }
    
}

#pragma mark - 修改 selectedRange内 所有超链接
- (void)modifyLinkDicIncludedeInRangee:(NSRange)range{
    
    NSRange selectedRange = range;
    
    NSInteger selectedLocation = selectedRange.location;
    NSInteger selectedEnd = selectedRange.location + selectedRange.length;
    
    NSMutableArray *copyLinkArr = _linkDicArr.mutableCopy;
    for (NSDictionary *dic in copyLinkArr) {
        
        @autoreleasepool {
            
            NSNumber *rangLocation = dic[kLinkRangLocationKey];
            NSNumber *rangLength = dic[KLinkRangLengthKey];
            
            NSInteger linkLocation = rangLocation.integerValue;
            NSInteger linkEnd = rangLocation.integerValue + rangLength.integerValue;
            
            if (selectedLocation <= linkLocation && selectedEnd >= linkEnd) { // 完全在选中范围内
                [_linkDicArr removeObject:dic];
                
            }else if (selectedLocation < linkLocation && selectedEnd < linkEnd && selectedEnd > linkLocation){ // 删前面一节(选中)
                
                [_linkDicArr removeObject:dic];
                
                NSInteger length = linkEnd - selectedEnd;
                NSString *linkTitle = [dic[kLinkTitleKey] substringWithRange:NSMakeRange(selectedEnd - linkLocation, length)];
                NSString *linkUrl = dic[kLinkUrlKey];
                
                NSDictionary *newLinDic = @{kLinkUrlKey:linkUrl,
                                            kLinkTitleKey:linkTitle,
                                            kLinkRangLocationKey:@(selectedEnd),
                                            KLinkRangLengthKey:@(length)};
                [_linkDicArr addObject:newLinDic];
                
            }else if (selectedLocation > linkLocation && selectedEnd > linkEnd && selectedLocation < linkEnd){ // 删后面一截(选中)
                
                [_linkDicArr removeObject:dic];
                
                NSInteger length = selectedLocation - linkLocation;
                NSString *linkTitle = [dic[kLinkTitleKey] substringWithRange:NSMakeRange(0, length)];
                NSString *linkUrl = dic[kLinkUrlKey];
                
                NSDictionary *newLinDic = @{kLinkUrlKey:linkUrl,
                                            kLinkTitleKey:linkTitle,
                                            kLinkRangLocationKey:dic[kLinkRangLocationKey],
                                            KLinkRangLengthKey:@(length)};
                [_linkDicArr addObject:newLinDic];
                
            }else if (selectedLocation >= linkLocation && selectedEnd <= linkEnd){ // 被包含在内
                
                // 在链接范围内强制弹出链接编辑框 这种情况可以排除
                
                [_linkDicArr removeObject:dic];
                
                NSInteger length1 = selectedLocation - linkLocation ;
                NSInteger length2 = linkEnd - selectedEnd;
                
                NSString *linkTitle1 = [dic[kLinkTitleKey] substringWithRange:NSMakeRange(0, length1)];
                NSString *linkTitle2 = [dic[kLinkTitleKey] substringWithRange:NSMakeRange(selectedEnd - linkLocation, length2)];
                NSString *linkTitle = [NSString stringWithFormat:@"%@%@",linkTitle1,linkTitle2];
                NSString *linkUrl = dic[kLinkUrlKey];
                
                NSDictionary *newLinDic = @{kLinkUrlKey:linkUrl,
                                            kLinkTitleKey:linkTitle,
                                            kLinkRangLocationKey:@(linkLocation),
                                            KLinkRangLengthKey:@(length1+length2)};
                [_linkDicArr addObject:newLinDic];
                
            }
            
        }
        
        
    }
    
}
/*-----------link数据源 end------------------*/

/*-----------image数据源 start ---------------*/
#pragma mark - image数据源
- (void)setImageDicArr:(NSMutableArray *)imageDicArr {
    if (!imageDicArr) {
        imageDicArr = [[NSMutableArray alloc] init];
    }
    _imageDicArr = imageDicArr.mutableCopy;
}

#pragma mark - 判断此处是否在图片range内
- (NSArray *)isThereInImageRange{
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    NSRange selectedRange = _textSelectedRange;
    
    NSInteger index = 0;
    for (NSDictionary *dic in _imageDicArr) {
        
        @autoreleasepool {
            
            index ++;
            
            NSNumber *rangLocation = dic[kImageRangeLocationKey];
            NSNumber *rangLength = dic[kImageRangeLengthKey];
            
            if (selectedRange.length == 0) {
                
                if ((selectedRange.location > rangLocation.integerValue &&
                     selectedRange.location < rangLocation.integerValue + rangLength.integerValue)) {
                    
                    [mutableArr addObject:dic];
                    break;
                    
                }
                
            }else{
                
                // 6种情况
                if ((selectedRange.location >= rangLocation.integerValue &&
                     selectedRange.location + selectedRange.length <= rangLocation.integerValue + rangLength.integerValue)) {
                    
                    [mutableArr addObject:dic];
                    break;
                    
                }else if ((selectedRange.location >= rangLocation.integerValue &&
                           selectedRange.location < rangLocation.integerValue + rangLength.integerValue)
                          ||
                          (selectedRange.location + selectedRange.length > rangLocation.integerValue &&
                           selectedRange.location + selectedRange.length < rangLocation.integerValue + rangLength.integerValue))
                {
                    if (index == _imageDicArr.count) {
                        [mutableArr addObject:@"失败"];
                        [mutableArr addObject:@"失败"];
                        break;
                    }else{
                        continue;
                    }
                    
                }else if (selectedRange.location + selectedRange.length <= rangLocation.integerValue
                          ||
                          selectedRange.location >= rangLocation.integerValue + rangLength.integerValue){
                    
                    continue;
                    
                }
                else{
                    
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    
    // 返回rang范围内存在的超链接数组
    if (mutableArr.count == 0) {
        return nil;
    }else{
        return mutableArr;
    }
    
}

#pragma mark - 调用删除
- (void)imageDeleteSelectedWithRange:(NSRange)range{
    
    if (range.length == 0) {
        return;
    }
    
    // 修改与删除image
    [self modifyImageDicIncludedeInRangee:range];
    
    // 改变数据源image range
    [self updateImageRange:range withDelete:YES];
}

#pragma mark - 修改 selectedRange内 所有image
- (void)modifyImageDicIncludedeInRangee:(NSRange)range{
    
    NSRange selectedRange = range;
    
    NSInteger selectedLocation = selectedRange.location;
    NSInteger selectedEnd = selectedRange.location + selectedRange.length;
    
    NSMutableArray *copyImageArr = _imageDicArr.mutableCopy;
    for (NSDictionary *dic in copyImageArr) {
        
        @autoreleasepool {
            
            NSNumber *rangLocation = dic[kImageRangeLocationKey];
            NSNumber *rangLength = dic[kImageRangeLengthKey];
            
            NSInteger linkLocation = rangLocation.integerValue;
            NSInteger linkEnd = rangLocation.integerValue + rangLength.integerValue;
            
            if (selectedLocation <= linkLocation && selectedEnd >= linkEnd) { // 完全在选中范围内
                [_imageDicArr removeObject:dic];
                
            }else if (selectedLocation > linkLocation && selectedEnd <= linkEnd){ // 被包含在内
                
                [_imageDicArr removeObject:dic];
                
                NSInteger newLocation = [dic[kImageRangeLocationKey] integerValue];
                NSInteger newLength = [dic[kImageRangeLengthKey] integerValue] - selectedRange.length;
                
                NSDictionary *newImageDic = @{kImageNameKey:dic[kImageNameKey],
                                              kImageRangeLocationKey:@(newLocation),
                                              kImageRangeLengthKey:@(newLength)};
                
                if (newLength != 0) {
                    [_imageDicArr addObject:newImageDic];
                }
                
                
            }
            
        }
        
    }
    
}

#pragma mark - 更新image数据源内range记录值
- (void)updateImageRange:(NSRange)range withDelete:(BOOL)isDelete{
    
    NSInteger location = range.location;
    NSInteger length   = range.length;
    NSLog(@"%ld--%ld",location,length);
    
    
    NSMutableArray *imageDicArr = _imageDicArr.mutableCopy;
    NSMutableArray *needModifyArr = [NSMutableArray array];
    
    // 正在修改的图片 且为插入（删除在delete时已经处理）
    NSDictionary *needModifyDic;
    
    // 提取所有需修改的imageDic
    for (NSDictionary *imageDic in imageDicArr) {
        
        @autoreleasepool {
            
            // 除选中外取所有需修改的imageDic
            NSInteger imageLocation = [imageDic[kImageRangeLocationKey] integerValue];
            if (imageLocation >= location) {
                [_imageDicArr removeObject:imageDic];
                [needModifyArr addObject:imageDic];
            }
            
            NSInteger imageLength = [imageDic[kImageRangeLengthKey] integerValue];
            if (imageLocation < location &&
                imageLocation + imageLength > location &&
                !isDelete) {
                
                [_imageDicArr removeObject:imageDic];
                needModifyDic = imageDic;
            }
            
        }
        
    }
    
    
    if (isDelete) {
        // 减运算
        for (NSDictionary *imageDic in needModifyArr) {
            
            @autoreleasepool {
                
                NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:imageDic];
                NSNumber *newLocation = @([imageDic[kImageRangeLocationKey] integerValue] - length);
                [mutableDic setValue:newLocation forKey:kImageRangeLocationKey];
                [_imageDicArr addObject:mutableDic];
                
            }
            
        }
        
    }else{
        // 加运算
        for (NSDictionary *imageDic in needModifyArr) {
            
            @autoreleasepool {
                
                NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:imageDic];
                NSNumber *newLocation = @([imageDic[kImageRangeLocationKey] integerValue] + length);
                [mutableDic setValue:newLocation forKey:kImageRangeLocationKey];
                [_imageDicArr addObject:mutableDic
                 ];
                
            }
            
        }
        
        if (needModifyDic) {
            
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:needModifyDic];
            NSNumber *newLength = @([needModifyDic[kImageRangeLengthKey] integerValue] + length);
            [mutableDic setValue:newLength forKey:kImageRangeLengthKey];
            [_imageDicArr addObject:mutableDic
             ];
        }
    }
    
    NSLog(@"*----------------*\n%@",_imageDicArr);
    
}


@end
