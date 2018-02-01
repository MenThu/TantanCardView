//
//  MPDragController.m
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "MPDragController.h"
#import "CardView.h"

@interface MPDragController ()

@property (nonatomic, strong) NSMutableArray <MPCardItemModel *> *cardSource;
@property (nonatomic, weak) CardView *cardView;
@property (nonatomic, assign) NSInteger pageNo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation MPDragController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat naviBarHeight = 44;
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    self.topSpace.constant = (naviBarHeight - self.titleLabel.font.lineHeight)+statusBarHeight;
    __weak typeof(self) weakSelf = self;
    self.pageNo = 1;
    NSMutableArray <MPCardItemModel *> *tempArray = [self getCardData:self.pageNo];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CardView *cardView = [[CardView alloc] init];
    cardView.getItemView = ^MPCardItemView *{
        return [[MPCardItemView alloc] init];
    };
    cardView.nextPage = ^{
        weakSelf.cardView.cardSource = [weakSelf getCardData:++weakSelf.pageNo];
    };
    cardView.likeOrDislike = ^(BOOL isLike, NSInteger userId) {
        NSString *temp = (isLike == YES ? @"喜欢" : @"不喜欢");
        NSLog(@"%@[%ld]", temp, (long)userId);
    };
    cardView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    cardView.cardSource = tempArray;
    [self.view addSubview:(_cardView = cardView)];
}

- (NSMutableArray <MPCardItemModel *> *)getCardData:(NSInteger)page{
    NSMutableArray *tempArray = @[].mutableCopy;
    for (NSInteger index = 0; index < 5; index ++) {
        MPCardItemModel *model = [MPCardItemModel new];
        model.userId = (page-1)*10 + index+1;
        model.nick = [NSString stringWithFormat:@"这是第%ld个很长的昵称", (long)model.userId];
        model.gender = (NSInteger)arc4random_uniform(2);
        model.age = [NSString stringWithFormat:@"%ld", (long)arc4random_uniform(10000)];
        model.distance = @"距离你12.8km";
        [tempArray addObject:model];
    }
    return tempArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
