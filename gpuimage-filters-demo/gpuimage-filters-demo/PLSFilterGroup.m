//
//  PLSFilterGroup.m
//  PLShortVideoKitDemo
//
//  Created by suntongmian on 2017/7/4.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLSFilterGroup.h"

@interface PLSFilterGroup ()

@property (strong, nonatomic) NSMutableArray *colorFilterArray;

@end

@implementation PLSFilterGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _colorFilterArray = [[NSMutableArray alloc] init];
        _filtersInfo = [[NSMutableArray alloc] init];
        
        [self setFilterModeOn:YES];
    }
    return self;
}

- (PLSGPUImageCustomFilter *)currentFilter {
    return _colorFilterArray[_filterIndex];
}

- (NSString *)filterName {
    NSString *name = [_filtersInfo[_filterIndex] objectForKey:@"name"];
    return name;
}

- (void)setFilterModeOn:(BOOL)filterModeOn {
    [self loadFilters];
    
    if (_colorFilterArray) {
        [_colorFilterArray removeAllObjects];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < _filtersInfo.count; i++) {
            NSString *colorImagePath = [_filtersInfo[i] objectForKey:@"colorImagePath"];
            PLSGPUImageCustomFilter *filter = [[PLSGPUImageCustomFilter alloc] initWithPath:colorImagePath];
            [_colorFilterArray addObject:filter];
        }
    });
}

- (void)loadFilters {
    if (_filtersInfo) {
        [_filtersInfo removeAllObjects];
    }
    
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *filtersPath = [bundlePath stringByAppendingString:@"/PLShortVideoKit.bundle/colorFilter"];
    NSString *jsonPath = [filtersPath stringByAppendingString:@"/plsfilters.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error;
    NSDictionary *dicFromJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"load internal filters json error: %@", error);
    
    NSArray *array = [dicFromJson objectForKey:@"filters"];

    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *filter = array[i];
        NSString *name = [filter objectForKey:@"name"];
        NSString *coverImagePath = [filtersPath stringByAppendingString:[NSString stringWithFormat:@"/%@/thumb.png", name]];
        NSString *colorImagePath = [filtersPath stringByAppendingString:[NSString stringWithFormat:@"/%@/filter.png", name]];
        
        NSDictionary *dic = @{
                              @"name"            : name,
                              @"coverImagePath"  : coverImagePath,
                              @"colorImagePath"  : colorImagePath
                              };
        [_filtersInfo addObject:dic];
    }
    
}

- (void)dealloc {
    _colorFilterArray = nil;
    _filtersInfo = nil;
}

@end


