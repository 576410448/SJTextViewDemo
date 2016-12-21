//
//  SubViewController.m
//  SJNumTabButton
//
//  Created by shenj on 16/11/2.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SubViewController.h"
#import "ViewController.h"
#import "CacheListModel.h"
#import "CacheDefaultCell.h"
#import "CacheWithImageCell.h"
#import "SJCacheManager.h"

static NSString *const kCacheWithImageCellID = @"kCacheWithImageCellID";
static NSString *const kCacheDefaultCellID = @"kCacheDefaultCellID";

@interface SubViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *cacheListTableView;

/**tableView 数据源*/
@property (nonatomic ,strong) NSMutableArray *cacheListArray;

/**coreData数据源*/
@property (nonatomic ,strong) NSArray *cacheDataArray;

@end

@implementation SubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"item2";
    
    [self uiConfig];
    
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

- (void)prepareCacheData {
    
    _cacheListArray = [[NSMutableArray alloc] init];
    
    _cacheDataArray = [[SJCacheManager coreDataManager] showAllObjInCoreData];
    
    [_cacheListArray addObjectsFromArray:[CacheListModel changeCoreDataArrayToArray:_cacheDataArray]];
    
    [_cacheListTableView reloadData];
    
    
}

- (void)uiConfig {
    
    [self prepareCacheData];
    
    CGRect frame = self.view.bounds;
    frame.size.height -= 64 + 49;
    
    _cacheListTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    _cacheListTableView.delegate = self;
    _cacheListTableView.dataSource = self;
    [self.view addSubview:_cacheListTableView];
    
    [_cacheListTableView registerClass:[CacheDefaultCell class] forCellReuseIdentifier:kCacheDefaultCellID];
    [_cacheListTableView registerClass:[CacheWithImageCell class] forCellReuseIdentifier:kCacheWithImageCellID];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cacheListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CacheListModel *model = _cacheListArray[indexPath.row];
    
    if (model.images.count == 0) {
        
        CacheDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:kCacheDefaultCellID];
        cell.textLabel.text = model.title;
        cell.textLabel.textColor = [UIColor redColor];
        return cell;
        
    }else{
        
        CacheWithImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCacheWithImageCellID];
        cell.cacheModel = model;
        return cell;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJCacheModel *model = _cacheDataArray[indexPath.row];
    
    ViewController *vc = [[ViewController alloc] init];
    vc.coredataModel = model;
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
    
}

@end
