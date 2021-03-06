//
//  ViewController.m
//  TantanCardView
//
//  Created by MenThu on 2017/12/26.
//  Copyright © 2017年 MenThu. All rights reserved.
//
#define MTColor(r,g,b,a)     [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define MTRandomColor      MTColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.f)

#import "ViewController.h"
#import "MPDragController.h"
#import "CardMacro.h"
#import "TestCardView.h"

@interface ViewController ()

@property (nonatomic, weak) UIView *oneView;
@property (nonatomic, weak) UIView *twoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //计算顶部图片参数
    CGFloat cardViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat cardViewHeight = CGRectGetHeight(self.view.bounds);
    CGFloat topCardWidth = cardViewWidth * 0.8;
    CGFloat topCardHeight = cardViewHeight * 0.6;
    CGFloat topCardX = (cardViewWidth - topCardWidth)/2;
    CGFloat topCardY = (cardViewHeight - topCardHeight)/2;
    CGRect topCardFrame = CGRectMake(topCardX, topCardY, topCardWidth, topCardHeight);

    NSMutableArray <UIView *> *tempArray = @[].mutableCopy;
    for (NSInteger index = 0; index < 4; index ++) {
        TestCardView *tempView = [TestCardView loadView];
        tempView.backgroundColor = MTRandomColor;
        tempView.frame = topCardFrame;
        [self.view insertSubview:tempView atIndex:0];
        [tempArray insertObject:tempView atIndex:0];
    }

    CGFloat scale = 0.8;
    CGFloat bottomOffset = 0;
    NSInteger totalCount = tempArray.count;
    for (NSInteger index = totalCount-1; index >= 0; index --) {
        NSInteger offset = totalCount-index-1;
        CGFloat actualScale = pow(scale, offset);
        CGFloat autualBottomOffset = (topCardHeight/2 - topCardHeight/2*actualScale + offset*bottomOffset)/actualScale;
        NSLog(@"index=[%ld]  scale=[%.2f] bottomOffset=[%.2f]", (long)index, actualScale, autualBottomOffset);
        CGAffineTransform transform = CGAffineTransformMakeScale(actualScale, actualScale);
        tempArray[index].transform = CGAffineTransformTranslate(transform, 0, autualBottomOffset);
    }
}

- (IBAction)push2TantanController:(UIButton *)sender {
    MPDragController *dragController = [[MPDragController alloc] init];
    [self.navigationController pushViewController:dragController animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    MPDragController *dragController = [[MPDragController alloc] init];
    [self.navigationController pushViewController:dragController animated:YES];
}


- (void)addTransformTestView{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat originWidth = screenWidth * 0.7;
    CGFloat originHeight = screenHeight * 0.7;
    CGFloat originX = (screenWidth - originWidth)/2;
    CGFloat originY = (screenHeight - originHeight)/2;
    CGFloat bottomOffset = 10;
    CGFloat scale = 0.5;
    CGRect originFrame = CGRectMake(originX, originY, originWidth, originHeight);
    
    NSInteger temp = 0;
    for (NSInteger index = 0; index < 2; index ++) {
        UIView *testView = [UIView new];
        testView.backgroundColor = MTRandomColor;
        testView.frame = originFrame;
        CGFloat actualScale = pow(scale, temp++);
        CGFloat offset = bottomOffset*index + originHeight/2*(1-actualScale);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(actualScale, actualScale);
        NSLog(@"index=[%d] scale=[%.2f] offset=[%.2f]", (int)index, actualScale, offset);
        testView.transform = CGAffineTransformTranslate(transfrom, 0, offset);
        [self.view addSubview:testView];
    }
}

//- (void)addCardContainerView{
//    MPCardView *cardView = [[MPCardView alloc] init];
//    cardView.cardSource = @[@(1), @(1), @(1), @(1)];
//    cardView.frame = self.view.bounds;
//    [self.view addSubview:(_cardView = cardView)];
//}

/**
 *  - (void)addCardContainerView{
 __weak typeof(self) weakSelf = self;
 CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
 CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
 MPDragLikeView *drageLikeView = [[MPDragLikeView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
 self.cardContainerView = drageLikeView.cardContainerView;
 self.cardContainerView.likeOrDislike = ^(BOOL isLike, NSInteger userId) {
 if (isLike) {
 //            NSLog(@"喜欢:[%d]", (int)userId);
 }else{
 //            NSLog(@"讨厌:[%d]", (int)userId);
 }
 };
 drageLikeView.cardContainerView.nextPage = ^(NSInteger pageNo) {
 [weakSelf getCarModelWithPageIndex:pageNo];
 };
 [self.view addSubview:(_drageLikeView = drageLikeView)];
 [self getCarModelWithPageIndex:1];
 }
 
 
 - (void)getCarModelWithPageIndex:(NSInteger)pageNo{
 NSMutableArray <MPCardModel *> *cardSource = @[].mutableCopy;
 
 NSInteger pageSize = arc4random_uniform(10)+1;
 //    pageSize = 2;
 for (NSInteger index = 0; index < pageSize; index ++) {
 MPCardModel *model = [MPCardModel new];
 model.userId = pageSize*10 + index;
 model.userName = [NSString stringWithFormat:@"%d_%d", (int)pageSize, (int)index];
 model.age = [NSString stringWithFormat:@"哈哈哈哈或或或或"];
 model.distance = [NSString stringWithFormat:@"的的的为ueueue"];
 [cardSource addObject:model];
 }
 self.cardContainerView.cardSource = cardSource;
 }
 */

//- (void)addTestView{
//    self.testViewArray = @[].mutableCopy;
//    self.viewScaleArray = @[].mutableCopy;
//    self.bottomOffsetArray = @[].mutableCopy;
//    self.frameArray = @[].mutableCopy;
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    NSInteger count = 4;
//    CGFloat scale = 0.7;
//    CGFloat bottomOffset = 10;
//    CGFloat viewWidth = screenWidth * scale;
//    CGFloat viewHeight = screenHeight * scale;
//    CGFloat bottomY = 10 + viewHeight;
//    for (NSInteger index = 0; index < count; index ++) {
//        [self.viewScaleArray insertObject:@(pow(scale, index)) atIndex:0];
//        [self.bottomOffsetArray insertObject:@(bottomY + index*bottomOffset) atIndex:0];
//    }
////    NSLog(@"%@ %@", self.viewScaleArray, self.bottomOffsetArray);
//    for (NSInteger index = 0; index < count; index ++) {
//        CGFloat scaleValue = self.viewScaleArray[index].floatValue;
//        CGFloat newViewWidth = viewWidth * scaleValue;
//        CGFloat newViewHeight = viewHeight * scaleValue;
//        CGFloat viewX = screenWidth/2 - newViewWidth/2;
//        CGFloat viewY = self.bottomOffsetArray[index].floatValue - newViewHeight;
//        UIView *testView = [UIView new];
//        testView.backgroundColor = MTRandomColor;
//        testView.frame = CGRectMake(viewX, viewY, newViewWidth, newViewHeight);
//        [self.view addSubview:testView];
//        [self.testViewArray addObject:testView];
//        [self.frameArray addObject:[NSValue valueWithCGRect:testView.frame]];
//    }
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.testViewArray.lastObject removeFromSuperview];
//    [self.testViewArray removeLastObject];
//    NSInteger offset = self.frameArray.count - self.testViewArray.count;
//    [UIView animateWithDuration:0.2 animations:^{
//        for (NSInteger index = 0; index < self.testViewArray.count; index ++) {
//            UIView *testView = self.testViewArray[index];
//            testView.frame = self.frameArray[index+offset].CGRectValue;
//        }
//    }];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
