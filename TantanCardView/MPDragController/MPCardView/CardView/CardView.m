//
//  CardView.m
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "CardView.h"
#import "MPCardItemView.h"
#import "CardSetting.h"
#import "CardMacro.h"

@interface CardView ()

@property (nonatomic, assign) CGRect topCardFrame;
@property (nonatomic, weak) MPCardItemView *dragCardView;
@property (nonatomic, strong) NSMutableArray <MPCardItemView *> *cardViewArray;
@property (nonatomic, strong) NSMutableArray <CardSetting *> *cardSettingArray;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGFloat determinSpace;
@property (nonatomic, assign) CGFloat scaleSpace;
@property (nonatomic, assign) CGFloat dismissSpace;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger cardUsedModelIndex;
@property (nonatomic, assign) NSInteger hiddenCount;
@property (nonatomic, weak) UIButton *likeBtn;
@property (nonatomic, weak) UIButton *disLikeBtn;
@property (nonatomic, assign) CGSize btnSize;

@end

@implementation CardView

- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    __weak typeof(self) weakSelf = self;
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.cardViewArray = @[].mutableCopy;
    self.cardSettingArray = @[].mutableCopy;
    self.pageNo = 1;
    self.btnSize = CGSizeMake(84, 84);

    UIButton *disLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    disLikeBtn.backgroundColor = [UIColor redColor];
    disLikeBtn.tag = 0;
    [disLikeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:(_disLikeBtn = disLikeBtn)];

    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    likeBtn.backgroundColor = [UIColor orangeColor];
    likeBtn.tag = 1;
    [likeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:(_likeBtn = likeBtn)];

    [disLikeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_centerX).offset(-10);
        make.bottom.equalTo(weakSelf).offset(-20);
        make.size.mas_equalTo(weakSelf.btnSize);
    }];

    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_centerX).offset(10);
        make.bottom.equalTo(disLikeBtn);
        make.size.equalTo(disLikeBtn);
    }];
}

#pragma mark - Pirvate
- (void)enableBtn:(BOOL)enable{
    self.likeBtn.userInteractionEnabled = self.disLikeBtn.userInteractionEnabled = enable;
}

- (void)clickBtn:(UIButton *)btn{
    __weak typeof(self) weakSelf = self;
    self.dragCardView = self.cardViewArray.lastObject;
    NSInteger userId = self.dragCardView.model.userId;
    BOOL isUp;
    if (btn.tag == 0) {//不喜欢
        isUp = YES;
    }else{//喜欢
        isUp = NO;
    }
    if (self.cardViewArray.count > 1 && self.cardViewArray.firstObject.hidden == NO) {
        [self.cardViewArray.firstObject showShadowOpacity:self.cardSettingArray[1].shadowOpacity];
    }
    [self enableBtn:NO];
    [self removeTopView:isUp removeFinish:^{
        [weakSelf moveDragCardToBack:^{
            if (weakSelf.likeOrDislike) {//上滑不喜欢
                weakSelf.likeOrDislike(!isUp, userId);
            }
            if (weakSelf.hiddenCount == weakSelf.cardViewArray.count) {
                [weakSelf enableBtn:NO];
            }else{
                [weakSelf enableBtn:YES];
            }
        }];
    }];
}

/** 检测数据是否存在 */
- (BOOL)isArrayExist:(NSArray *)array{
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        return YES;
    }else{
        return NO;
    }
}

/** 计算平方差 */
- (CGFloat)sqrtValue:(CGFloat)width Height:(CGFloat)height{
    return sqrt(pow(width, 2)+pow(height, 2));
}

/** 根据缩放比和y轴偏移量,计算cardView的frame */
- (CGRect)getCardFrameWithBottomOffset:(CGFloat)offset andScale:(CGFloat)scale{
    CGFloat topCardWidth = CGRectGetWidth(_topCardFrame);
    CGFloat topCardHeight = CGRectGetHeight(_topCardFrame);
    CGFloat topCardCenterX = CGRectGetMidX(_topCardFrame);
    CGFloat topCardMaxY = CGRectGetMaxY(_topCardFrame);
    
    CGFloat thisCardWidth = topCardWidth * scale;
    CGFloat thisCardHeight = topCardHeight * scale;
    CGFloat thisCardX = topCardCenterX - thisCardWidth/2;
    CGFloat thisCardY = topCardMaxY + offset - thisCardHeight;
    
    return CGRectMake(thisCardX, thisCardY, thisCardWidth, thisCardHeight);
}

