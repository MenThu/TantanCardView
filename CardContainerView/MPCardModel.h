//
//  MPCardModel.h
//  TantanCardView
//
//  Created by MenThu on 2018/1/3.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPCardModel : NSObject

/** 头像 */
@property (nonatomic, strong) NSString *coverImgUrl;
/** 姓名 */
@property (nonatomic, strong) NSString *userName;
/** 性别 */
@property (nonatomic, assign) NSInteger gender;
/** 年龄星座 */
@property (nonatomic, strong) NSString *age;
/** 距离 */
@property (nonatomic, strong) NSString *distance;
/** 用户id */
@property (nonatomic, assign) NSInteger userId;

@end
