//
//  MPCardView.m
//  TantanCardView
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#define MTColor(r,g,b,a)     [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define MTRandomColor      MTColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.f)
#define MTWeakSelf __weak typeof(self) weakSelf = self

static NSInteger const VIEW_START_INDEX = 5;
static NSInteger const CARD_DEFAULT_COUNT = 4;//必须大于0
static CGFloat   const BTN_WIDTH = 80.f;
static CGFloat   const BTN_SPACE = 80;
static CGFloat   const LABEL_TOP_2_BACKBTN_BOTTOM = 10;
static CGFloat   const ITEMVIEW_TOP_2_HINTLABEL_BOTTOM = 15;
static CGFloat   const ITEMVIEW_BOTTOM_2_LIKEBTN_TOP = 30;
static CGFloat   const BTN_BOTTOM_2_VIEW_BOTTOM = 20;
static CGFloat   const VIEW_SCALE = 0.9;
static CGFloat   const BOTTOM_OFFSET = 8;
static CGFloat   const MAX_MOVE_DISTANCE = 300;
static CGFloat   const TIME_PERDISTANCE = 0.1f/100;
static CGFloat   const TOP_CARD_REMOVE_DISTANCE = 1000;

@interface _ItemViewSetting : NSObject

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat shadowOpacity;

@end

@implementation _ItemViewSetting

- (instancetype)init{
    if (self = [super init]) {
        self.scale = self.offset = 0;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", @{@"scale":@(self.scale), @"offset":@(self.offset)}];
}

@end

#import "MPCardView.h"

@interface MPCardView ()

@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, assign) CGRect backBtnFrame;
@property (nonatomic, weak) UIButton *addPicture;
@property (nonatomic, assign) CGRect addPicutreFrame;
@property (nonatomic, weak) UILabel *hintLabel;
@property (nonatomic, assign) CGSize labelSize;
@property (nonatomic, strong) NSMutableArray <MPCardItemView *> *itemViewArray;
@property (nonatomic, strong) NSMutableArray <_ItemViewSetting *> *settingArray;
@property (nonatomic, assign) CGFloat itemViewY;
@property (nonatomic, assign) CGRect itemViewFrame;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat viewCenterY;
@property (nonatomic, weak) UIButton *disLikeBtn;
@property (nonatomic, weak) UIButton *likeBtn;

@end

@implementation MPCardView

#pragma mark - LifeCircle
- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = [UIColor orangeColor];
    backBtn.tag = 0;
    [backBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:(_backBtn = backBtn)];
    
    UIButton *addPicture = [UIButton buttonWithType:UIButtonTypeCustom];
    addPicture.backgroundColor = [UIColor orangeColor];
    addPicture.tag = 1;
    [addPicture addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:(_addPicture = addPicture)];
    
    UILabel *hintLabel = [UILabel new];
    hintLabel.font = [UIFont systemFontOfSize:15];
    hintLabel.text = @"上滑跳过，下滑喜欢哟~";
    [self addSubview:(_hintLabel = hintLabel)];
    CGFloat hintLabelWidth = [hintLabel sizeThatFits:CGSizeMake(MAXFLOAT, hintLabel.font.lineHeight)].width;
    self.labelSize = CGSizeMake(hintLabelWidth, hintLabel.font.lineHeight);
    
    UIButton *disLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [disLikeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    disLikeBtn.layer.cornerRadius = BTN_WIDTH/2;
    disLikeBtn.tag = 2;
    disLikeBtn.backgroundColor = [UIColor orangeColor];
    [self addSubview:(_disLikeBtn = disLikeBtn)];
    
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    likeBtn.tag = 3;
    likeBtn.layer.cornerRadius = BTN_WIDTH/2;
    likeBtn.backgroundColor = [UIColor redColor];
    [self addSubview:(_likeBtn = likeBtn)];
    
    CGFloat backX = 20;
    CGFloat backY = 30;
    CGFloat scale = 7/12.f;
    CGFloat backWidth = 20;
    CGFloat backHeight = backWidth/scale;
    self.backBtn.frame = CGRectMake(backX, backY, backWidth, backHeight);
    self.itemViewY = CGRectGetMaxY(self.backBtn.frame) + LABEL_TOP_2_BACKBTN_BOTTOM + self.labelSize.height + ITEMVIEW_TOP_2_HINTLABEL_BOTTOM;
    self.itemViewArray = @[].mutableCopy;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat scale = 23/19.f;
    CGFloat rightSpace = 15;
    CGFloat addBtnWidth = 30;
    CGFloat addBtnHeight = addBtnWidth/scale;
    CGFloat centerY = CGRectGetMidY(self.backBtn.frame);
    CGFloat addBtnX = width - rightSpace - addBtnWidth;
    CGFloat addBtnY = centerY - addBtnHeight/2;
    self.addPicture.frame = CGRectMake(addBtnX, addBtnY, addBtnWidth, addBtnHeight);
    
    CGFloat labelX = (width - self.labelSize.width)/2;
    CGFloat labelY = CGRectGetMaxY(self.backBtn.frame) + LABEL_TOP_2_BACKBTN_BOTTOM;
    self.hintLabel.frame = CGRectMake(labelX, labelY, self.labelSize.width, self.labelSize.height);
    
    //右边喜欢，左边不喜欢
    CGFloat leftX = width/2 - BTN_SPACE/2 - BTN_WIDTH;
    CGFloat rightX = width/2 + BTN_SPACE/2;
    CGFloat y = height - BTN_BOTTOM_2_VIEW_BOTTOM - BTN_WIDTH;
    
    self.disLikeBtn.frame = CGRectMake(leftX, y, BTN_WIDTH, BTN_WIDTH);
    self.likeBtn.frame = CGRectMake(rightX, y, BTN_WIDTH, BTN_WIDTH);
}

