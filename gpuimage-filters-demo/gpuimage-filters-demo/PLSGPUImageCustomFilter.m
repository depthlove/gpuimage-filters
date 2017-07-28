//
//  PLSGPUImageCustomFilter.m
//  PLShortVideoKit
//
//  Created by suntongmian on 17/4/14.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLSGPUImageCustomFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation PLSGPUImageCustomFilter

- (instancetype)initWithPath:(NSString *)colorFilterPath {
    self = [super init];
    if (self) {
        self.colorFilterPath = colorFilterPath;
        UIImage *image = [UIImage imageWithContentsOfFile:colorFilterPath];
        
        self.currentImage = [image CGImage];
        NSAssert(self.currentImage, @"To use PLSGPUImageLookupFilter you need to add %@ from PLSGPUImage/framework/Resources to your application bundle.", colorFilterPath);
        
        self.lookupImageSource = [[GPUImagePicture alloc] initWithCGImage:self.currentImage];
        GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
        [self addFilter:lookupFilter];
        
        [self.lookupImageSource addTarget:lookupFilter atTextureLocation:1];
        [self.lookupImageSource processImage];
        
        self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
        self.terminalFilter = lookupFilter;
    }
    return self;
}

- (void)dealloc {
    self.lookupImageSource = nil;
    
//    CGImageRelease(self.currentImage);
    self.currentImage = nil;
}

@end
