//
//  TestCardView.m
//  TantanCardView
//
//  Created by MenThu on 2018/3/13.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "TestCardView.h"

@interface TestCardView ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation TestCardView

+ (instancetype)loadView{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].lastObject;
}

- (void)setCardModel:(id)cardModel{
    [super setCardModel:cardModel];
    NSString *string = (NSString *)cardModel;
    self.label.text = string;
}

- (void)awakeFromNib{
    [super awakeFromNib];
//    self.containerView.layer.masksToBounds = YES;
//    self.containerView.layer.cornerRadius = 4.f;
    self.layer.shadowColor = [UIColor colorWithHexString:@"000000" alpha:0.3].CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = CGSizeZero;
//    self.layer.shadowRadius = 4.f;
//    self.layer.cornerRadius = 4.f;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, -1, -1)].CGPath;
}

@end
