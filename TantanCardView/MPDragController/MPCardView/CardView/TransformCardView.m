//
//  TransformCardView.m
//  TantanCardView
//
//  Created by MenThu on 2018/3/13.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "TransformCardView.h"
#import "CardItemView.h"
#import "CardSetting.h"
#import "CardMacro.h"
#import "CardItemView.h"

@interface TransformCardView (){
    dispatch_group_t _animateGroup;
}

@property (nonatomic, strong) NSMutableArray <CardItemView *> *cardViewArray;
@property (nonatomic, strong) NSMutableArray <CardSetting *> *cardSettingArray;
@property (nonatomic, assign) CGRect topCardFrame;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGFloat scaleDistance;
@property (nonatomic, assign) CGFloat determinDistance;
@property (nonatomic, assign) BOOL isLayoutSubViewCall;
@property (nonatomic, assign) NSInteger modelIndex;
@property (nonatomic, assign) NSInteger cardHiddenCount;
@property (nonatomic, assign) BOOL isAskingForMoreData;

@end

@implementation TransformCardView

#pragma mark - LifeCircle
- (void)awakeFromNib{
    [super awakeFromNib];
    [self configCardView];
}

- (instancetype)init{
    if (self = [super init]) {
        [self configCardView];
    }
    return self;
}

- (void)configCardView{
    self.cardViewArray = @[].mutableCopy;
    self.cardSettingArray = @[].mutableCopy;
    self.isNoMoreData = self.isLayoutSubViewCall = NO;
    self.modelIndex = 0;
    self.cardHiddenCount = 0;
    _animateGroup = dispatch_group_create();
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.isLayoutSubViewCall && !CGRectEqualToRect(self.bounds, CGRectZero)) {
        self.isLayoutSubViewCall = YES;
        [self prepareCardSetting];
    }
}

#pragma mark - Private
/** 配置卡片 */
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
    CardWeakSelf;
    
    //计算顶部图片参数
    CGFloat cardViewWidth = CGRectGetWidth(self.bounds);
    CGFloat cardViewHeight = CGRectGetHeight(self.bounds);
    CGFloat topCardWidth = cardViewWidth * 1;
    CGFloat topCardHeight = cardViewHeight * 1;
    CGFloat topCardX = (cardViewWidth - topCardWidth)/2;
    CGFloat topCardY = (cardViewHeight - topCardHeight)/2;
    self.topCardFrame = CGRectMake(topCardX, topCardY, topCardWidth, topCardHeight);
    self.scaleDistance = [self sqrtValue:cardViewWidth Height:cardViewHeight] * 0.25;
    self.determinDistance = cardViewWidth * 0.15;

    //计算每个卡片对应的参数
    [self.cardSettingArray removeAllObjects];
    NSInteger cardCount = MIN(self.cardSource.count, _defaultDisplayCount);
    for (NSInteger index = 0; index < cardCount-1; index ++) {
        CGFloat actualScale = pow(_cardScale, index);
        CGFloat actualBottomOffset = (topCardHeight/2 - actualScale*topCardHeight/2 + (index*_bottomOffset))/actualScale;
        CardSetting *cardSetting = [CardSetting new];
        cardSetting.viewScale = actualScale;
        cardSetting.cardFrame = self.topCardFrame;
        cardSetting.bottomOffsetY = actualBottomOffset;
        [self.cardSettingArray insertObject:cardSetting atIndex:0];
    }
    CGFloat cardBottomOffset = 0;
    CGFloat cardScale = 0;
    CGFloat shadowOpacity = 0;
    if (cardCount <= 3) {
        cardScale = pow(_cardScale, cardCount-1);
        cardBottomOffset = (0.5*topCardHeight*(1-cardScale)+(cardCount-1)*_bottomOffset)/cardScale;
        shadowOpacity = 1;
    }else{
        cardScale = pow(_cardScale, cardCount-2);
        cardBottomOffset = (0.5*topCardHeight*(1-cardScale)+(cardCount-2)*_bottomOffset)/cardScale;
        shadowOpacity = 0;
    }
    CardSetting *cardSetting = [CardSetting new];
    cardSetting.bottomOffsetY = cardBottomOffset;
    cardSetting.viewScale = cardScale;
    cardSetting.cardFrame = self.topCardFrame;
    cardSetting.shadowOpacity = shadowOpacity;
    [self.cardSettingArray insertObject:cardSetting atIndex:0];
    
    //添加(或者删除)卡片视图
    NSInteger minus = self.cardViewArray.count - cardCount;
    if (minus > 0) {//卡片多了
        for (NSInteger index = 0; index < minus; index ++) {
            [self.cardViewArray.lastObject removeFromSuperview];
            [self.cardViewArray removeLastObject];
        }
    }else if (minus < 0) {//卡片少了
        for (NSInteger index = 0; index < -minus; index ++) {
            CardItemView *itemView = self.getItemView();
            NSAssert([itemView isKindOfClass:[CardItemView class]], @"");
            itemView.backgroundColor = MTRandomColor;
            itemView.dragBegin = ^(CGPoint point) {
                [weakSelf dragBegin:point];
            };
            itemView.dragMove = ^(CGPoint point) {
                [weakSelf dragMove:point];
            };
            itemView.dragEnd = ^(CGPoint point) {
                [weakSelf dragEnd:point];
            };
            [self insertSubview:itemView atIndex:_cardStartIndex];
            [self.cardViewArray insertObject:itemView atIndex:0];
        }
    }
    
    //根据数据源刷新卡片
    NSInteger modelIndex = 0;
    for (NSInteger index = cardCount-1; index >= 0; index --) {
        CardItemView *itemView = self.cardViewArray[index];
        itemView.userInteractionEnabled = NO;
        itemView.hidden = NO;
        itemView.transform = CGAffineTransformIdentity;
        itemView.cardModel = self.cardSource[modelIndex++];
    }
    self.modelIndex = self.cardViewArray.count;

    for (NSInteger index = 0; index < self.cardViewArray.count; index ++) {
        CardItemView *itemView = self.cardViewArray[index];
        CardSetting *settingModel = self.cardSettingArray[index];
        itemView.frame = self.topCardFrame;
        itemView.transform = [self makeTransformWith:settingModel.viewScale yOffset:settingModel.bottomOffsetY];
    }
    self.cardViewArray.lastObject.userInteractionEnabled = YES;
}

