//
//  MPCardView.h
//  TantanCardView
//
//  Created by MenThu on 2017/12/26.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPCardModel.h"

@interface MPCardView : UIView

/** 数据源 */
@property (nonatomic, weak) MPCardModel *model;
/** 隐藏或者显示阴影 */
- (void)showShadowOpacity:(CGFloat)opacity;

@end
