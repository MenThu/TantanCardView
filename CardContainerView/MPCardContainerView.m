//
//  MPCardContainerView.m
//  TantanCardView
//
//  Created by MenThu on 2017/12/26.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#define MTColor(r,g,b,a)     [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define MTRandomColor      MTColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.f)
#define LineColor MTRandomColor
#define MTWeakSelf __weak typeof(self) weakSelf = self

#import "MPCardContainerView.h"
#import "MPCardView.h"

//卡片参数相关
static NSInteger _defaultDisplayCount = 4;
static CGFloat _bottomOffset = 10.f;
static CGFloat _cardScale = 0.9f;
static CGFloat _animateDurationPerPoint = 0.05/100;

@interface CardSetting : NSObject

@property (nonatomic, assign) CGRect cardFrame;
@property (nonatomic, assign) CGFloat viewScale;
@property (nonatomic, assign) CGFloat bottomOffsetY;
@property (nonatomic, assign) CGFloat shadowOpacity;

@end

@implementation CardSetting

- (instancetype)init{
    if (self = [super init]) {
        self.shadowOpacity = 1.f;
    }
    return self;
}

@end

@interface MPCardContainerView (){
    dispatch_group_t _animateGroup;
}

@property (nonatomic, assign) CGRect topCardFrame;
@property (nonatomic, weak) MPCardView *dragCardView;
@property (nonatomic, strong) NSMutableArray <MPCardView *> *cardViewArray;
@property (nonatomic, strong) NSMutableArray <CardSetting *> *cardSettingArray;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGFloat determinSpace;
@property (nonatomic, assign) CGFloat scaleSpace;
@property (nonatomic, assign) CGFloat dismissSpace;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger cardIndex;
@property (nonatomic, assign) NSInteger hiddenCount;
@property (nonatomic, assign) BOOL canBeDrag;
@property (nonatomic, assign) BOOL isDrag;
@property (nonatomic, weak) UIButton *likeBtn;
@property (nonatomic, weak) UIButton *disLikeBtn;

@end

@implementation MPCardContainerView

#pragma mark - LifeCircle
- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}

/** 配置视图 **/
- (void)configView{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.cardViewArray = @[].mutableCopy;
    self.cardSettingArray = @[].mutableCopy;
    self.pageNo = 1;
    _animateGroup = dispatch_group_create();
}

#pragma mark - Private
/** 准备所有卡片的参数 */
- (void)prepareCardSetting{
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    if ([self isArrayExist:self.cardSource] == NO) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [self.cardSettingArray removeAllObjects];
    
    CGFloat topCardWidth = self.bounds.size.width * 0.8;
    CGFloat topCardHeight = self.bounds.size.height * 0.6;
    CGFloat topCardX = (self.bounds.size.width - topCardWidth)/2;
    CGFloat topCardY = 100;
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
            MPCardView *cardView = [[MPCardView alloc] init];
            [self addSubview:cardView];
            [self.cardViewArray addObject:cardView];
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGesture:)];
            [cardView addGestureRecognizer:panGesture];
        }
    }
    
    NSInteger modelIndex = 0;
    for (NSInteger index = cardCount-1; index >= 0; index --) {
        MPCardView *cardView = self.cardViewArray[index];
        cardView.userInteractionEnabled = NO;
        cardView.tag = index;
        cardView.hidden = NO;
        cardView.model = self.cardSource[modelIndex++];
        cardView.frame = self.cardSettingArray.lastObject.cardFrame;
        [cardView layoutIfNeeded];
    }
    
    self.cardIndex = self.cardViewArray.count;
    [self refreshAllCardView:^{
        weakSelf.canBeDrag = YES;
        weakSelf.cardViewArray.lastObject.userInteractionEnabled = YES;
    }];
}