#pragma mark - Private
/**
 *  点击按钮
 */
- (void)clickBtn:(UIButton *)btn{
    switch (btn.tag) {
        case 0://返回按钮
        {
            
        }
            break;
        case 1://添加或者更改背景图
        {
            
        }
            break;
        case 2://不喜欢
        {
            
        }
            break;
        case 3://喜欢
        {
            
        }
            break;
            
        default:
            break;
    }
}

/**
 *  开始布局卡片
 */
- (void)startLayoutCardView{
    if ([self.cardSource isKindOfClass:[NSArray class]] == NO || self.cardSource.count <= 0) {
        return;
    }
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.viewCenterY = height/2;
    CGFloat itemViewWidth = width * 0.8;
    CGFloat itemViewHeight = height - BTN_BOTTOM_2_VIEW_BOTTOM - BTN_WIDTH - ITEMVIEW_BOTTOM_2_LIKEBTN_TOP - self.itemViewY;
    CGFloat itemViewX = (width - itemViewWidth)/2;
    CGRect itemViewFrame = CGRectMake(itemViewX, self.itemViewY, itemViewWidth, itemViewHeight);
    
    NSInteger viewCount = MIN(self.cardSource.count, CARD_DEFAULT_COUNT);
    self.settingArray = @[].mutableCopy;
    for (NSInteger index = 0; index < viewCount-1; index ++) {
        _ItemViewSetting *setting = [_ItemViewSetting new];
        CGFloat actualScale = pow(VIEW_SCALE, index);
        setting.scale = actualScale;
        setting.offset = (index * BOTTOM_OFFSET + itemViewHeight/2 * (1-actualScale))/actualScale;
        setting.shadowOpacity = 1;
        [self.settingArray insertObject:setting atIndex:0];
    }
    
    NSInteger actualIndex = 1;
    CGFloat shadowOpacity = 1;
    if (viewCount > 3) {
        actualIndex = viewCount-2;
        shadowOpacity = 0;
    }else{
        actualIndex = viewCount-1;
        shadowOpacity = 1;
    }
    CGFloat actualScale = pow(VIEW_SCALE, actualIndex);
    CGFloat offset = actualIndex*BOTTOM_OFFSET;
    _ItemViewSetting *setting = [_ItemViewSetting new];
    setting.scale = actualScale;
    setting.offset = (offset + itemViewHeight/2 * (1-actualScale))/actualScale;
    setting.shadowOpacity = shadowOpacity;
    [self.settingArray insertObject:setting atIndex:0];
    
    NSInteger minusCount = self.itemViewArray.count - viewCount;
    if (minusCount < 0) {//需要增加卡片
        for (NSInteger index = 0; index < -minusCount; index ++) {
            MPCardItemView *itemView;
            if (self.viewOfCardItem == nil) {
                itemView = [[MPCardItemView alloc] init];
            }else{
                itemView = self.viewOfCardItem();
            }
            itemView.dragBegin = ^(CGPoint beginPoint) {
                weakSelf.beginPoint = beginPoint;
            };
            itemView.dragMove = ^(CGPoint movePoint) {
                [weakSelf cardDidBeginDrag:movePoint];
            };
            itemView.dragEnd = ^(CGPoint endPoint) {
                [weakSelf cardDidEndDrag:endPoint];
            };
            [self insertSubview:itemView atIndex:VIEW_START_INDEX];
            [self.itemViewArray insertObject:itemView atIndex:0];
        }
    }else if (minusCount > 0){//需要删除卡片
        for (NSInteger index = 0; index < minusCount; index ++) {
            [self.itemViewArray.lastObject removeFromSuperview];
            [self.itemViewArray removeLastObject];
        }
    }
    
    for (MPCardItemView *itemView in self.itemViewArray) {
        itemView.userInteractionEnabled = NO;
        itemView.frame = itemViewFrame;
        itemView.transform = CGAffineTransformIdentity;
    }
    
    [self inAnimate:0.2 animate:^{
        for (NSInteger index = 0; index < viewCount; index ++) {
            MPCardItemView *itemView = weakSelf.itemViewArray[index];
            _ItemViewSetting *setting = weakSelf.settingArray[index];
            CGAffineTransform scaleTransfrom = CGAffineTransformMakeScale(setting.scale, setting.scale);
            itemView.transform = CGAffineTransformTranslate(scaleTransfrom, 0, setting.offset);
        }
    } finish:^{
        weakSelf.itemViewArray.lastObject.userInteractionEnabled = YES;
    }];
    [self.itemViewArray.firstObject changeShaowOpacity:self.settingArray.firstObject.shadowOpacity];
}

