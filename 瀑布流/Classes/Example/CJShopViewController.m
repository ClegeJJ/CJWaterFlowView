//
//  CJShopViewController.m
//  瀑布流
//
//  Created by mac527 on 15/10/27.
//  Copyright (c) 2015年 mac527. All rights reserved.
//

#import "CJShopViewController.h"
#import "CJWaterFlowView.h"
#import "CJWaterFlowViewCell.h"
#import "MJRefresh.h"
#import "CJShop.h"
#import "CJShopCell.h"
#import "MJExtension.h"

@interface CJShopViewController () <CJWaterFlowViewDelegate,CJWaterFlowViewDataSource>
@property (nonatomic, strong) NSMutableArray *shops;
@property (nonatomic, weak) CJWaterFlowView *waterFlowView;
@end

@implementation CJShopViewController
- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 0.初始化数据
    NSArray *newShops = [CJShop objectArrayWithFilename:@"2.plist"];
    [self.shops addObjectsFromArray:newShops];
    
    // 1.瀑布流控件
    CJWaterFlowView *waterflowView = [[CJWaterFlowView alloc] init];
    // 跟随着父控件的尺寸而自动伸缩
    waterflowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    waterflowView.frame = self.view.bounds;
    waterflowView.dataSource = self;
    waterflowView.delegate = self;
//    waterflowView.backgroundColor = [UIColor redColor];
    waterflowView.header = [MJRefreshHeader headerWithRefreshingBlock:^{
        NSLog(@"header");
    }];
    [self.view addSubview:waterflowView];
    self.waterFlowView = waterflowView;
    
    
    self.waterFlowView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    self.waterFlowView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    
//    [self.waterFlowView.header beginRefreshing];
    
}
- (void)loadNewShops
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 加载1.plist
        NSArray *newShops = [CJShop objectArrayWithFilename:@"1.plist"];
        [self.shops insertObjects:newShops atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)]];
        
        // 刷新瀑布流控件
        [self.waterFlowView reloadata];
        
        // 停止刷新
        [self.waterFlowView.header endRefreshing];
    });
}

- (void)loadMoreShops
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 加载3.plist
        NSArray *newShops = [CJShop objectArrayWithFilename:@"3.plist"];
        [self.shops addObjectsFromArray:newShops];
        
        // 刷新瀑布流控件
        [self.waterFlowView reloadata];
        
        // 停止刷新
        [self.waterFlowView.footer endRefreshing];
    });
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.waterFlowView reloadata];

}
#pragma mark - 数据源方法
- (NSInteger)numberOfCellsAtWaterFlowView:(CJWaterFlowView *)waterFlowView
{
    return self.shops.count;
    
}

- (NSInteger)numberOfColumnsInWaterFlowView:(CJWaterFlowView *)waterFlowView
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // 竖屏
        return 3;
    } else {
        return 5;
    }
}

- (CJWaterFlowViewCell *)waterFlowView:(CJWaterFlowView *)waterFlowView cellAtIndex:(NSInteger)index
{
    CJShopCell *cell = [CJShopCell cellWithWaterflowView:waterFlowView];
    
    cell.shop = self.shops[index];
    
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)waterFlowView:(CJWaterFlowView *)waterFlowView heightForCellAtIndex:(NSInteger)index
{
    CJShop *shop = self.shops[index];
    // 根据cell的宽度 和 图片的宽高比 算出 cell的高度
    return waterFlowView.cellWidth * shop.h / shop.w;

}

@end
