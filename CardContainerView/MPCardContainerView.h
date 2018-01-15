//
//  MPCardContainerView.h
//  TantanCardView
//
//  Created by MenThu on 2017/12/26.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPCardModel.h"

@interface MPCardContainerView : UIView

/** 数据源 */
@property (nonatomic, strong) NSMutableArray <MPCardModel *> *cardSource;
/** 喜欢或者不喜欢 */
@property (nonatomic, copy) void (^likeOrDislike) (BOOL isLike, NSInteger userId);
/** 卡片已用完,请求下一页数据 */
@property (nonatomic, copy) void (^nextPage) (NSInteger pageNo);
/** 喜欢或者不喜欢最上面的一张卡片 */
- (void)likeOrDislikeTopCard:(BOOL)isLike;

@end
