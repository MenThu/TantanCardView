//
//  MPCardItemView.m
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "MPCardItemView.h"

static CGFloat const _cornerRadius = 4.f;
static CGFloat const _coverImageHeightScale = 0.65f;
static CGFloat const _nickLabelHeight = 30;

@interface MPCardItemView ()

@property (nonatomic, weak) UIView *radiusViews;//圆角视图
@property (nonatomic, weak) UIImageView *coverImage;//用户头像
@property (nonatomic, weak) UILabel *nickLabel;//用户昵称
@property (nonatomic, assign) CGFloat nickLabelWidth;
@property (nonatomic, weak) UIView *genderAgeContainer;//用户昵称
@property (nonatomic, assign) CGFloat containerLeft2NickRight;//10
@property (nonatomic, assign) CGFloat genderAgeHeight;//15
@property (nonatomic, weak) UIImageView *genderImage;
@property (nonatomic, weak) UILabel *ageLabel;
@property (nonatomic, assign) CGFloat ageLabelWidth;
@property (nonatomic, assign) CGFloat genderAgeContainerWidth;
@property (nonatomic, assign) CGSize imgSize;
@property (nonatomic, assign) CGFloat imgTitleSpace;
@property (nonatomic, weak) UILabel *distancelabel;
@property (nonatomic, assign) CGFloat distanceLabelWidth;
@property (nonatomic, assign) CGFloat distanceLabelTop2NickBottom;
@property (nonatomic, assign) BOOL isShowShadow;

@end

@implementation MPCardItemView

#pragma mark - LifeCircle
- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    __weak typeof(self) weakSelf = self;
    self.backgroundColor = [UIColor whiteColor];
    self.isShowShadow = YES;
    
    UIView *radiusViews = [[UIView alloc] init];
    radiusViews.layer.cornerRadius = _cornerRadius;
    radiusViews.layer.masksToBounds = YES;
    radiusViews.backgroundColor = [UIColor whiteColor];
    [self addSubview:(_radiusViews = radiusViews)];
    
    UIImageView *coverImage = [[UIImageView alloc] init];
    coverImage.backgroundColor = [UIColor orangeColor];
    [radiusViews addSubview:(_coverImage = coverImage)];
    
    UILabel *nickLabel = [UILabel new];
    nickLabel.textColor = [UIColor colorWithHexString:@"333333"];
    nickLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
    [radiusViews addSubview:(_nickLabel = nickLabel)];
    
    self.genderAgeHeight = 20.f;
    self.containerLeft2NickRight = 10.f;
    UIView *genderAgeContainer = [UIView new];
    genderAgeContainer.backgroundColor = [UIColor colorWithHexString:@"e27ca7"];
    genderAgeContainer.layer.cornerRadius = 4.f;
    [radiusViews addSubview:(_genderAgeContainer = genderAgeContainer)];
//    [genderAgeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(nickLabel);
//        make.left.equalTo(nickLabel.mas_right).offset(weakSelf.containerLeft2NickRight);
//        make.size.mas_equalTo(CGSizeMake(37, weakSelf.genderAgeHeight));
//    }];

    self.imgTitleSpace = 5;
    self.imgSize = CGSizeMake(9, 9);
    UIImageView *genderImage = [[UIImageView alloc] init];
    genderImage.contentMode = UIViewContentModeScaleAspectFill;
    genderImage.clipsToBounds = YES;
    [genderAgeContainer addSubview:(_genderImage = genderImage)];
//    [genderImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(weakSelf.imgSize);
//        make.centerY.equalTo(genderAgeContainer);
//        make.right.equalTo(genderAgeContainer.mas_centerX).offset(-weakSelf.imgTitleSpace/2);
//    }];

    UILabel *ageLabel = [UILabel new];
    ageLabel.textColor = [UIColor whiteColor];
    ageLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:9];
    [genderAgeContainer addSubview:(_ageLabel = ageLabel)];
