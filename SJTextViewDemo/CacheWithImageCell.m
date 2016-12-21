//
//  CacheWithImageCell.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/15.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "CacheWithImageCell.h"

@interface CacheWithImageCell ()

@property (nonatomic ,strong) UILabel *titleLabel;

@property (nonatomic ,strong) UIImageView *rightImageView;

@end

@implementation CacheWithImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    /**
     * LaunchScreen适配问题
     */
    CGRect frame = self.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    [self setFrame:frame];
    
    if (self) {
        [self uiConfig];
    }
    return self;
    
}

- (void)uiConfig {
    
    [self layoutSubviews];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 30, self.contentView.bounds.size.width - 100 - 17, 40)];
    [self.contentView addSubview:_titleLabel];
    
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:17];
    
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 90, 10, 80, 80)];
    [self.contentView addSubview:_rightImageView];
    _rightImageView.layer.cornerRadius = 5;
    _rightImageView.clipsToBounds = YES;
}

- (void)setCacheModel:(CacheListModel *)cacheModel {
    
    _titleLabel.text = cacheModel.title;
    NSDictionary *dic = cacheModel.images.firstObject;
    _rightImageView.image = dic[kImageNameKey];
    
}

@end
