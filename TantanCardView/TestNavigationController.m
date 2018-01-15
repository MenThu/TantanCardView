//
//  TestNavigationController.m
//  TantanCardView
//
//  Created by MenThu on 2018/1/5.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "TestNavigationController.h"

@interface TestNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation TestNavigationController

+ (void)load{
    UINavigationBar *naviBar = [UINavigationBar appearance];
    [self navigationBarMainStyle:naviBar];
}

+ (void)navigationBarMainStyle:(UINavigationBar *)navigationBar{
    NSLog(@"nabiBar=[%p]", navigationBar);
    [navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.viewControllers.count <= 1) {
        return gestureRecognizer != self.interactivePopGestureRecognizer;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
