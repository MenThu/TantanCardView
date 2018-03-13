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

@end
