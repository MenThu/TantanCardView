//
//  MPDragLikeView.m
//  TantanCardView
//
//  Created by MenThu on 2018/1/6.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "MPDragLikeView.h"

//按钮参数相关
static CGFloat _btnWidth = 80;
static CGFloat _btnXRight2ViewCenterX = 50;

@interface MPDragLikeView ()

@property (nonatomic, weak, readwrite) MPCardContainerView *cardContainerView;
@property (nonatomic, weak) UIButton *likeBtn;
@property (nonatomic, weak) UIButton *disLikeBtn;

@end

@implementation MPDragLikeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addBtn];
        MPCardContainerView *cardContainerView = [[MPCardContainerView alloc] init];
        cardContainerView.frame = self.bounds;
        [self addSubview:(_cardContainerView = cardContainerView)];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat bottom2ViewBottom = 50.f;
    CGFloat y = self.bounds.size.height - bottom2ViewBottom - _btnWidth;
    CGFloat leftX = self.bounds.size.width/2 - _btnXRight2ViewCenterX - _btnWidth;
    CGFloat rightX = self.bounds.size.width/2 + _btnXRight2ViewCenterX;
    self.likeBtn.frame = CGRectMake(leftX, y, _btnWidth, _btnWidth);
    self.disLikeBtn.frame = CGRectMake(rightX, y, _btnWidth, _btnWidth);
}

- (void)addBtn{
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    likeBtn.exclusiveTouch = YES;
    likeBtn.backgroundColor = [UIColor redColor];
    likeBtn.layer.cornerRadius = _btnWidth/2;
    likeBtn.tag = 0;
    [likeBtn addTarget:self action:@selector(touchLikeOrDisLikeBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [likeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self addSubview:(_likeBtn = likeBtn)];
    
    UIButton *disLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    disLikeBtn.exclusiveTouch = YES;
    disLikeBtn.backgroundColor = [UIColor orangeColor];
    disLikeBtn.layer.cornerRadius = _btnWidth/2;
    disLikeBtn.tag = 1;
    [disLikeBtn addTarget:self action:@selector(touchLikeOrDisLikeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [disLikeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self addSubview:(_disLikeBtn = disLikeBtn)];
}

- (void)touchLikeOrDisLikeBtn:(UIButton *)btn{
    [self.cardContainerView likeOrDislikeTopCard:(btn.tag == 0)];
}

- (void)enableBtn:(BOOL)enable{
    self.likeBtn.userInteractionEnabled = self.disLikeBtn.userInteractionEnabled = enable;
}

- (void)likeOrDislikeTopCard:(BOOL)isLike{
    NSLog(@"likeOrDislikeTopCard");
    
//    if (self.isDrag) {
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    self.dragCardView = self.cardViewArray.lastObject;
//    self.beginPoint = self.center;
//    CGFloat space = _determinSpace*2;
//    if (isLike) {
//        self.endPoint = CGPointMake(self.beginPoint.x, self.beginPoint.y+space);
//    }else{
//        self.endPoint = CGPointMake(self.beginPoint.x, self.beginPoint.y-space);
//    }
//    CGFloat angle = (isLike ? 1 : -1);
//    [UIView animateWithDuration:0.2 animations:^{
//        weakSelf.dragCardView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * M_PI_4 / 2);
//    }];
//    [self removeTopView:!isLike removeFinish:^{
//        for (NSInteger index = 1; index < weakSelf.cardViewArray.count; index ++) {
//            MPCardView *cardView = weakSelf.cardViewArray[index];
//            [UIView animateWithDuration:0.2 animations:^{
//                //                cardView.frame = weakSelf.frameArray[index].CGRectValue;
//                [cardView layoutIfNeeded];
//            }];
//        }
//        if (weakSelf.cardViewArray.count > 1) {
//            //            [weakSelf.cardViewArray[1] showShadow:YES];
//        }
//    }];
}

@end