- (CGFloat)sqrtValue:(CGFloat)width withHeight:(CGFloat)height{
    return sqrt(pow(width, 2) + pow(height, 2));
}

- (void)cardDidBeginDrag:(CGPoint)movePoint{
    //第一张做平移和倾斜的动画
    CGFloat xLength = movePoint.x - self.beginPoint.x;
    CGFloat yLength = movePoint.y - self.beginPoint.y;
    CGFloat yMoveLength = movePoint.y - self.viewCenterY;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(xLength, yLength);
    self.itemViewArray.lastObject.transform = CGAffineTransformRotate(transform, (yMoveLength / self.frame.size.height) * (M_PI_4/2));
    
    //最底部一张不变，其余做放大和上移
    CGFloat moveDistance = [self sqrtValue:xLength withHeight:yLength];
    CGFloat percent = MIN(moveDistance/MAX_MOVE_DISTANCE, 1);
    for (NSInteger index = 0; index < self.itemViewArray.count-1; index ++) {
        if (self.itemViewArray[index].hidden) {
            continue;
        }
        
        _ItemViewSetting *belowSetting = self.settingArray[index];
        _ItemViewSetting *aboveSetting = self.settingArray[index+1];
        CGFloat belowScale = belowSetting.scale;
        CGFloat belowOffset = belowSetting.offset;
        
        
        CGFloat aboveScale = aboveSetting.scale;
        CGFloat aboveOffset = aboveSetting.offset;
        
        CGFloat newScale = belowScale + (aboveScale-belowScale)*percent;
        CGFloat newOffset = belowOffset + (aboveOffset-belowOffset)*percent;
        
        
        CGAffineTransform scaleTransfrom = CGAffineTransformMakeScale(newScale, newScale);
        self.itemViewArray[index].transform = CGAffineTransformTranslate(scaleTransfrom, 0, newOffset);
    }

    if (self.itemViewArray.count > 3) {
        [self.itemViewArray.firstObject changeShaowOpacity:percent];
    }
}

- (void)cardDidEndDrag:(CGPoint)point{
    CGFloat distance = [self sqrtValue:(point.x - self.beginPoint.x) withHeight:(point.y - self.beginPoint.y)];
    if (distance < MAX_MOVE_DISTANCE) {//还原卡片
        [self restoreAllCard:distance];
    }else{//移除卡片
        BOOL removeFromTop = YES;
        [self removeTopCard:removeFromTop];
    }
}

- (void)removeTopCard:(BOOL)isRemoveFromTop{
    static CGFloat animateTime = TOP_CARD_REMOVE_DISTANCE * TIME_PERDISTANCE;
    __weak typeof(self) weakSelf = self;
    CGFloat distance = TOP_CARD_REMOVE_DISTANCE * (isRemoveFromTop == YES ? -1 : 1);
    [self inAnimate:animateTime animate:^{
        CGAffineTransform transform = weakSelf.itemViewArray.lastObject.transform;
        weakSelf.itemViewArray.lastObject.transform = CGAffineTransformTranslate(transform, 0, distance);
    } finish:^{
    }];
}

- (void)restoreAllCard:(CGFloat)distance{
    __weak typeof(self) weakSelf = self;
    CGFloat animateTime = MAX(distance * TIME_PERDISTANCE, 0.25);
    NSLog(@"animateTime=[%.2f]", animateTime);
    self.itemViewArray.lastObject.userInteractionEnabled = NO;
    [self inAnimate:animateTime animate:^{
        weakSelf.itemViewArray.lastObject.transform = CGAffineTransformIdentity;
    } finish:^{
        weakSelf.itemViewArray.lastObject.userInteractionEnabled = YES;
    }];
    
    [self inAnimate:animateTime animate:^{
        for (NSInteger index = 0; index < weakSelf.itemViewArray.count-1; index ++) {
            MPCardItemView *itemView = weakSelf.itemViewArray[index];
            _ItemViewSetting *setting = weakSelf.settingArray[index];
            CGAffineTransform scaleTransfrom = CGAffineTransformMakeScale(setting.scale, setting.scale);
            itemView.transform = CGAffineTransformTranslate(scaleTransfrom, 0, setting.offset);
        }
    } finish:^{
        [weakSelf.itemViewArray.firstObject changeShaowOpacity:weakSelf.settingArray.firstObject.shadowOpacity];
    }];
}

- (void)inAnimate:(CGFloat)duration animate:(void (^) (void))animate finish:(void (^) (void))completion{
    NSAssert(animate != nil, @"");
    [UIView animateWithDuration:duration animations:animate completion:^(BOOL finished) {
        if (finished) {
            if (completion) {
                completion();
            }
        }
    }];
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self startLayoutCardView];
}

- (void)setCardSource:(NSMutableArray<CardItemModel *> *)cardSource{
    _cardSource = cardSource;
    [self startLayoutCardView];
}

@end
