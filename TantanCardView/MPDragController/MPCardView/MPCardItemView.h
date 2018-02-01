//
//  MPCardItemView.h
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "CardItemView.h"
#import "MPCardItemModel.h"

@interface MPCardItemView : CardItemView

@property (nonatomic, weak) MPCardItemModel *model;

/**
 *  显示或者隐藏阴影
 */
- (void)showShadowOpacity:(CGFloat)opacity;

@end
