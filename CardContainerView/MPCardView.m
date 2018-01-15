//
//  MPCardView.m
//  TantanCardView
//
//  Created by MenThu on 2017/12/26.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#define MTColor(r,g,b,a)     [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define MTRandomColor      MTColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.f)

#import "MPCardView.h"

static CGFloat _cornerRadius = 4.f;
static CGFloat _topBottomSpace = 5;
static CGFloat _coverImageHeightScale = 0.65f;
static CGFloat _nickLabelHeight = 30;
static CGFloat _genderWidth = 20;
static CGFloat _ageLabelHeight = 30;
static CGFloat _distanceLabelHeight = 30;


@interface MPCardView ()

@property (nonatomic, weak) UIView *radiusViews;//圆角视图
@property (nonatomic, weak) UIImageView *coverImage;//用户头像
@property (nonatomic, weak) UILabel *nickLabel;//用户昵称
@property (nonatomic, weak) UIImageView *genderImage;//性别
@property (nonatomic, weak) UILabel *ageLabel;//年龄和星座
@property (nonatomic, weak) UILabel *distancelabel;//距离
@property (nonatomic, assign) BOOL isShowShadow;

@end

@implementation MPCardView

- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}

- (void)configView{
#if 0
    self.backgroundColor = MTRandomColor;
    return;
#endif
    self.backgroundColor = [UIColor whiteColor];
    _isShowShadow = YES;
    UIView *radiusViews = [[UIView alloc] init];
    radiusViews.layer.cornerRadius = _cornerRadius;
    radiusViews.layer.masksToBounds = YES;
    radiusViews.backgroundColor = [UIColor whiteColor];
    [self addSubview:(_radiusViews = radiusViews)];
    
    UIImageView *coverImage = [[UIImageView alloc] init];
    coverImage.backgroundColor = [UIColor orangeColor];
    [radiusViews addSubview:(_coverImage = coverImage)];
    
    UILabel *nickLabel = [UILabel new];
    nickLabel.text = @"测试名称";
    [radiusViews addSubview:(_nickLabel = nickLabel)];
    
    UIImageView *genderImage = [[UIImageView alloc] init];
    genderImage.backgroundColor = [UIColor purpleColor];
    [radiusViews addSubview:(_genderImage = genderImage)];
    
    UILabel *ageLabel = [UILabel new];
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.text = @"95后 · 双鱼座";
    [radiusViews addSubview:(_ageLabel = ageLabel)];
    
    UILabel *distancelabel = [UILabel new];
    distancelabel.textAlignment = NSTextAlignmentCenter;
    distancelabel.text = @"距你200m";
    [radiusViews addSubview:(_distancelabel = distancelabel)];
    
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowColor = [UIColor colorWithHexString:@"000000" alpha:0.3].CGColor;
    self.layer.shadowRadius = 5.f;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)layoutSubviews{
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    CGSize nickLabelMaxSize = CGSizeMake(MAXFLOAT, _nickLabelHeight);
    
    self.radiusViews.frame = self.bounds;
    CGFloat coverImageHeight = viewHeight * _coverImageHeightScale;
    self.coverImage.frame = CGRectMake(0, 0, viewWidth, coverImageHeight);
    
    CGFloat fitWidth = [self.nickLabel sizeThatFits:nickLabelMaxSize].width;
    CGFloat topSpace = ((viewHeight-coverImageHeight)-(_nickLabelHeight + _ageLabelHeight + _distanceLabelHeight) - 2*_topBottomSpace)/2;
    self.nickLabel.frame = CGRectMake(viewWidth/2-fitWidth/2, coverImageHeight+topSpace, fitWidth, _nickLabelHeight);
    CGFloat genderX = CGRectGetMaxX(self.nickLabel.frame)+3;
    CGFloat genderY = CGRectGetMidY(self.nickLabel.frame) - _genderWidth/2;
    self.genderImage.frame = CGRectMake(genderX, genderY, _genderWidth, _genderWidth);
    
    self.ageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nickLabel.frame)+_topBottomSpace, viewWidth, _ageLabelHeight);
    self.distancelabel.frame = CGRectMake(0, CGRectGetMaxY(self.ageLabel.frame)+_topBottomSpace, viewWidth, _distanceLabelHeight);
}

- (void)setModel:(MPCardModel *)model{
    _model = model;
    CGSize nickLabelMaxSize = CGSizeMake(MAXFLOAT, _nickLabelHeight);
    self.nickLabel.text = model.userName;
    CGFloat fitWidth = [self.nickLabel sizeThatFits:nickLabelMaxSize].width;
    CGFloat labelY = self.nickLabel.frame.origin.y;
    CGFloat labelX = self.nickLabel.center.x - fitWidth/2;
    self.nickLabel.frame = CGRectMake(labelX, labelY, fitWidth, _nickLabelHeight);
    self.genderImage.frame = CGRectMake(CGRectGetMaxX(self.nickLabel.frame)+3, self.genderImage.frame.origin.y, _genderWidth, _genderWidth);
    self.ageLabel.text = model.age;
    self.distancelabel.text = model.distance;
}

- (void)showShadowOpacity:(CGFloat)opacity{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.layer.shadowOpacity = opacity;
    }];
}

@end
