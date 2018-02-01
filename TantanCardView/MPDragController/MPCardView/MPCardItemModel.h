//
//  MPCardItemModel.h
//  TantanCardView
//
//  Created by MenThu on 2018/2/1.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPCardItemModel : NSObject

/**
 *  用户id
 **/
@property (nonatomic, assign) NSInteger userId;

/**
 *  背景图片
 **/
@property (nonatomic, strong) NSString *picture;

/**
 *  昵称
 **/
@property (nonatomic, strong) NSString *nick;

/**
 *  性别
 *  0 男
 *  1 女
 *  3 未知
 **/
@property (nonatomic, assign) NSInteger gender;

/**
 *  年龄
 **/
@property (nonatomic, strong) NSString *age;

/**
 *  星座
 **/
@property (nonatomic, strong) NSString *constellation;

/**
 *  距离，单位米
 **/
@property (nonatomic, strong) NSString *distance;

@end
