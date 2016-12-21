//
//  TabBarController.m
//  SJNumTabButton
//
//  Created by shenj on 16/11/2.
//  Copyright © 2016年 shenj. All rights reserved.
//

# define kTabBtnTag 100

#import "TabBarController.h"
#import "ViewController.h"
#import "SubViewController.h"
#import "FirstViewController.h"
#import "TabBarBtn.h"
#import "UIButton+SJTab.h"
#import "SJTextHeader.h"

@interface TabBarController ()

@property (nonatomic ,strong) UIButton *tabBarHome;

@property (nonatomic ,strong) UIButton *tabBarOther;

@property (nonatomic ,strong) UIView *tabBarView;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 快速创建标签栏 方法一 */
    //    [self tabBarConfig];
    
    
    
    /** 自定义多样化标签栏 方法二 */
    
    // 创建视图
    [self createViewController];
    
    // 创建标签栏
    [self createTableBar];
    
    // 创建标签
    [self createTabs];
    
    // 创建角标
    [self prepareCacheData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserverForName:kCacheDataHasChangeNote object:nil queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification * _Nonnull note) {
        [self prepareCacheData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCacheDataHasChangeNote object:nil];
}

#pragma mark 方法一
- (void)tabBarConfig{
    
    NSArray *titleArr = @[@"item1",@"item2"];
    
    NSArray *imgs = @[@"tabbar_home_normal",@"tabbar_romeo_normal"];
    
    FirstViewController *item1 = [[FirstViewController alloc] init];
    UINavigationController *naviItem1 = [[UINavigationController alloc] initWithRootViewController:item1];
    naviItem1.title = titleArr[0];
    naviItem1.tabBarItem.image = [UIImage imageNamed:imgs[0]];
    
    SubViewController *item2 = [[SubViewController alloc] init];
    UINavigationController *naviItem2 = [[UINavigationController alloc] initWithRootViewController:item2];
    naviItem2.title = titleArr[1];
    naviItem2.tabBarItem.image = [UIImage imageNamed:imgs[1]];
    
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor blueColor]];
    
    self.viewControllers = @[naviItem1,naviItem2];
    
}

#pragma mark 方法二
-(void)createViewController{
    
    
    
    NSArray *viewConts = @[@"FirstViewController",
                           @"",
                           @"SubViewController"];
    
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < viewConts.count; i ++) {
        
        if (i == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            UIViewController *sv = [storyboard instantiateViewControllerWithIdentifier:viewConts[i]];
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:sv];
            [vcs addObject:navi];
            continue;
        }
        
        
        UIViewController *vc = [[NSClassFromString(viewConts[i]) alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        [vcs addObject:navi];
    }
    self.viewControllers = vcs;
    
}


-(void)createTableBar{
    
    _tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 49)];
    
    _tabBarView.backgroundColor = [UIColor whiteColor];
    _tabBarView.userInteractionEnabled = YES;
    [self.tabBar addSubview:_tabBarView];
    
}


-(void)createTabs{
    
    NSArray *titleArr = @[@"item1",@"➕",@"item2"];
    
    NSArray *imgs = @[@"tabbar_home_normal",@"",@"tabbar_romeo_normal"];
    
    for (int i = 0; i < imgs.count; i ++) {
        
        if (i == 1) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_tabBarView addSubview:btn];
            
            CGFloat weight = MAIN_WIDTH/3;
            btn.frame = CGRectMake(i * weight, 0, weight, 49);
            
            [btn setTitle:titleArr[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(beginToEdit) forControlEvents:UIControlEventTouchUpInside];
            
            continue;
        }
        
        
        TabBarBtn *btn = [TabBarBtn buttonWithType:UIButtonTypeCustom];
        
        __weak typeof(btn) weakBtn = btn;
        [weakBtn setSj_tabRemoveEventBlock:^{
            weakBtn.sj_tabNum = 0;
        }];
        
        CGFloat weight = MAIN_WIDTH/3;
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        
        btn.frame = CGRectMake(i * weight, 0, weight, 49);
        btn.tag = i + kTabBtnTag;
        
        
        if (i == 0) {
            btn.selected = YES;
        }
        
        [_tabBarView addSubview:btn];
        
        [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)beginToEdit {
    
    UINavigationController *textVC = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    
    [self presentViewController:textVC animated:YES completion:nil];
    
}

-(void)tapAction:(UIButton *)btn{
    
    NSInteger index = btn.tag - kTabBtnTag;
    self.selectedIndex = index;
    
    for (UIButton *btn in _tabBarView.subviews) {
        btn.selected = NO;
    }
    
    //设置selected属性
    btn.selected = YES;
}

// 角标
- (void)prepareCacheData{
    
    TabBarBtn *btn0 = (TabBarBtn *)[self.view viewWithTag:kTabBtnTag];
    TabBarBtn *btn1 = (TabBarBtn *)[self.view viewWithTag:kTabBtnTag + 2];
    
    NSArray *arr = [[SJCacheManager coreDataManager] showAllObjInCoreData];
    
    // 添加角标
    btn0.sj_tabNum = 520;
    btn0.sj_rightOfSet = 30;
    btn0.sj_topOfSet = 0;
    btn0.sj_tabUserInteractionEnabled = YES;
    
    // 添加角标
    btn1.sj_tabNum = arr.count;
    btn1.sj_rightOfSet = 30;
    btn1.sj_topOfSet = 0;
    btn1.sj_backColor = [UIColor lightGrayColor];
    btn1.sj_numColor = [UIColor blackColor];
    btn1.sj_tabUserInteractionEnabled = NO;
}

@end
