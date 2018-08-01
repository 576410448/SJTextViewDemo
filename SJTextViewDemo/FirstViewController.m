//
//  FirstViewController.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/10.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"item1";
    
    [self loadSomeUseless];
    
}

- (void) loadSomeUseless {
    
    NSString *str = @"关于：此demo仅用于初学者学习了解，实际项目富文本编辑开发最好采用html以进行各端同步\n\ndemo中用到的tabBar角标链接：https://github.com/576410448/SJNumTabDmeo\n\n欢迎关注我的Github，有帮到你的话请给颗✨哦~";
    _firstTextView.text = str;
    
}

@end
