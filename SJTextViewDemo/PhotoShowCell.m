//
//  PhotoShowCell.m
//  SJNavigationBar
//
//  Created by shenj on 16/12/20.
//  Copyright © 2016年 wangjucheng. All rights reserved.
//

#import "PhotoShowCell.h"

@implementation PhotoShowCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    if (self) {
        
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig {
    
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)setShowImage:(UIImage *)showImage {
    _imageView.image = showImage;
}

@end
