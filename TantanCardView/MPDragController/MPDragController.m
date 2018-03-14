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
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation MPDragController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.currentPage = 0;
    self.cardView.getItemView = ^CardItemView *{
        return [TestCardView loadView];
    };
    self.cardView.cardSource = [self getDataWithPage:self.currentPage];
    self.cardView.needMoreData = ^{
        if (weakSelf.currentPage < 3) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.cardView appendCardArray:[weakSelf getDataWithPage:++weakSelf.currentPage]];
            });
        }else{
            weakSelf.cardView.isNoMoreData = YES;
        }
    };
    self.cardView.allCardDataIsDone = ^{
        NSLog(@"没有更多数据了");
    };
}

- (NSMutableArray *)getDataWithPage:(NSInteger)page{
    NSMutableArray *cardSource = @[].mutableCopy;
    for (NSInteger index = 0; index < 10; index ++) {
        [cardSource addObject:[NSString stringWithFormat:@"%lld", (long long)(index + 1 + page*10)]];
    }
    return cardSource;
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
