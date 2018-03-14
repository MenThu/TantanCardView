//
//  TransformCardView.h
//  TantanCardView
//
//  Created by MenThu on 2018/3/13.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardItemView.h"

@interface TransformCardView : UIView

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *cardSource;
/** 获取卡片block */
@property (nonatomic, copy) CardItemView * (^getItemView) (void);
/** 请求更多数据 */
@property (nonatomic, copy) void (^needMoreData) (void);
/** 没有更多数据了 */
@property (nonatomic, copy) void (^allCardDataIsDone) (void);
/** 提示卡片容器没有更多数据了 */
@property (nonatomic, assign) BOOL isNoMoreData;
/** 添加更多数据 */
- (void)appendCardArray:(NSArray *)array;

@end
