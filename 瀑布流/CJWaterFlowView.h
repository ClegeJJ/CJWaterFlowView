//
//  CJWaterFlowView.h
//  瀑布流
//
//  Created by mac527 on 15/10/27.
//  Copyright (c) 2015年 mac527. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CJWaterFlowView,CJWaterFlowViewCell;

typedef enum {
    CJWaterFlowViewMarginTypeTop,
    CJWaterFlowViewMarginTypeLeft,
    CJWaterFlowViewMarginTypeBottom,
    CJWaterFlowViewMarginTypeRight,
    CJWaterFlowViewMarginTypeColumn, // 每一行
    CJWaterFlowViewMarginTypeRow, // 每一列

}CJWaterFlowViewMarginType; // 间距

@protocol CJWaterFlowViewDataSource <NSObject> // 数据源
@required
//  一共多少个cell需要展示
- (NSInteger)numberOfCellsAtWaterFlowView:(CJWaterFlowView *)waterFlowView;


// cell所在的索引
- (CJWaterFlowViewCell *)waterFlowView:(CJWaterFlowView *)waterFlowView cellAtIndex:(NSInteger *)index;

@optional
// 一共有多少列
- (NSInteger)numberOfColumnsInWaterFlowView:(CJWaterFlowView *)waterFlowView;
@end

@protocol CJWaterFlowViewDelegate <UIScrollViewDelegate> // 代理

@optional
// 第index对应的cell有多高
- (CGFloat)waterFlowView:(CJWaterFlowView *)waterFlowView heightForCellAtIndex:(NSInteger)index;

// 返回间距
- (CGFloat)waterFlowView:(CJWaterFlowView *)waterFlowView marginForType:(CJWaterFlowViewMarginType)marginType;

// 选中了某个cell
- (void)waterFlowView:(CJWaterFlowView *)waterFlowView didSelectedCellAtIndex:(NSInteger)index;
@end

@interface CJWaterFlowView : UIScrollView
/**
 *  代理
 */
@property (nonatomic, weak) id <CJWaterFlowViewDelegate> delegate;

/**
 *  数据源
 */
@property (nonatomic, weak) id <CJWaterFlowViewDataSource> dataSource;


/**
 *  刷新数据
 */
- (void)reloadata;
@end