/** 构建Transform */
- (CGAffineTransform)makeTransformWith:(CGFloat)scale yOffset:(CGFloat)offset{
    CGAffineTransform temp1 = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform temp2 = CGAffineTransformTranslate(temp1, 0, offset);
    return temp2;
}

/** 判断数据是否存在 */
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

/** 开始拖动 */
- (void)dragBegin:(CGPoint)point{
    self.beginPoint = point;
//    self.dragView = self.cardViewArray.lastObject;
}

/** 正在拖动 */
- (void)dragMove:(CGPoint)point{
    //最上面一张平移
    CGFloat xLength = point.x - self.beginPoint.x;
    CGFloat yLength = point.y - self.beginPoint.y;
    self.cardViewArray.lastObject.center = CGPointMake(CGRectGetMidX(self.topCardFrame)+xLength, CGRectGetMidY(self.topCardFrame)+yLength);
//    CGFloat yMoveLength = self.center.y - self.cardViewArray.lastObject.center.y;
    CGFloat moveDistance = [self sqrtValue:xLength Height:yLength];
    self.cardViewArray.lastObject.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (xLength / self.frame.size.height) * (M_PI_4/2));
    
    //最底部一张不变，其余做放大和上移
    CGFloat percent = MIN(moveDistance/self.scaleDistance, 1);
    for (NSInteger index = 1; index < self.cardViewArray.count-1; index ++) {
//        if (self.cardViewArray[index].hidden) {
//            continue;
//        }
        CGFloat belowScale = self.cardSettingArray[index].viewScale;
        CGFloat aboveScale = self.cardSettingArray[index+1].viewScale;
        CGFloat minusScale = aboveScale - belowScale;
        CGFloat addScale = percent*minusScale;
        CGFloat newScale = belowScale + addScale;
        
        CGFloat belowOffset = self.cardSettingArray[index].bottomOffsetY;
        CGFloat aboveOffset = self.cardSettingArray[index+1].bottomOffsetY;
        CGFloat minusOffset = aboveOffset - belowOffset;
        CGFloat addOffset = percent*minusOffset;
        CGFloat newOffset = belowOffset + addOffset;
        
        self.cardViewArray[index].transform = [self makeTransformWith:newScale yOffset:newOffset];
    }
    
//    if (self.cardViewArray.count > 3) {
//        [self.cardViewArray.firstObject showShadowOpacity:percent];
//    }
}

/** 拖动结束 */
- (void)dragEnd:(CGPoint)point{
    self.endPoint = point;
    CGFloat moveSpace = point.x - self.beginPoint.x;
    if (fabs(moveSpace) > self.determinDistance) {
        BOOL isRight;
        if (moveSpace < 0) {
            isRight = NO;
        }else{
            isRight = YES;
        }
        [self removeTopCardView:isRight finish:nil];
    }else{//还原
        [self restoreCardView];
    }
}

