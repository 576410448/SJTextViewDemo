//
//  TabBarBtn.m
//  SJNumTabButton
//
//  Created by shenj on 16/11/3.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "TabBarBtn.h"

@implementation TabBarBtn

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (instancetype)initWithFrame:(CGRect)fr
{
    self = [super initWithFrame:fr];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

// 24*24
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake((self.frame.size.width - 24)/2, 2, 24, 24);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(2, self.frame.size.height - 20, self.frame.size.width - 4, 18);
}


@end
