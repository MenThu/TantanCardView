//
//  ThirdController.m
//  TantanCardView
//
//  Created by MenThu on 2018/1/5.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "ThirdController.h"
#import "TestNavigationController.h"

@interface ThirdController ()

@end

@implementation ThirdController

- (void)viewDidLoad{
    [super viewDidLoad];
    [TestNavigationController navigationBarMainStyle:self.navigationController.navigationBar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
