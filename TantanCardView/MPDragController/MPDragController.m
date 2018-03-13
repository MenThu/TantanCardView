//
//  MPDragController.m
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "MPDragController.h"
#import "CardView.h"
#import "TransformCardView.h"
#import "TestCardView.h"

@interface MPDragController ()

@property (weak, nonatomic) IBOutlet TransformCardView *cardView;

@end

@implementation MPDragController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardView.getItemView = ^CardItemView *{
        return [TestCardView loadView];
    };
    NSMutableArray <NSString *> *cardSource = @[].mutableCopy;
    for (NSInteger index = 0; index < 100; index ++) {
        [cardSource addObject:[NSString stringWithFormat:@"%lld", (long long)(index + 1)]];
    }
    self.cardView.cardSource = cardSource;
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