/** 准备所有卡片的参数 */
- (void)prepareCardSetting{
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    if ([self isArrayExist:self.cardSource] == NO) {
        return;
    }
    if (self.getItemView == nil) {
        return;
    }
    [self enableBtn:NO];
    __weak typeof(self) weakSelf = self;
    [self.cardSettingArray removeAllObjects];
    CGFloat topCardY = 90;
    CGFloat topCardWidth = self.bounds.size.width - 30;
    CGFloat topCardHeight = self.bounds.size.height - topCardY - self.btnSize.height - _topCardBottom2BtnTop - _btnBottom2ViewBottom;
    CGFloat topCardX = (self.bounds.size.width - topCardWidth)/2;
    
    _topCardFrame = CGRectMake(topCardX, topCardY, topCardWidth, topCardHeight);
    _scaleSpace = [self sqrtValue:self.bounds.size.width Height:self.bounds.size.height] * 0.25;
    _determinSpace = self.bounds.size.height * 0.2;
    _hiddenCount = 0;
    
    NSInteger cardCount = MIN(self.cardSource.count, _defaultDisplayCount);
    for (NSInteger index = 0; index < cardCount-1; index ++) {
        CGFloat cardBottomOffset = index * _bottomOffset;
        CGFloat cardScale = pow(_cardScale, index);
        CardSetting *cardSetting = [CardSetting new];
        cardSetting.viewScale = cardScale;
        cardSetting.cardFrame = [self getCardFrameWithBottomOffset:cardBottomOffset andScale:cardScale];
        [self.cardSettingArray insertObject:cardSetting atIndex:0];
    }
    CGFloat cardBottomOffset = 0;
    CGFloat cardScale = 0;
    CGFloat shadowOpacity = 0;
    if (cardCount <= 3) {
        cardBottomOffset = (cardCount-1) * _bottomOffset;
        cardScale = pow(_cardScale, cardCount-1);
        shadowOpacity = 1;
    }else{
        cardBottomOffset = (cardCount-2) * _bottomOffset;
        cardScale = pow(_cardScale, cardCount-2);
        shadowOpacity = 0;
    }
    CardSetting *cardSetting = [CardSetting new];
    cardSetting.viewScale = cardScale;
    cardSetting.cardFrame = [self getCardFrameWithBottomOffset:cardBottomOffset andScale:cardScale];
    cardSetting.shadowOpacity = shadowOpacity;
    [self.cardSettingArray insertObject:cardSetting atIndex:0];
    
    NSInteger minus = self.cardViewArray.count - cardCount;
    if (minus > 0) {//卡片多了
        for (NSInteger index = 0; index < minus; index ++) {
            [self.cardViewArray.lastObject removeFromSuperview];
            [self.cardViewArray removeLastObject];
        }
    }else if (minus < 0) {//卡片少了
        for (NSInteger index = 0; index < -minus; index ++) {
            MPCardItemView *cardView = self.getItemView();
            cardView.dragBegin = ^(CGPoint point) {
                [weakSelf drageBegin:point];
            };
            cardView.dragMove = ^(CGPoint point) {
                [weakSelf dragMove:point];
            };
            cardView.dragEnd = ^(CGPoint point) {
                [weakSelf dragEnd:point];
            };
            [self insertSubview:cardView atIndex:_cardStartIndex];
            [self.cardViewArray insertObject:cardView atIndex:0];
        }
    }
    
    NSInteger modelIndex = 0;
    for (NSInteger index = cardCount-1; index >= 0; index --) {
        MPCardItemView *cardView = self.cardViewArray[index];
        cardView.userInteractionEnabled = NO;
        cardView.tag = index;
        cardView.hidden = NO;
        cardView.model = self.cardSource[modelIndex++];
        cardView.frame = self.cardSettingArray.lastObject.cardFrame;
        [cardView layoutIfNeeded];
    }
    self.cardUsedModelIndex = self.cardViewArray.count;

    [UIView animateWithDuration:0.2 animations:^{
        for (NSInteger index = 0; index < weakSelf.cardViewArray.count-1; index ++) {
            MPCardItemView *cardView = weakSelf.cardViewArray[index];
            cardView.frame = weakSelf.cardSettingArray[index].cardFrame;
        }
    } completion:^(BOOL finished) {
        [weakSelf.cardViewArray.firstObject showShadowOpacity:weakSelf.cardSettingArray.firstObject.shadowOpacity];
        weakSelf.cardViewArray.lastObject.userInteractionEnabled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf enableBtn:YES];
        });
    }];
    
    [self bringSubviewToFront:self.disLikeBtn];
    [self bringSubviewToFront:self.likeBtn];
}

