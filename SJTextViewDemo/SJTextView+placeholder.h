//
//  SJTextView+placeholder.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/5.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  UITextView类扩展


#import "SJTextView.h"

static NSString * const kObservePlaceholderShowNote = @"kObservePlaceholderShowNote";
static NSString * const kObserveEndPlaceholderNote = @"kObserveEndPlaceholderNote4";

@interface UITextView (placeholder)

@property (nonatomic ,copy) NSString *placeholder;

@property (nonatomic ,copy) NSString *endPlaceholder;

@end
