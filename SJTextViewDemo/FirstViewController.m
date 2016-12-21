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
    
    NSString *str = @"关于：\n欢迎关注本人微博：http://weibo.com/u/5092390792 纯属放松娱乐的，跟开发毫无关系T-T，不过可以在工作之余聊聊天啊~\n\ndemo中用到的tabBar角标链接：https://github.com/576410448/SJNumTabDmeo\n\n欢迎关注我的Github，有帮到你的话给颗✨哦~";
    _firstTextView.text = str;
    
}

@end
