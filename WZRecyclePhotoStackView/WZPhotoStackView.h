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
- (UIImage *)photoForSkipQueueInStack:(WZPhotoStackView *)stackView;
- (UIImage *)photoForRatingQueueInStack:(WZPhotoStackView *)stackView;
- (NSUInteger)numberOfRatingPhotosInStack:(WZPhotoStackView *)stackView;
- (NSUInteger)numberOfSkipPhotosInStack:(WZPhotoStackView *)stackView;
- (BOOL)canFetchMoreDataInStack:(WZPhotoStackView *)stackView;
- (void)fetchMoreDataFromCoreDataInStack:(WZPhotoStackView *)stackView;
- (void)fetchSkipPhotosInStack:(WZPhotoStackView *)stackView;

@end

typedef NS_ENUM(NSUInteger, WZPhotoStackStatus)
{
    WZPhotoStackStatusLike = 0,
    WZPhotoStackStatusSkip = 1,
    WZPhotoStackStatusPullBack = 2,
    WZPhotoStackStatusHate = 3
};

@protocol WZPhotoStackViewDelegate <NSObject>

@optional
- (void)didSkipPhoto:(UIImage *)photo       inStackView:(WZPhotoStackView *)stackView;
- (void)didBringBackPhoto:(UIImage *)photo  inStackView:(WZPhotoStackView *)stackView;
- (void)didRatePhotoAsLike:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView;
- (void)didRatePhotoAsHate:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView;
- (void)didFinishRateAllPhotosInStackView:(WZPhotoStackView *)stackView;
@end

@interface WZPhotoStackView : UIView

@property (nonatomic, weak) id<WZPhotoStackViewDataSource> dataSource;
@property (nonatomic, weak) id<WZPhotoStackViewDelegate>   delegate;

@end
