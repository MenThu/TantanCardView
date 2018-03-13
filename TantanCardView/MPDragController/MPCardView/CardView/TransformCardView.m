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

@interface TransformCardView ()

@property (nonatomic, strong) NSMutableArray <CardItemView *> *cardViewArray;
@property (nonatomic, strong) NSMutableArray <CardSetting *> *cardSettingArray;
@property (nonatomic, assign) CGRect topCardFrame;

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
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"call layoutSubviews");
    [self prepareCardSetting];
}

#pragma mark - Private
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
    __weak typeof(self) weakSelf = self;
    
    //计算顶部图片参数
    CGFloat cardViewWidth = CGRectGetWidth(self.bounds);
    CGFloat cardViewHeight = CGRectGetHeight(self.bounds);
    CGFloat topCardWidth = cardViewWidth * 0.8;
    CGFloat topCardHeight = cardViewHeight * 0.6;
    CGFloat topCardX = (cardViewWidth - topCardWidth)/2;
    CGFloat topCardY = (cardViewHeight - topCardHeight)/2;
    self.topCardFrame = CGRectMake(topCardX, topCardY, topCardWidth, topCardHeight);

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
//            itemView.dragBegin = ^(CGPoint point) {
//                [weakSelf drageBegin:point];
//            };
//            itemView.dragMove = ^(CGPoint point) {
//                [weakSelf dragMove:point];
//            };
//            itemView.dragEnd = ^(CGPoint point) {
//                [weakSelf dragEnd:point];
//            };
            [self insertSubview:itemView atIndex:_cardStartIndex];
            [self.cardViewArray insertObject:itemView atIndex:0];
        }
    }
    
    NSInteger modelIndex = 0;
    for (NSInteger index = cardCount-1; index >= 0; index --) {
        CardItemView *itemView = self.cardViewArray[index];
//        itemView.userInteractionEnabled = NO;
//        itemView.tag = index;
//        itemView.hidden = NO;
        itemView.transform = CGAffineTransformIdentity;
        itemView.cardModel = self.cardSource[modelIndex++];
    }
//    self.cardUsedModelIndex = self.cardViewArray.count;
    
    for (NSInteger index = 0; index < weakSelf.cardViewArray.count; index ++) {
        CardItemView *itemView = weakSelf.cardViewArray[index];
        CardSetting *settingModel = weakSelf.cardSettingArray[index];
        itemView.frame = self.topCardFrame;
        itemView.transform = [weakSelf makeTransformWith:settingModel.viewScale yOffset:settingModel.bottomOffsetY];
    }
    
    
//    [UIView animateWithDuration:0.2 animations:^{
//
//    } completion:^(BOOL finished) {
//        [weakSelf.cardViewArray.firstObject showShadowOpacity:weakSelf.cardSettingArray.firstObject.shadowOpacity];
//        weakSelf.cardViewArray.lastObject.userInteractionEnabled = YES;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf enableBtn:YES];
//        });
//    }];
}

- (CGAffineTransform)makeTransformWith:(CGFloat)scale yOffset:(CGFloat)offset{
    CGAffineTransform temp1 = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform temp2 = CGAffineTransformTranslate(temp1, 0, offset);
    return temp2;
}

- (BOOL)isArrayExist:(NSArray *)array{
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        return YES;
    }else{
        return NO;
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
