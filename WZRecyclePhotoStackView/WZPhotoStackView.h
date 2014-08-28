//
//  WZPhotoStackView.h
//  iPhoto
//
//  Created by satanwoo on 14-8-16.
//  Copyright (c) 2014年 Ziqi Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZPhotoStackView;
@class Photo;

@protocol WZPhotoStackViewDataSource <NSObject>
@required
- (UIImage *)photoForSkipStack:(WZPhotoStackView *)stackView;
- (UIImage *)photoForRatingStack:(WZPhotoStackView *)stackView;
- (NSUInteger)numberOfRatingPhotos;
- (NSUInteger)numberOfSkipPhotos;
- (BOOL)canFetchMoreData;
- (void)fetchMoreDataFromCoreData;
- (void)fetchSkipPhotos;

@end

typedef NS_ENUM(NSUInteger, WZPhotoStackStatus)
{
    WZPhotoStackStatusLike = 0,
    WZPhotoStackStatusSkip = 1,
    WZPhotoStackStatusPullBack = 2,
    WZPhotoStackStatusAverage = 3
};

@protocol WZPhotoStackViewDelegate <NSObject>

@optional
- (void)didSkipPhoto:(UIImage *)photo;
- (void)didBringBackPhoto:(UIImage *)photo;
- (void)didRatePhotoAsLike:(UIImage *)photo;
- (void)didRatePhotoAsHate:(UIImage *)photo;
- (void)didFinishRateAllPhotos;
@end

@interface WZPhotoStackView : UIView

@property (nonatomic, weak) id<WZPhotoStackViewDataSource> dataSource;
@property (nonatomic, weak) id<WZPhotoStackViewDelegate>   delegate;

@end