/** 拖拽手势 */
- (void)dragGesture:(UIPanGestureRecognizer *)gestrue{
    if (self.canBeDrag ==  NO) {
        return;
    }
    switch (gestrue.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self drageBegin:[gestrue locationInView:self]];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint movePoint = [gestrue translationInView:self.dragCardView];
            [gestrue setTranslation:CGPointZero inView:self.dragCardView];
            [self dragMove:movePoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self dragEnd:[gestrue locationInView:self]];
        }
            break;
            
        default:
            break;
    }
}

/** 按照cardsettingArray刷新所有cardView */
- (void)refreshAllCardView:(void (^) (void))finish{
    __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger index = 0; index < weakSelf.cardViewArray.count; index ++) {
                MPCardView *cardView = weakSelf.cardViewArray[index];
                cardView.frame = weakSelf.cardSettingArray[index].cardFrame;
            }
        } completion:^(BOOL finished) {
            [weakSelf.cardViewArray.firstObject showShadowOpacity:weakSelf.cardSettingArray.firstObject.shadowOpacity];
            if (finish) {
                finish();
            }
        }];
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

/** 响应者链 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.cardViewArray.lastObject.frame, point)) {
        return YES;
    }else{
        return self.isDrag == YES;
    }
}

- (void)drageBegin:(CGPoint)beginPoint{
    NSLog(@"Begin");
    if (self.isDrag) {
        return;
    }
    self.beginPoint = beginPoint;
    self.dragCardView = self.cardViewArray.lastObject;
    self.isDrag = YES;
}

- (void)dragMove:(CGPoint)movePoint{
    NSLog(@"Move=[%@]", NSStringFromCGPoint(movePoint));
    //最上面一张平移
//    CGFloat xLength = movePoint.x-_beginPoint.x;
//    CGFloat yLength = movePoint.y-_beginPoint.y;
//    CGFloat moveDistance = [self sqrtValue:xLength Height:yLength];
//    self.dragCardView.center = CGPointMake(CGRectGetMidX(_topCardFrame)+xLength, CGRectGetMidY(_topCardFrame)+yLength);
//    self.dragCardView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (yLength / self.frame.size.height) * (M_PI_4/2));
    CGFloat xLength = movePoint.x;
    CGFloat yLength = movePoint.y;
    self.dragCardView.center = CGPointMake(self.dragCardView.center.x+xLength, self.dragCardView.center.y+yLength);
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
        
        MPCardView *cardView = self.cardViewArray[index];
        cardView.frame = CGRectMake(x, y, newWidth, newHeight);
    }
    
    if (self.cardViewArray.count > 3) {
        [self.cardViewArray.firstObject showShadowOpacity:percent];
    }
}

- (void)dragEnd:(CGPoint)endPoint{
    NSLog(@"End");
    self.canBeDrag = NO;
    __weak typeof(self) weakSelf = self;
    self.endPoint = endPoint;
    CGFloat moveSpace = endPoint.y - _beginPoint.y;
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
            [weakSelf moveDragCardToBack];
            weakSelf.isDrag = NO;
            weakSelf.canBeDrag = YES;
            if (weakSelf.likeOrDislike) {//上滑不喜欢
                weakSelf.likeOrDislike(!isUp, userId);
            }
        }];
    }else{//还原
        MPCardView *layoutView = nil;
        if (self.cardViewArray.count > 1) {
            layoutView = self.cardViewArray[self.cardViewArray.count-2];
        }
        [self restoreDragCardView];
        for (NSInteger index = 0; index < self.cardViewArray.count-1; index ++) {
            if (self.cardViewArray[index].hidden) {
                continue;
            }
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.cardViewArray[index].frame = weakSelf.cardSettingArray[index].cardFrame;
                if (layoutView == weakSelf.cardViewArray[index]) {
                    [layoutView layoutIfNeeded];
                }
            }];
        }
        [self.cardViewArray.firstObject showShadowOpacity:self.cardSettingArray.firstObject.shadowOpacity];
    }
}

/** 还原被拖拽的视图 */
- (void)restoreDragCardView{
    self.dragCardView.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             weakSelf.dragCardView.transform = CGAffineTransformIdentity;
                             weakSelf.dragCardView.frame = weakSelf.topCardFrame;
                         }
                         completion:^(BOOL finished) {
                             weakSelf.isDrag = NO;
                             weakSelf.canBeDrag = YES;
                             weakSelf.dragCardView.userInteractionEnabled = YES;
                         }];
}