//    [ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(genderAgeContainer);
//        make.left.equalTo(genderAgeContainer.mas_centerX).offset(weakSelf.imgTitleSpace/2);
//    }];

    self.distanceLabelTop2NickBottom = 10;
    UILabel *distancelabel = [UILabel new];
    distancelabel.textColor = [UIColor colorWithHexString:@"b7c4cb"];
    distancelabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    [radiusViews addSubview:(_distancelabel = distancelabel)];
//    [distancelabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(weakSelf);
//        make.top.equalTo(nickLabel.mas_bottom).offset(weakSelf.distanceLabelTop2NickBottom);
//    }];
    
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

    CGFloat leftHeight = viewHeight - coverImageHeight;
    CGFloat bottomContentHeight = self.nickLabel.font.lineHeight + self.distanceLabelTop2NickBottom + self.distancelabel.font.lineHeight;
    CGFloat labelY = (leftHeight - bottomContentHeight)/2 + coverImageHeight;

    CGFloat fitWidth = [self.nickLabel sizeThatFits:nickLabelMaxSize].width;
    CGFloat nameAndContainerWidth = fitWidth + self.containerLeft2NickRight + self.genderAgeContainerWidth;

    self.nickLabel.frame = CGRectMake(viewWidth/2-nameAndContainerWidth/2, labelY, fitWidth, _nickLabelHeight);

    CGFloat containerY = CGRectGetMidY(self.nickLabel.frame) - self.genderAgeHeight/2;
    self.genderAgeContainer.frame = CGRectMake(CGRectGetMaxX(self.nickLabel.frame)+self.containerLeft2NickRight, containerY, self.genderAgeContainerWidth, self.genderAgeHeight);
    CGFloat genderY = (self.genderAgeHeight-self.imgSize.height)/2;
    self.genderImage.frame = CGRectMake(10, genderY, self.imgSize.width, self.imgSize.height);
    CGFloat ageLabelX = CGRectGetMaxX(self.genderImage.frame)+5;
    CGFloat ageLabelY = (self.genderAgeHeight - self.ageLabel.font.lineHeight)/2;
    self.ageLabel.frame = CGRectMake(ageLabelX, ageLabelY, self.ageLabelWidth, self.ageLabel.font.lineHeight);
    CGFloat distanceLabelX = (viewWidth-self.distanceLabelWidth)/2;
    CGFloat distanceLabelY = CGRectGetMaxY(self.nickLabel.frame)+10;
    self.distancelabel.frame = CGRectMake(distanceLabelX, distanceLabelY, self.distanceLabelWidth, self.distancelabel.font.lineHeight);
}

#pragma mark - Setter
- (void)setModel:(MPCardItemModel *)model{
    _model = model;
    self.nickLabel.text = model.nick;
    self.ageLabel.text = model.age;
    self.distancelabel.text = model.distance;
    if (model.gender == 0) {
        self.genderImage.image = [UIImage imageWithColor:[UIColor blueColor]];
    }else{
        self.genderImage.image = [UIImage imageWithColor:[UIColor redColor]];
    }
    CGSize maxSize = CGSizeMake(MAXFLOAT, _nickLabelHeight);
    self.nickLabelWidth = [self.nickLabel sizeThatFits:maxSize].width;
    maxSize = CGSizeMake(MAXFLOAT, self.ageLabel.font.lineHeight);
    self.ageLabelWidth = [self.ageLabel sizeThatFits:maxSize].width;
    maxSize = CGSizeMake(MAXFLOAT, self.distancelabel.font.lineHeight);
    self.distanceLabelWidth = [self.distancelabel sizeThatFits:maxSize].width;
    self.genderAgeContainerWidth = 10+self.imgSize.width+5+self.ageLabelWidth+10;
}

- (void)showShadowOpacity:(CGFloat)opacity{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.layer.shadowOpacity = opacity;
    }];
}

@end