/** 移除最底层的卡片 */
- (void)removeTopCardView:(BOOL)isRight finish:(void (^) (void))removeFinish{
    CardWeakSelf;
    self.cardViewArray.lastObject.userInteractionEnabled = NO;
    CGFloat xMoveDistance;
    if (isRight) {
        xMoveDistance = CGRectGetWidth(self.bounds)-CGRectGetMinX(self.cardViewArray.lastObject.frame);
    }else{
        xMoveDistance = -CGRectGetMaxX(self.cardViewArray.lastObject.frame);
    }
    CGPoint disappearCenter = CGPointMake(self.cardViewArray.lastObject.center.x + xMoveDistance, self.cardViewArray.lastObject.center.y);
    dispatch_group_enter(_animateGroup);
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.cardViewArray.lastObject.center = disappearCenter;
    } completion:^(BOOL finished) {
        if (finished) {
            dispatch_group_leave(_animateGroup);
        }
    }];
    for (NSInteger index = 1; index < self.cardViewArray.count-1; index ++) {
//        if (self.cardViewArray[index].hidden) {
//            continue;
//        }
        dispatch_group_enter(_animateGroup);
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.cardViewArray[index].transform = [weakSelf makeTransformWith:weakSelf.cardSettingArray[index+1].viewScale yOffset:weakSelf.cardSettingArray[index+1].bottomOffsetY];
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_group_leave(_animateGroup);
            }
        }];
    }
    dispatch_group_notify(_animateGroup, dispatch_get_main_queue(), ^{
        [weakSelf moveTopCard2Bottom];
        if (removeFinish) {
            removeFinish();
        }
    });
}

/** 将顶部卡片查到最底部 */
- (void)moveTopCard2Bottom{
    CardItemView *itemView = self.cardViewArray.lastObject;
    [itemView removeFromSuperview];
    [self.cardViewArray removeLastObject];
    itemView.transform = CGAffineTransformIdentity;
    [self insertSubview:itemView atIndex:_cardStartIndex];
    [self.cardViewArray insertObject:itemView atIndex:0];
    itemView.frame = self.topCardFrame;
    itemView.transform = [self makeTransformWith:self.cardSettingArray[0].viewScale yOffset:self.cardSettingArray[0].bottomOffsetY];
    self.cardViewArray.lastObject.userInteractionEnabled = YES;
    if (self.modelIndex > self.cardSource.count-1) {//没有新的数据了
        itemView.hidden = YES;
        self.cardHiddenCount++;
        [self checkIfDataIsEnd];
    }else{
        itemView.hidden = NO;
        itemView.cardModel = self.cardSource[self.modelIndex++];
        [self requestForMoreDataIfNeed];
    }
}

/** 还原所有卡片 */
- (void)restoreCardView{
    CardWeakSelf;
    [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        weakSelf.cardViewArray.lastObject.center = CGPointMake(CGRectGetMidX(weakSelf.topCardFrame), CGRectGetMidY(weakSelf.topCardFrame));
        weakSelf.cardViewArray.lastObject.transform = CGAffineTransformMakeRotation(0);
    } completion:nil];
    for (NSInteger index = 0; index < self.cardViewArray.count-1; index ++) {
        CardSetting *setting = self.cardSettingArray[index];
        CardItemView *itemView = self.cardViewArray[index];
        [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            itemView.transform = [weakSelf makeTransformWith:setting.viewScale yOffset:setting.bottomOffsetY];
        } completion:nil];
    }
}

/** 检查数据是否已经全部使用完成 */
- (void)checkIfDataIsEnd{
    if (!self.isNoMoreData) {
        return;
    }
    BOOL isAllCardHidden = (self.cardViewArray.count <= self.cardHiddenCount);
    if (isAllCardHidden && self.allCardDataIsDone) {
        self.allCardDataIsDone();
    }
}

- (void)appendCardArray:(NSArray *)array{
    self.isAskingForMoreData = NO;
    [self.cardSource addObjectsFromArray:array];
    NSInteger endIndex = self.cardHiddenCount-1;
    NSInteger length = MIN(self.cardHiddenCount, array.count);
    NSInteger startIndex = endIndex - length + 1;
    for (NSInteger index = endIndex; index >= startIndex; index --) {
        self.cardViewArray[index].hidden = NO;
        self.cardViewArray[index].cardModel = self.cardSource[self.modelIndex++];
    }
    self.cardHiddenCount -= length;
}

/** 如果需要,则请求更多数据 */
- (void)requestForMoreDataIfNeed{
    if (self.isAskingForMoreData || !self.needMoreData || self.isNoMoreData) {
        return;
    }
    if (self.cardSource.count-self.modelIndex < _aheadCardCount) {
        self.isAskingForMoreData = YES;
        self.needMoreData();
    }
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self prepareCardSetting];
}

- (void)setCardSource:(NSMutableArray *)cardSource{
    if ([self isArrayExist:cardSource]) {
        _cardSource = [NSMutableArray arrayWithArray:cardSource];
        [self prepareCardSetting];
    }else{
        [self.cardViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.cardViewArray removeAllObjects];
    }
}

- (void)setGetItemView:(CardItemView *(^)(void))getItemView{
    _getItemView = getItemView;
    [self prepareCardSetting];
}

@end
