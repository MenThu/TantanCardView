//
//  MPCardView.h
//  TantanCardView
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardItemModel.h"
#import "MPCardItemView.h"

@interface MPCardView <T:MPCardItemView*> : UIView

/**
 *  卡片的数据源
 */
@property (nonatomic, strong) NSMutableArray <CardItemModel *> *cardSource;
/**
 *  外部可以指定卡片视图的具体类，但必须是MPCardItemView的子类
 */
@property (nonatomic, copy) T (^viewOfCardItem) (void);

/**
 *  喜欢或者不喜欢某一个用户
 */
@property (nonatomic, copy) void (^likeOrDislike) (BOOL isLike, NSInteger userId);

@end
