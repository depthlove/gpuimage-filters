//
//  ViewController.m
//  gpuimage-filters-demo
//
//  Created by suntongmian on 2017/7/27.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLSEditVideoCell.h"
#import "PLSFilterGroup.h"

/**
 * some resources from https://github.com/pili-engineering/PLShortVideoKit
 */

#define PLS_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define PLS_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

@interface ViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (strong, nonatomic) PLSFilterGroup *filterGroup;
@property (strong, nonatomic) UICollectionView *editVideoCollectionView;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *filtersArray;
@property (assign, nonatomic) NSInteger filterIndex;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *imageNamePath;
@property (strong, nonatomic) UIButton *saveAllFilterImagesButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // ...
    self.view.backgroundColor = [UIColor grayColor];
    
    // ...
    self.imageName = @"liqin";
    self.image = [UIImage imageNamed:self.imageName];
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.frame = CGRectMake(0, 20, PLS_SCREEN_WIDTH, PLS_SCREEN_WIDTH);
    [self.view addSubview:self.imageView];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.imageName];
    self.imageNamePath = path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // ...
    self.saveAllFilterImagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveAllFilterImagesButton.frame = CGRectMake(PLS_SCREEN_WIDTH - 180, PLS_SCREEN_WIDTH + 30, 160, 45);
    [self.saveAllFilterImagesButton setTitle:@"save all" forState:UIControlStateNormal];
    [self.saveAllFilterImagesButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.saveAllFilterImagesButton];
    [self.saveAllFilterImagesButton addTarget:self action:@selector(saveAllFilterImagesButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    // ...
    self.filterGroup = [[PLSFilterGroup alloc] init];

    // ...
    self.filtersArray = [[NSMutableArray alloc] init];
    for (NSDictionary *filterInfoDic in self.filterGroup.filtersInfo) {
        NSString *name = [filterInfoDic objectForKey:@"name"];
        NSString *colorImagePath = [filterInfoDic objectForKey:@"colorImagePath"];
        
        NSDictionary *dic = @{
                              @"name"            : name,
                              @"colorImagePath"  : colorImagePath
                              };
        
        [self.filtersArray addObject:dic];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(50, 65);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    _editVideoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, PLS_SCREEN_WIDTH, layout.itemSize.height) collectionViewLayout:layout];
    _editVideoCollectionView.backgroundColor = [UIColor clearColor];
    _editVideoCollectionView.showsHorizontalScrollIndicator = NO;
    _editVideoCollectionView.showsVerticalScrollIndicator = NO;
    [_editVideoCollectionView setExclusiveTouch:YES];
    [_editVideoCollectionView registerClass:[PLSEditVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([PLSEditVideoCell class])];
    _editVideoCollectionView.delegate = self;
    _editVideoCollectionView.dataSource = self;
    self.editVideoCollectionView.frame = CGRectMake(0, PLS_SCREEN_HEIGHT - _editVideoCollectionView.frame.size.height - 20, _editVideoCollectionView.frame.size.width, _editVideoCollectionView.frame.size.height);
    [self.view addSubview:self.editVideoCollectionView];
    [self.editVideoCollectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filtersArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLSEditVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PLSEditVideoCell class]) forIndexPath:indexPath];
    
    NSDictionary *filterInfoDic = self.filtersArray[indexPath.row];
    
    NSString *name = [filterInfoDic objectForKey:@"name"];
    NSString *colorImagePath = [filterInfoDic objectForKey:@"colorImagePath"];
    
    cell.iconPromptLabel.text = name;
    cell.iconImageView.image = [UIImage imageWithContentsOfFile:colorImagePath];
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.filterGroup.filterIndex = indexPath.row;
    
    [self refreshFilterImage];
}

- (void)refreshFilterImage {
    UIImage *outputImage = [self applyFilter:self.image];
   
    self.imageView.image = outputImage;
}

- (UIImage *)applyFilter:(UIImage *)inputImage {
    PLSGPUImageCustomFilter *filter = self.filterGroup.currentFilter;

    UIImage *outputImage;
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    [stillImageSource addTarget:filter atTextureLocation:0];
    [filter useNextFrameForImageCapture];
    if([filter.lookupImageSource processImageWithCompletionHandler:nil] && [stillImageSource processImageWithCompletionHandler:nil]) {
        outputImage = [filter imageFromCurrentFramebuffer];
    }
    
    return outputImage;
}

#pragma mark -
- (void)saveAllFilterImagesButtonEvent:(id)sender {
    NSString *filterName;
    UIImage *outputImage;
    
    NSLog(@"start to filter image...");

    for (NSInteger filterIndex = 0; filterIndex < self.filterGroup.filtersInfo.count; filterIndex++) {
        self.filterGroup.filterIndex = filterIndex;
        filterName = self.filterGroup.filterName;

        outputImage = [self applyFilter:self.image];
        
        [self saveImage:outputImage filterName:filterName];
    }
    
    NSLog(@"save all filter image success.");
}

- (void)saveImage:(UIImage *)image filterName:(NSString *)filterName {
    NSString *path = [self.imageNamePath stringByAppendingPathComponent:filterName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // output png
    NSString *pngPath = [path stringByAppendingPathComponent:@"thumb.png"];
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    
//    // output jpg
//    NSString  *jpgPath = [path stringByAppendingPathComponent:@"thumb.png"];
//    // Write a UIImage to JPEG with minimum compression (best quality)
//    // The value 'image' must be a UIImage object
//    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
//    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
}

#pragma mark -- limit orientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -- hide status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
