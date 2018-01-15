//
//  CardItemModel.h
//  TantanCardView
//
//  Created by MenThu on 2018/1/14.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardItemModel : NSObject

/**
 *  用户ID
 */
@property (nonatomic, assign) NSInteger userId;

/**
 *  用户头像链接
 */
@property (nonatomic, strong) NSString *avatar;

/**
 *  用户姓名
 */
@property (nonatomic, strong) NSString *userName;

/**
 *  用户性别
 */
@property (nonatomic, assign) NSInteger gender;

/**
 *  用户年龄和星座
 */
@property (nonatomic, strong) NSString *ageAndConstellation;

/**
 *  距离
 */
@property (nonatomic, strong) NSString *distance;


@end
