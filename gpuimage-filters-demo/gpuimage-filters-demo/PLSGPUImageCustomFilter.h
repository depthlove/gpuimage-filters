//
//  PLSGPUImageCustomFilter.h
//  PLShortVideoKit
//
//  Created by suntongmian on 17/4/14.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class PLSGPUImagePicture;

@interface PLSGPUImageCustomFilter : GPUImageFilterGroup

@property (assign, nonatomic) CGImageRef currentImage;

@property (strong, nonatomic) GPUImagePicture *lookupImageSource;

@property (strong, nonatomic) NSString *colorFilterName;

@property (strong, nonatomic) NSString *colorFilterPath;

- (instancetype)initWithPath:(NSString *)colorFilterPath;

@end
