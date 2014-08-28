//
//  WZCardView.h
//  iPhoto
//
//  Created by satanwoo on 14-8-11.
//  Copyright (c) 2014年 Ziqi Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WZOverlayMode)
{
    WZOverlayModeLike = 0,
    WZOverlayModeHate = 1,
    WZOverlayModeNormal = 2
};

@interface WZCardView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *overlayImageView;

@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, assign, readonly) WZOverlayMode mode;

+ (WZCardView *)createCardView;
- (void)updateRotation;
- (void)updateOverlay;
- (void)restoreNormalCard;
- (void)moveByTranslation:(CGPoint)translation;

@end
