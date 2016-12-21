//
//  PreViewController.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/10.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "PreViewController.h"
#import "SJTextHeader.h"

#import "PhotoShowVC.h"
#import "WKWebviewVC.h"

@interface PreViewController ()<UITextViewDelegate>

@property (nonatomic ,strong) UITextView *showTextView;

@end

@implementation PreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self uiConfig];
}

- (void)uiConfig {
    
    _showTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, MAIN_WIDTH - 20, MAIN_HEIGHT - 64)];
    [self.view addSubview:_showTextView];
    _showTextView.editable = NO;
    _showTextView.delegate = self;
    _showTextView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor blueColor]};
    
    NSMutableAttributedString *showAttributeText = [[NSMutableAttributedString alloc] initWithAttributedString:_attriButeText];
    
    // 添加链接 touch event
    for (NSDictionary *linkDic in _links) {
        
        NSRange linkRange = NSMakeRange([linkDic[kLinkRangLocationKey] integerValue], [linkDic[KLinkRangLengthKey] integerValue]);
        
        NSString *linkTitlt = linkDic[kLinkTitleKey];
        
        [showAttributeText addAttribute:NSLinkAttributeName value:linkTitlt range:linkRange];

    }
    
    _showTextView.attributedText = showAttributeText;
    
}

#pragma mark - link touch event
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    for (NSDictionary *linkDic in _links) {
        
        NSRange linkRange = NSMakeRange([linkDic[kLinkRangLocationKey] integerValue], [linkDic[KLinkRangLengthKey] integerValue]);
        
        if (characterRange.location == linkRange.location &&
            characterRange.length == linkRange.length) {
            
            WKWebviewVC *webVC = [[WKWebviewVC alloc] init];
            webVC.urlStr = linkDic[kLinkUrlKey];
            webVC.navigationItem.title = linkDic[kLinkTitleKey];
            [self.navigationController pushViewController:webVC animated:YES];
            
            return NO;
        }
        
    }
    
    return YES;
}

#pragma mark -  image touch event
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    
    for (NSInteger i = 0; i < _images.count; i ++) {
        
        NSDictionary *imageDic = _images[i];
        
        NSRange imageRange = NSMakeRange([imageDic[kImageRangeLocationKey] integerValue], [imageDic[kImageRangeLengthKey] integerValue]);
                
        if (characterRange.location >= imageRange.location &&
            characterRange.location + characterRange.length <= imageRange.location + imageRange.length) {
            NSLog(@"第%ld张图",i);
            
            PhotoShowVC *photoVC = [[PhotoShowVC alloc] init];
            photoVC.page = i;
            photoVC.images = _images;
            [self.navigationController pushViewController:photoVC animated:YES];
            
            return NO;
        }
        
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%f",event.accessibilityActivationPoint.y);
}

@end
