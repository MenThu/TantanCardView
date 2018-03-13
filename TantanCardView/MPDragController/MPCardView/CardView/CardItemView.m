//
//  CardItemView.m
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "CardItemView.h"

@implementation CardItemView

- (instancetype)init{
    if (self = [super init]) {
        [self addPanGesture];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self addPanGesture];
}

- (void)addPanGesture{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)dragGesture:(UIPanGestureRecognizer *)gestrue{
    if (!self.dragBegin || !self.dragMove || !self.dragEnd || !self.superview) {
        return;
    }
    CGPoint point = [gestrue locationInView:self.superview];
    switch (gestrue.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.dragBegin(point);
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.dragMove(point);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.dragEnd(point);
        }
            break;
            
        default:
            break;
    }
}

@end
