//
//  CardMacro.h
//  TantanCardView
//
//  Created by MenThu on 2018/3/13.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#ifndef CardMacro_h
#define CardMacro_h

static NSInteger    const   _cardStartIndex = 0;
static NSInteger    const   _defaultDisplayCount = 4;
static CGFloat      const   _bottomOffset = 8;
static CGFloat      const   _cardScale = 0.8f;
static CGFloat      const   _animateDurationPerPoint = 0.05/100;
static CGFloat      const   _topCardBottom2BtnTop = 40.f;
static CGFloat      const   _btnBottom2ViewBottom = 20.f;

#define MTColor(r,g,b,a)     [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define MTRandomColor      MTColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.f)

#endif /* CardMacro_h */
