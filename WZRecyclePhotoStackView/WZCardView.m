//
//  WZCardView.m
//  iPhoto
//
//  Created by satanwoo on 14-8-11.
//  Copyright (c) 2014年 Ziqi Wu. All rights reserved.
//

#import "WZCardView.h"

#define WZCardViewNibName @"WZCardView"
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#define WZRatingThreshold 80

@interface WZCardView()
@property (nonatomic, assign) CGFloat startCenterX;
@property (nonatomic, assign) CGFloat startCenterY;
@property (nonatomic, assign) WZOverlayMode mode;
@end

@implementation WZCardView
+ (WZCardView *)createCardView
{
    WZCardView *view = [[[NSBundle mainBundle] loadNibNamed:WZCardViewNibName owner:self options:nil] lastObject];
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    
    self.overlayImageView.alpha = 0.0f;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    self.startCenterX = self.center.x;
    self.startCenterY = self.center.y;
}

#pragma mark - Public
- (void)updateOverlay
{
    CGFloat offsetY = self.center.y - self.startCenterY;
    if (offsetY < 0) {
        self.mode = WZOverlayModeLike;
    } else {
        self.mode = WZOverlayModeHate;
    }
    self.overlayImageView.alpha = MIN(fabsf(offsetY)/100, 0.4);
}

- (void)updateRotation
{
    CGFloat offsetX = self.center.x - self.startCenterX;
    CGFloat rotationStrength = MIN(offsetX / ROTATION_STRENGTH, ROTATION_MAX);
    CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
    CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
    CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
    
    self.transform = scaleTransform;
}

- (void)restoreNormalCard
{
    self.overlayImageView.alpha = 0.0f;
    self.center = CGPointMake(self.startCenterX, self.startCenterY);
    self.transform = CGAffineTransformMakeRotation(0);
}

- (void)moveByTranslation:(CGPoint)translation
{
    self.center = CGPointMake(self.startCenterX + translation.x, self.startCenterY + translation.y);
}

#pragma mark - Override
- (void)setMode:(WZOverlayMode)mode
{
    if (mode == WZOverlayModeHate) {
        self.overlayImageView.image = [UIImage imageNamed:@"no"];
    } else {
        self.overlayImageView.image = [UIImage imageNamed:@"yes"];
    }
}

- (void)setPhoto:(UIImage *)photo
{
    if (_photo == photo) return;
    
    _photo = photo;
    self.photoImageView.image = photo;
}
@end