/** 将dragCardView放到视图层级最底部 */
- (void)moveDragCardToBack{
    self.dragCardView.transform = CGAffineTransformIdentity;
    self.dragCardView.userInteractionEnabled = NO;
    [self.cardViewArray insertObject:self.dragCardView atIndex:0];
    self.cardViewArray.lastObject.userInteractionEnabled = YES;
    [self.dragCardView removeFromSuperview];
    [self insertSubview:self.dragCardView atIndex:0];
    if (self.cardIndex >= self.cardSource.count) {//数据已经用完
        self.dragCardView.hidden = YES;
        if (++self.hiddenCount == self.cardViewArray.count) {
            //数据已经全部展示完毕
            if (self.nextPage) {
                self.nextPage(++self.pageNo);
            }
        }
    }else{
        self.dragCardView.model = self.cardSource[self.cardIndex++];
        self.dragCardView.frame = self.cardSettingArray.firstObject.cardFrame;
        [self.dragCardView showShadowOpacity:self.cardSettingArray.firstObject.shadowOpacity];
    }
}

/** 计算平方差 */
- (CGFloat)sqrtValue:(CGFloat)width Height:(CGFloat)height{
    return sqrt(pow(width, 2)+pow(height, 2));
}

/** 检测数据是否存在 */
- (BOOL)isArrayExist:(NSArray *)array{
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        return YES;
    }else{
        return NO;
    }
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

#pragma mark - Public
- (void)likeOrDislikeTopCard:(BOOL)isLike{
    __weak typeof(self) weakSelf = self;
    self.isDrag = YES;
    self.dragCardView = self.cardViewArray.lastObject;
    NSInteger userId = self.dragCardView.model.userId;
    [self.cardViewArray removeLastObject];
    NSInteger offset = self.cardSettingArray.count - self.cardViewArray.count;
    for (NSInteger index = 0; index < self.cardViewArray.count; index ++) {
        MPCardView *cardView = self.cardViewArray[index];
        if (cardView.hidden) {
            continue;
        }
        dispatch_group_enter(_animateGroup);
        [UIView animateWithDuration:0.2 animations:^{
            cardView.frame = weakSelf.cardSettingArray[index+offset].cardFrame;
            [cardView layoutIfNeeded];
            [cardView showShadowOpacity:weakSelf.cardSettingArray[index+offset].shadowOpacity];
        } completion:^(BOOL finished) {
            dispatch_group_leave(_animateGroup);
        }];
    }
    dispatch_group_enter(_animateGroup);
    CGFloat angle = M_PI_4/2 * (isLike == YES ? 1 : -1);
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.dragCardView.transform = CGAffineTransformMakeRotation(angle);
    } completion:^(BOOL finished) {
        dispatch_group_leave(_animateGroup);
    }];
    dispatch_group_enter(_animateGroup);
    [self removeTopView:!isLike removeFinish:^{
        dispatch_group_leave(_animateGroup);
    }];
    dispatch_group_notify(_animateGroup, dispatch_get_main_queue(), ^{
        [weakSelf moveDragCardToBack];
        weakSelf.isDrag = NO;
        if (weakSelf.likeOrDislike) {
            weakSelf.likeOrDislike(isLike, userId);
        }
    });
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self prepareCardSetting];
}

- (void)setCardSource:(NSMutableArray<MPCardModel *> *)cardSource{
    if ([self isArrayExist:cardSource]) {
        _cardSource = [NSMutableArray arrayWithArray:cardSource];
        [self prepareCardSetting];
    }else{
        [self.cardViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.cardViewArray removeAllObjects];
    }
}

@end
