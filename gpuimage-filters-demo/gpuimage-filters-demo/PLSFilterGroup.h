//
//  PLSFilterGroup.h
//  PLShortVideoKitDemo
//
//  Created by suntongmian on 2017/7/4.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLSGPUImageCustomFilter.h"

@interface PLSFilterGroup : NSObject

/**
 @abstract 所有滤镜的信息，NSDictionary 的 key 为 name，coverImagePath，colorImagePath，分别为一个滤镜的名称，封面，滤镜图片
 */
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *filtersInfo;

/**
 @abstract 当前使用的滤镜在滤镜组中的索引
 */
@property (assign, nonatomic) NSInteger filterIndex;


/**
 @abstract 当前使用的滤镜的名称
 */
@property (strong, nonatomic) NSString *filterName;

/**
 @abstract 当前使用的滤镜
 */
@property (strong, nonatomic) PLSGPUImageCustomFilter *currentFilter;

@end