- (void)drageBegin:(CGPoint)point{
    self.beginPoint = point;
    self.dragCardView = self.cardViewArray.lastObject;
    [self enableBtn:NO];
}

- (void)dragMove:(CGPoint)point{
//    NSLog(@"Move=[%@]", NSStringFromCGPoint(point));
    //最上面一张平移
    CGFloat xLength = point.x - self.beginPoint.x;
    CGFloat yLength = point.y - self.beginPoint.y;
    self.dragCardView.center = CGPointMake(CGRectGetMidX(self.topCardFrame)+xLength, CGRectGetMidY(self.topCardFrame)+yLength);
    CGFloat yMoveLength = self.center.y - self.dragCardView.center.y;
    CGFloat moveDistance = [self sqrtValue:(self.dragCardView.center.x - self.center.x) Height:yMoveLength];
    self.dragCardView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (yMoveLength / self.frame.size.height) * (M_PI_4/2));
    
    //最底部一张不变，其余做放大和上移
    CGFloat percent = MIN(moveDistance/_scaleSpace, 1);
    for (NSInteger index = 0; index < self.cardViewArray.count-1; index ++) {
        if (self.cardViewArray[index].hidden) {
            continue;
        }
        CGFloat smallWidth = self.cardSettingArray[index].cardFrame.size.width;
        CGFloat biggerWidth = self.cardSettingArray[index+1].cardFrame.size.width;
        CGFloat minusWidth = biggerWidth - smallWidth;
        CGFloat addWidth = percent*minusWidth;
        CGFloat newWidth = smallWidth + addWidth;
        
        CGFloat smallHeight = self.cardSettingArray[index].cardFrame.size.height;
        CGFloat biggerHeight = self.cardSettingArray[index+1].cardFrame.size.height;
        CGFloat minusHeight = biggerHeight - smallHeight;
        CGFloat addHeight = percent*minusHeight;
        CGFloat newHeight = smallHeight + addHeight;
        
        CGFloat belowY = CGRectGetMinY(self.cardSettingArray[index].cardFrame);
        CGFloat upperY = CGRectGetMinY(self.cardSettingArray[index+1].cardFrame);
        CGFloat minusY = (belowY - upperY) * percent;
        
        CGFloat x = CGRectGetMidX(_topCardFrame) - newWidth/2;
        CGFloat y = belowY - minusY;
        
        MPCardItemView *cardView = self.cardViewArray[index];
        cardView.frame = CGRectMake(x, y, newWidth, newHeight);
    }
    
    if (self.cardViewArray.count > 3) {
        [self.cardViewArray.firstObject showShadowOpacity:percent];
    }
}

- (void)dragEnd:(CGPoint)point{
    __weak typeof(self) weakSelf = self;
    self.endPoint = point;
    CGFloat moveSpace = point.y - self.beginPoint.y;
    if (fabs(moveSpace) > self.determinSpace) {
        BOOL isUp;
        if (moveSpace < 0) {//卡片上滑
            isUp = YES;
        }else{//卡片下滑
            isUp = NO;
        }
        NSInteger userId = self.dragCardView.model.userId;
        [self.cardViewArray removeLastObject];
        [self removeTopView:isUp removeFinish:^{
            [weakSelf moveDragCardToBack:^{
                [weakSelf enableBtn:YES];
                if (weakSelf.likeOrDislike) {//上滑不喜欢
                    weakSelf.likeOrDislike(!isUp, userId);
                }
            }];
        }];
    }else{//还原
        MPCardItemView *layoutView = nil;
        if (self.cardViewArray.count > 1) {
            layoutView = self.cardViewArray[self.cardViewArray.count-2];
        }
        [self restoreDragCardView];
        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger index = 0; index < self.cardViewArray.count-1; index ++) {
                if (self.cardViewArray[index].hidden) {
                    continue;
                }
                weakSelf.cardViewArray[index].frame = weakSelf.cardSettingArray[index].cardFrame;
                if (layoutView == weakSelf.cardViewArray[index]) {
                    [layoutView layoutIfNeeded];
                }
            }
        } completion:^(BOOL finished) {
            if (finished) {
                [weakSelf enableBtn:YES];
            }
        }];
        [self.cardViewArray.firstObject showShadowOpacity:self.cardSettingArray.firstObject.shadowOpacity];
    }
}

