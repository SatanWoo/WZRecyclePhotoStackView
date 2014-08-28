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
- (UIImage *)photoForSkipStack:(WZPhotoStackView *)stackView
{
    if ([self.skipPhotos count] == 0) return nil;
    
    UIImage *skipPhoto = [self.skipPhotos lastObject];
    [self.skipPhotos removeObject:skipPhoto];
    return skipPhoto;
}

- (UIImage *)photoForRatingStack:(WZPhotoStackView *)stackView
{
    if ([self.photos count] == 0) return nil;
    
    UIImage *photo = [self.photos firstObject];
    [self.photos removeObject:photo];
    return photo;
}

- (NSUInteger)numberOfRatingPhotos
{
    return [self.photos count];
}

- (NSUInteger)numberOfSkipPhotos
{
    return [self.skipPhotos count];
}

- (BOOL)canFetchMoreData
{
    return !self.noMoreData;
}

- (void)fetchMoreDataFromCoreData
{
    NSLog(@"refill the photos");
    [self loadData];
}

- (void)fetchSkipPhotos
{
    if ([self.skipPhotos count] != 0) {
        [self.photos addObjectsFromArray:self.skipPhotos];
        [self.skipPhotos removeAllObjects];
    }
}

#pragma mark - WZPhotoStackViewDelegate
- (void)didSkipPhoto:(UIImage *)photo
{
    NSLog(@"skip photos");
    [self.skipPhotos addObject:photo];
}

- (void)didBringBackPhoto:(UIImage *)photo
{
    if (photo == nil) return;
    [self.photos insertObject:photo atIndex:0];
}

- (void)didRatePhotoAsLike:(UIImage *)photo
{
    NSLog(@"haha you like it");
}

- (void)didRatePhotoAsHate:(UIImage *)photo
{
    NSLog(@"woops you hate it");
}

- (void)didFinishRateAllPhotos
{
    self.stackView.hidden = YES;
    NSLog(@"You have finish photo stack");
}

@end
