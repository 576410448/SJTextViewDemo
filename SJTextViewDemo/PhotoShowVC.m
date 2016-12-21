//
//  PhotoShowVC.m
//  SJNavigationBar
//
//  Created by shenj on 16/12/20.
//  Copyright © 2016年 wangjucheng. All rights reserved.
//

#import "PhotoShowVC.h"
#import "PhotoShowLayout.h"
#import "PhotoShowCell.h"
#import "SJTextHeader.h"

static NSString *const kPhotoShowCellID = @"kPhotoShowCellID";

@interface PhotoShowVC ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic ,strong) UICollectionView *collectionView;

@property (nonatomic ,assign) NSInteger currentPage;

@end

@implementation PhotoShowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentPage = _page + 1;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", _currentPage,_images.count];
    
    [self uiConfig];
    
}

- (void)uiConfig {
    
    CGRect frame = CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT - 64);
    
    PhotoShowLayout *layout = [[PhotoShowLayout alloc] init];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView setContentOffset:CGPointMake(MAIN_WIDTH*_page, 0)];
    
    [_collectionView registerClass:[PhotoShowCell class] forCellWithReuseIdentifier:kPhotoShowCellID];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoShowCellID forIndexPath:indexPath];
    
    NSDictionary *imageDic = _images[indexPath.row];
    cell.showImage = imageDic[kImageNameKey];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger index = _collectionView.contentOffset.x / MAIN_WIDTH + 1;
    _currentPage = index - 1;
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", (long)index,_images.count];
}

@end
