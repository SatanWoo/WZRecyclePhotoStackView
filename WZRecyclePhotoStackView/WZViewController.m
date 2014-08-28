//
//  WZViewController.m
//  WZRecyclePhotoStackView
//
//  Created by satanwoo on 14-8-28.
//  Copyright (c) 2014年 Ziqi Wu. All rights reserved.
//

#import "WZViewController.h"
#import "WZPhotoStackView.h"

const NSUInteger WZPhotoLoadCount = 10;

@interface WZViewController () <WZPhotoStackViewDataSource, WZPhotoStackViewDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *skipPhotos;
@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) WZPhotoStackView *stackView;

@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) BOOL noMoreData;

- (void)loadData;
- (void)configureCardView;
@end

@implementation WZViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.photos = [[NSMutableArray alloc] init];
        self.skipPhotos = [[NSMutableArray alloc] init];
        
        self.datas = @[@"FICDDemoImage000.jpg",
                       @"FICDDemoImage001.jpg",
                       @"FICDDemoImage002.jpg",
                       @"FICDDemoImage003.jpg",
                       @"FICDDemoImage004.jpg",
                       @"FICDDemoImage005.jpg",
                       @"FICDDemoImage006.jpg",
                       @"FICDDemoImage007.jpg",
                       @"FICDDemoImage008.jpg",
                       @"FICDDemoImage009.jpg",
                       @"FICDDemoImage010.jpg",
                       @"FICDDemoImage011.jpg",
                       @"FICDDemoImage012.jpg",
                       @"FICDDemoImage013.jpg",
                       @"FICDDemoImage014.jpg",
                       @"FICDDemoImage015.jpg",
                       @"FICDDemoImage016.jpg",
                       ];
        
        self.offset = 0;
        self.noMoreData = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
    [self configureCardView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private
- (void)configureCardView
{
    self.stackView = [[WZPhotoStackView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        CGRectGetWidth(self.view.frame),
                                                                        CGRectGetHeight(self.view.frame))];
    
    [self.view addSubview:self.stackView];
    
    self.stackView.delegate = self;
    self.stackView.dataSource = self;
}

- (void)loadData
{
    NSUInteger threshold =
    [self.datas count] - self.offset < WZPhotoLoadCount? [self.datas count] : self.offset + WZPhotoLoadCount;
    
    NSUInteger loadedCount = threshold - self.offset;
    
    for (int i = self.offset; i < threshold; i++) {
        @autoreleasepool {
            NSString *imgName = self.datas[i];
            UIImage *image = [UIImage imageNamed:imgName];
            [self.photos addObject:image];
        }
    }
    
    if (loadedCount < WZPhotoLoadCount) self.noMoreData = YES;
    self.offset += loadedCount;
}

#pragma mark - WZPhotoStackViewDataSource
- (UIImage *)photoForSkipQueueInStack:(WZPhotoStackView *)stackView
{
    if ([self.skipPhotos count] == 0) return nil;
    
    UIImage *skipPhoto = [self.skipPhotos lastObject];
    [self.skipPhotos removeObject:skipPhoto];
    return skipPhoto;
}

- (UIImage *)photoForRatingQueueInStack:(WZPhotoStackView *)stackView
{
    if ([self.photos count] == 0) return nil;
    
    UIImage *photo = [self.photos firstObject];
    [self.photos removeObject:photo];
    return photo;
}

- (NSUInteger)numberOfRatingPhotosInStack:(WZPhotoStackView *)stackView
{
    return [self.photos count];
}

- (NSUInteger)numberOfSkipPhotosInStack:(WZPhotoStackView *)stackView
{
    return [self.skipPhotos count];
}

- (BOOL)canFetchMoreDataInStack:(WZPhotoStackView *)stackView
{
    return !self.noMoreData;
}

- (void)fetchMoreDataFromCoreDataInStack:(WZPhotoStackView *)stackView
{
    NSLog(@"refill the photos");
    [self loadData];
}

- (void)fetchSkipPhotosInStack:(WZPhotoStackView *)stackView
{
    if ([self.skipPhotos count] != 0) {
        [self.photos addObjectsFromArray:self.skipPhotos];
        [self.skipPhotos removeAllObjects];
    }
}

#pragma mark - WZPhotoStackViewDelegate
- (void)didSkipPhoto:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView
{
    NSLog(@"skip photos");
    [self.skipPhotos addObject:photo];
}

- (void)didBringBackPhoto:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView
{
    if (photo == nil) return;
    [self.photos insertObject:photo atIndex:0];
}

- (void)didRatePhotoAsLike:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView
{
    NSLog(@"haha you like it");
}

- (void)didRatePhotoAsHate:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView
{
    NSLog(@"woops you hate it");
}

- (void)didFinishRateAllPhotosInStackView:(WZPhotoStackView *)stackView
{
    self.stackView.hidden = YES;
    NSLog(@"You have finish photo stack");
}

@end
