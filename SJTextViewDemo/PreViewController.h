//
//  PreViewController.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/10.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  预览界面

#import <UIKit/UIKit.h>

@interface PreViewController : UIViewController

@property (nonatomic ,copy) NSAttributedString *attriButeText;

@property (nonatomic ,copy) NSArray *images;

@property (nonatomic ,copy) NSArray *links;

@property (nonatomic ,copy) NSString *showTitle;

@end
