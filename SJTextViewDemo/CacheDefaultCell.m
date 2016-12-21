//
//  CacheDefaultCell.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/15.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "CacheDefaultCell.h"

@interface CacheDefaultCell ()

@property (nonatomic ,strong) UILabel *titleLabel;

@end

@implementation CacheDefaultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self uiConfig];
    }
    return self;
    
}

- (void)uiConfig {
    
}

@end
