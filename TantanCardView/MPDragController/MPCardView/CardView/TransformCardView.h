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

@property (nonatomic, strong) NSMutableArray *cardSource;
@property (nonatomic, copy) CardItemView * (^getItemView) (void);

@end
