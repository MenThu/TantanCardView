//
//  MPCardItemView.h
//  TantanCardView
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPCardItemView : UIView

@property (nonatomic, copy) void (^dragBegin) (CGPoint beginPoint);
@property (nonatomic, copy) void (^dragMove) (CGPoint movePoint);
@property (nonatomic, copy) void (^dragEnd) (CGPoint endPoint);

- (void)changeShaowOpacity:(CGFloat)opacity;
@end
