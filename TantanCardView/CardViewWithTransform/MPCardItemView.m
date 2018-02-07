//
//  MPCardItemView.m
//  TantanCardView
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

static CGFloat const TOP_BOTTOM_SPACE = 5;
static CGFloat const CORNER_RADIUS = 4;
static CGFloat const NICK_LABEL_HEIGHT = 30;
static CGFloat const DISTANCE_LABEL_HEIGHT = 30;
static CGFloat const AGE_LABEL_HEIGHT = 30;
static CGFloat const GENDER_WIDTH = 20;
static CGFloat const COVER_IMAGE_HEIGHT_SCALE = 0.65f;

#import "MPCardItemView.h"

@interface MPCardItemView ()

@property (nonatomic, weak) UIView *radiusViews;//圆角视图
@property (nonatomic, weak) UIImageView *coverImage;
@property (nonatomic, weak) UILabel *nickLabel;
@property (nonatomic, weak) UIImageView *genderImage;
@property (nonatomic, weak) UILabel *ageLabel;
@property (nonatomic, weak) UILabel *distancelabel;

@end

@implementation MPCardItemView

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
    UIView *radiusViews = [[UIView alloc] init];
    radiusViews.layer.cornerRadius = CORNER_RADIUS;
    radiusViews.layer.masksToBounds = YES;
    radiusViews.backgroundColor = [UIColor whiteColor];
    [self addSubview:(_radiusViews = radiusViews)];
    
    UIImageView *coverImage = [[UIImageView alloc] init];
    coverImage.backgroundColor = [UIColor orangeColor];
    [radiusViews addSubview:(_coverImage = coverImage)];
    
    UILabel *nickLabel = [UILabel new];
    nickLabel.font = [UIFont systemFontOfSize:15];
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
    self.layer.cornerRadius = CORNER_RADIUS;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.radiusViews.frame = self.bounds;
    
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    CGFloat coverImageHeight = viewHeight * COVER_IMAGE_HEIGHT_SCALE;
    self.coverImage.frame = CGRectMake(0, 0, viewWidth, coverImageHeight);
    
    CGSize nickLabelMaxSize = CGSizeMake(MAXFLOAT, NICK_LABEL_HEIGHT);
    CGFloat fitWidth = [self.nickLabel sizeThatFits:nickLabelMaxSize].width;
    CGFloat topSpace = ((viewHeight-coverImageHeight)-(NICK_LABEL_HEIGHT + AGE_LABEL_HEIGHT + DISTANCE_LABEL_HEIGHT) - 2*TOP_BOTTOM_SPACE)/2;
    self.nickLabel.frame = CGRectMake(viewWidth/2-fitWidth/2, coverImageHeight+topSpace, fitWidth, NICK_LABEL_HEIGHT);
    
    CGFloat genderX = CGRectGetMaxX(self.nickLabel.frame)+3;
    CGFloat genderY = CGRectGetMidY(self.nickLabel.frame) - GENDER_WIDTH/2;
    self.genderImage.frame = CGRectMake(genderX, genderY, GENDER_WIDTH, GENDER_WIDTH);
    
    self.ageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nickLabel.frame)+TOP_BOTTOM_SPACE, viewWidth, AGE_LABEL_HEIGHT);
    self.distancelabel.frame = CGRectMake(0, CGRectGetMaxY(self.ageLabel.frame)+TOP_BOTTOM_SPACE, viewWidth, DISTANCE_LABEL_HEIGHT);
}

- (void)changeShaowOpacity:(CGFloat)opacity{
    self.layer.shadowOpacity = opacity;
}

#pragma mark - UIRespond
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.dragBegin) {
        self.dragBegin([[touches anyObject] locationInView:self.superview]);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.dragMove) {
        self.dragMove([[touches anyObject] locationInView:self.superview]);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.dragEnd) {
        self.dragEnd([[touches anyObject] locationInView:self.superview]);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.dragEnd) {
        self.dragEnd([[touches anyObject] locationInView:self.superview]);
    }
}

@end