/** 还原被拖拽的视图 */
- (void)restoreDragCardView{
//    self.dragCardView.userInteractionEnabled = NO;
//    __weak typeof(self) weakSelf = self;
//    [UIView animateWithDuration:0.5
//                          delay:0.0
//         usingSpringWithDamping:0.6
//          initialSpringVelocity:0.6
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         weakSelf.dragCardView.transform = CGAffineTransformIdentity;
//                         weakSelf.dragCardView.frame = weakSelf.topCardFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         weakSelf.isDrag = NO;
//                         weakSelf.dragCardView.userInteractionEnabled = YES;
//                     }];
    __weak typeof(self) weakSelf = self;
    CGFloat centerX = CGRectGetMidX(self.dragCardView.frame);
    CGFloat centerY = CGRectGetMidY(self.dragCardView.frame);
    CGFloat distance = [self sqrtValue:centerX-CGRectGetMidX(self.topCardFrame) Height:centerY-CGRectGetMidY(self.topCardFrame)];
    CGFloat animateTime = MAX(0.25, distance*_animateDurationPerPoint);
    [UIView animateKeyframesWithDuration:animateTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        weakSelf.dragCardView.transform = CGAffineTransformIdentity;
        weakSelf.dragCardView.frame = weakSelf.topCardFrame;
    } completion:^(BOOL finished) {
        [weakSelf enableBtn:YES];
    }];
}

/** 移除最顶上的卡片 */
- (void)removeTopView:(BOOL)isScroll2Top removeFinish:(void (^) (void))finish{
    __weak typeof(self) weakSelf = self;
    CGFloat centerMoveSpace  = 0;
    if (isScroll2Top) {
        centerMoveSpace = -CGRectGetMaxY(self.dragCardView.frame);
    }else{
        centerMoveSpace = self.bounds.size.height - CGRectGetMinY(self.dragCardView.frame);
    }
    CGFloat animateTime = MAX(fabs(centerMoveSpace) * _animateDurationPerPoint, 0.1);
    CGPoint dismissPoint = CGPointMake(CGRectGetMidX(self.dragCardView.frame), CGRectGetMidY(self.dragCardView.frame)+centerMoveSpace);
    [UIView animateWithDuration:animateTime animations:^{
        weakSelf.dragCardView.center = dismissPoint;
    } completion:^(BOOL finished) {
        if (finish) {
            finish();
        }
    }];
}

/** 将dragCardView放到视图层级最底部 */
- (void)moveDragCardToBack:(void (^) (void))moveFinish{
    __weak typeof(self) weakSelf = self;
    self.dragCardView.transform = CGAffineTransformIdentity;
    self.dragCardView.userInteractionEnabled = NO;
    [self.dragCardView removeFromSuperview];
    [self insertSubview:self.dragCardView atIndex:_cardStartIndex];
    [self.cardViewArray removeObject:self.dragCardView];
    [self.cardViewArray insertObject:self.dragCardView atIndex:0];
    [UIView animateWithDuration:0.25 animations:^{
        for (NSInteger index = weakSelf.cardViewArray.count-1; index > 0; index --) {
            weakSelf.cardViewArray[index].frame = weakSelf.cardSettingArray[index].cardFrame;
            [weakSelf.cardViewArray[index] layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            weakSelf.cardViewArray.lastObject.userInteractionEnabled = YES;
            if (weakSelf.cardUsedModelIndex >= weakSelf.cardSource.count) {//数据已经用完
                weakSelf.dragCardView.hidden = YES;
                if (++weakSelf.hiddenCount == weakSelf.cardViewArray.count) {
                    //数据已经全部展示完毕
                    if (weakSelf.nextPage) {
                        weakSelf.nextPage();
                    }
                }
            }else{
                weakSelf.dragCardView.model = weakSelf.cardSource[weakSelf.cardUsedModelIndex++];
                weakSelf.dragCardView.frame = weakSelf.cardSettingArray.firstObject.cardFrame;
                [weakSelf.dragCardView showShadowOpacity:weakSelf.cardSettingArray.firstObject.shadowOpacity];
            }
            if (moveFinish) {
                moveFinish();
            }
        }
    }];
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self prepareCardSetting];
}

- (void)setCardSource:(NSMutableArray<MPCardItemModel *> *)cardSource{
    if ([self isArrayExist:cardSource]) {
        _cardSource = [NSMutableArray arrayWithArray:cardSource];
        [self prepareCardSetting];
    }else{
        [self.cardViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.cardViewArray removeAllObjects];
    }
}

- (void)setGetItemView:(MPCardItemView *(^)(void))getItemView{
    _getItemView = getItemView;
    [self prepareCardSetting];
}

@end
