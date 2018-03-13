//
//  CardItemView.h
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardItemView : UIView

/**
 *  拖拽开始
 */
@property (nonatomic, copy) void (^dragBegin) (CGPoint point);

/**
 *  拖拽移动
 */
@property (nonatomic, copy) void (^dragMove) (CGPoint point);

/**
 *  拖拽结束
 */
@property (nonatomic, copy) void (^dragEnd) (CGPoint point);

/**
 *  数据源
 */
@property (nonatomic, weak) id cardModel;

@end
