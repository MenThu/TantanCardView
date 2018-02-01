//
//  CardView.h
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPCardItemView.h"

@interface CardView : UIView

@property (nonatomic, strong) NSMutableArray <MPCardItemModel *> *cardSource;
@property (nonatomic, copy) MPCardItemView * (^getItemView) (void);
@property (nonatomic, copy) void (^nextPage)(void);
@property (nonatomic, copy) void (^likeOrDislike) (BOOL isLike, NSInteger userId);

@end
