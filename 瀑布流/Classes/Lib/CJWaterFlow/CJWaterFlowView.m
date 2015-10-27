//
//  CJWaterFlowView.m
//  瀑布流
//
//  Created by mac527 on 15/10/27.
//  Copyright (c) 2015年 mac527. All rights reserved.
//

#import "CJWaterFlowView.h"
#import "CJWaterFlowViewCell.h"
#define CJDefaultColumns 3 // 默认列数
#define CJDefaultCellHeight 44 // 默认行高
#define CJDefaultMargin 8 // 默认间距

@interface CJWaterFlowView()
/**
 *  存放所有cell的Frame
 */
@property (nonatomic, strong) NSMutableArray *cellFrames;
/**
 *  存放当前显示的cell
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
/**
 *  缓存池
 */
@property (nonatomic, strong) NSMutableSet *reusebleSet;
@end

@implementation CJWaterFlowView

/**
 *  懒加载数组
 */
- (NSMutableArray *)cellFrames{
    if (_cellFrames == nil) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}
- (NSMutableDictionary *)displayingCells{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}
- (NSMutableSet *)reusebleSet{
    if (_reusebleSet == nil) {
        self.reusebleSet = [NSMutableSet set];
    }
    return _reusebleSet;
}


#pragma mark - 公开接口
/**
 *  重新刷新数据
 */
- (void)reloadata
{
    // 清空之前的所有数据
    // 移除正在正在显示cell
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusebleSet removeAllObjects];
    
    // cell的总数
    NSInteger numOfCells = [self.dataSource numberOfCellsAtWaterFlowView:self];
    
    NSInteger numOfColumns = [self numOfColumns];
    
    // 间距
    CGFloat topM = [self marginForType:CJWaterFlowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:CJWaterFlowViewMarginTypeBottom];
    CGFloat leftM = [self marginForType:CJWaterFlowViewMarginTypeLeft];
    CGFloat columnM = [self marginForType:CJWaterFlowViewMarginTypeColumn];
    CGFloat rowM = [self marginForType:CJWaterFlowViewMarginTypeRow];
    
    CGFloat cellW = [self cellWidth];
    
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
        // cell的高度
        CGFloat cellH = [self heightAtIndex:i];
        CGFloat cellX = leftM + cellColumn * (cellW + columnM);
        CGFloat cellY = 0;
        
        if (maxYOfCellColumn == 0.0)  { // 首行
            cellY = topM;
        }else{
            cellY = maxYOfCellColumn + rowM;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW,cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        
        // 更新最短那一列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
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

/**
 *  从缓存池中取
 *
 *  @param identifier 唯一标识
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block CJWaterFlowViewCell *reuseCell = nil;
    [self.reusebleSet enumerateObjectsUsingBlock:^(CJWaterFlowViewCell *cell, BOOL *stop) {
        cell = [self.reusebleSet anyObject];
        
        if ([cell.identifier isEqualToString:identifier]) {
            reuseCell = cell;
            *stop = YES;
        }
    }];
    
    if (reuseCell) {
        [self.reusebleSet removeObject:reuseCell];
    }
    
    return reuseCell;
    
}

/**
 *  找到被点击的cell
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectedCell = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, CJWaterFlowViewCell *cell, BOOL *stop) {
        
        if (![self.delegate respondsToSelector:@selector(waterFlowView:didSelectedCellAtIndex:)]) return;
        
        if (CGRectContainsPoint(cell.frame, point)) {
            selectedCell = key;
            *stop = YES;
        }
       
        if (selectedCell) {
            [self.delegate waterFlowView:self didSelectedCellAtIndex:selectedCell.unsignedIntegerValue];
        }
        
    }];
}

- (CGFloat)cellWidth
{
    // 总列数
    NSInteger numberOfColumns = [self numOfColumns];
    CGFloat leftM = [self marginForType:CJWaterFlowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:CJWaterFlowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:CJWaterFlowViewMarginTypeColumn];
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadata];
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    for (int i = 0; i < self.cellFrames.count; i ++) {
        // 根据索引取出cell的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        CJWaterFlowViewCell *cell = self.displayingCells[@(i)];
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterFlowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                self.displayingCells[@(i)] = cell;
            }
        } else{ // 不在屏幕上
            if (cell) {
                // 移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];

                [self.reusebleSet addObject:cell];
                
            }
        }
    }
}


#pragma mark - 私有方法
/**
 *  判断一个frame有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return CGRectGetMinY(frame) < self.contentOffset.y + self.bounds.size.height && CGRectGetMaxY(frame) > self.contentOffset.y;
}



/**
 *  cell的高度
 */
- (CGFloat)heightAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:cellAtIndex:)]) {
        return [self.delegate waterFlowView:self heightForCellAtIndex:index];
    } else {
        return CJDefaultCellHeight;
    }
}

/**
 *  间距
 */
- (NSInteger)marginForType:(CJWaterFlowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:marginForType:)]) {
        return [self.delegate waterFlowView:self marginForType:type];
    } else{
        return CJDefaultMargin;
    }
}

/**
 *  总共有多少列
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
