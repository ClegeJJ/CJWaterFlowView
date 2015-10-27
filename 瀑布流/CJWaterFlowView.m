//
//  CJWaterFlowView.m
//  瀑布流
//
//  Created by mac527 on 15/10/27.
//  Copyright (c) 2015年 mac527. All rights reserved.
//

#import "CJWaterFlowView.h"
#import "CJWaterFlowViewCell.h"
#define CJDefaultColumns 3
#define CJDefaultCellHeight 44
#define CJDefaultMargin 8

@interface CJWaterFlowView()
@property (nonatomic, strong) NSMutableArray *cellFrames;
@end

@implementation CJWaterFlowView

- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (void)reloadata
{
    // cell的总数
    NSInteger numOfCells = [self.dataSource numberOfCellsAtWaterFlowView:self];
    
    NSInteger numOfColumns = [self numOfColumns];
    
    // 间距
    CGFloat topM = [self marginForType:CJWaterFlowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:CJWaterFlowViewMarginTypeBottom];
    CGFloat leftM = [self marginForType:CJWaterFlowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:CJWaterFlowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:CJWaterFlowViewMarginTypeColumn];
    CGFloat rowM = [self marginForType:CJWaterFlowViewMarginTypeRow];
    
    CGFloat cellWidth = (self.width - leftM - rightM - (numOfColumns - 1) * columnM) / numOfColumns;
    
    // 定义一个C语言数组 装载当前所有列最大的Y值
    CGFloat maxYOfColumns[numOfColumns];
    for (int i = 0; i<numOfColumns; i ++) {
        maxYOfColumns[i] = 0.0;
    }
    
    // 计算cell的frame
    for (int i = 0; i<numOfCells; i++) {
        
        //cell默认处在第一列
        NSInteger cellColumn = 0;
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        for (int j = 1; j < numOfColumns; j ++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        CGFloat cellH = [self heightAtIndex:i];
     
        CGFloat cellX = leftM + cellColumn * (cellWidth + columnM);
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0)  { // 首行
            cellY = topM;
        }else{
            cellY = maxYOfCellColumn + rowM;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellWidth,cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        
        // 更新最短那一列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
        
        CJWaterFlowViewCell *cell = [self.dataSource waterFlowView:self cellAtIndex:i];
        cell.frame = cellFrame;
        [self addSubview:cell];
    }
    
    // 设置contenSize
    CGFloat contentH = maxYOfColumns[0];
    for (int j = 1 ; j<numOfColumns; j++) {
        if (maxYOfColumns[j] > contentH) {
            contentH = maxYOfColumns[j];
        }
    }

    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);
}




- (CGFloat)heightAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:cellAtIndex:)]) {
        return [self.delegate waterFlowView:self heightForCellAtIndex:index];
    } else {
        return CJDefaultCellHeight;
    }
}


- (NSInteger)marginForType:(CJWaterFlowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:marginForType:)]) {
        return [self.delegate waterFlowView:self marginForType:type];
    } else{
        return CJDefaultMargin;
    }
}

/**
 *  多少列
 */
- (NSInteger)numOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterFlowView:)]) {
        return  [self.dataSource numberOfColumnsInWaterFlowView:self];
    } else{
        return CJDefaultColumns;
    }
}
@end
