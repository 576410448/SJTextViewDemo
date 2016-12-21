//
//  WKWebviewVC.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/21.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "WKWebviewVC.h"
#import <WebKit/WebKit.h>

@interface WKWebviewVC ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic ,strong) WKWebView *webView;

@property (nonatomic ,strong) UIProgressView *progressView;

@end

@implementation WKWebviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self webUIConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [_webView addObserver:self
               forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionOld
                  context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)webUIConfig {
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT - 64)];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    [_webView loadRequest:requset];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0, 0, MAIN_WIDTH, 2);
    [_webView addSubview:_progressView];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    [_progressView setProgress:_webView.estimatedProgress animated:YES];
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"start");
    [_progressView setProgress:0.2 animated:YES];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"load web data");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"load successful");
    [_progressView setProgress:_webView.estimatedProgress animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC*700), dispatch_get_main_queue(), ^{
        [_progressView removeFromSuperview];
    });
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"fail 1");
    [_progressView removeFromSuperview];
}

- (void)dealloc {
    
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
    [_webView removeFromSuperview];
    _webView = nil;
    
}

@end
