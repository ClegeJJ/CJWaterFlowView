//
//  CJShopCell.h
//  瀑布流
//
//  Created by mac527 on 15/10/27.
//  Copyright (c) 2015年 mac527. All rights reserved.
//

#import "CJWaterFlowViewCell.h"
@class CJShop,CJWaterFlowView;

@interface CJShopCell : CJWaterFlowViewCell
+ (instancetype)cellWithWaterflowView:(CJWaterFlowView *)waterflowView;


@property (nonatomic, strong) CJShop *shop;

@end
