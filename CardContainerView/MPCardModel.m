//
//  MPCardModel.m
//  TantanCardView
//
//  Created by MenThu on 2018/1/3.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "MPCardModel.h"

@implementation MPCardModel

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", @{@"userName":self.userName}];
}

@end
