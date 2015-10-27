//
//  CJViewController.m
//  瀑布流
//
//  Created by mac527 on 15/10/27.
//  Copyright (c) 2015年 mac527. All rights reserved.
//

#import "CJViewController.h"
#import "CJWaterFlowView.h"
#import "CJWaterFlowViewCell.h"
@interface CJViewController ()<CJWaterFlowViewDelegate,CJWaterFlowViewDataSource>

@end

@implementation CJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CJWaterFlowView *waterFlow = [[CJWaterFlowView alloc] init];
    waterFlow.dataSource = self;
    waterFlow.delegate = self;
    waterFlow.frame = self.view.bounds;
    [self.view addSubview:waterFlow];
    
    [waterFlow reloadata];
    
}

- (NSInteger)numberOfCellsAtWaterFlowView:(CJWaterFlowView *)waterFlowView
{
    return 100;
}

- (CJWaterFlowViewCell *)waterFlowView:(CJWaterFlowView *)waterFlowView cellAtIndex:(NSInteger *)index
{
    CJWaterFlowViewCell *cell = [[CJWaterFlowViewCell alloc] init];
    cell.backgroundColor = CJRandomColor;
    return cell;
}

- (CGFloat)waterFlowView:(CJWaterFlowView *)waterFlowView heightForCellAtIndex:(NSInteger)index
{
    return arc4random_uniform(100) + 70;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
