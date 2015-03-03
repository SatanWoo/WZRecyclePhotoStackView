//
//  WZPhotoStackView.m
//  iPhoto
//
//  Created by satanwoo on 14-8-16.
//  Copyright (c) 2014年 Ziqi Wu. All rights reserved.
//

#import "WZPhotoStackView.h"
#import "WZCardView.h"

@interface WZPhotoStackView()
@property (nonatomic, strong) NSMutableArray *cardPools;
@property (nonatomic, assign) NSUInteger cardPoolsUsingIndex;

@property (nonatomic, strong) WZCardView *skipPullBackCard;

@property (nonatomic, assign) CGPoint translationPoint;
@property (nonatomic, assign) WZPhotoStackStatus status;

@property (nonatomic, assign) BOOL isPanning;
@property (nonatomic, assign) BOOL isPulling;

- (void)initializeWithFrame:(CGRect)frame;
- (void)initCardView;
- (void)swapDataWithPhoto:(UIImage *)photo;

- (void)animationPhotoWithBlock:(void(^)(WZCardView *currentCard))animationBlock completion:(void(^)(WZCardView *currentCard))completionBlock;
@end

@implementation WZPhotoStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithFrame:self.bounds];
    }
    return self;
}

#pragma mark - Private
- (void)initializeWithFrame:(CGRect)frame
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanCard:)];
    [self addGestureRecognizer:panGesture];
    
    self.cardPools = [[NSMutableArray alloc] initWithCapacity:2];
    self.cardPoolsUsingIndex = 0;
    
    self.isPanning = NO;
    
    self.skipPullBackCard = [WZCardView createCardView];
    self.skipPullBackCard.hidden = YES;
    [self.skipPullBackCard setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    [self addSubview:self.skipPullBackCard];
    
    WZCardView *firstCard = [WZCardView createCardView];
    [self.cardPools addObject:firstCard];
    [firstCard setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    
    WZCardView *secondCard = [WZCardView createCardView];
    [self.cardPools addObject:secondCard];
    [secondCard setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    
    [self addSubview:secondCard];
    [self addSubview:firstCard];
    
    firstCard.hidden = YES;
    secondCard.hidden = YES;
}

- (void)initCardView
{
    if ([self.dataSource numberOfRatingPhotosInStack:self] == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishRateAllPhotosInStackView:)]) {
            [self.delegate didFinishRateAllPhotosInStackView:self];
        }
        return;
    }
    
    WZCardView *secondCard = (WZCardView *)[self.cardPools objectAtIndex:1];
    secondCard.hidden = NO;
    WZCardView *firstCard = (WZCardView *)[self.cardPools objectAtIndex:0];
    firstCard.hidden = NO;
   
    [firstCard setPhoto:[self.dataSource photoForRatingQueueInStack:self]];
    [secondCard setPhoto:[self.dataSource photoForRatingQueueInStack:self]];
}

- (void)animationPhotoWithBlock:(void (^)(WZCardView *))animationBlock completion:(void (^)(WZCardView *))completionBlock
{
    WZCardView *currentCard = self.cardPools[self.cardPoolsUsingIndex];
    [UIView animateWithDuration:.25f animations:^{
        if (animationBlock) animationBlock(currentCard);
    } completion:^(BOOL finished) {
        [self sendSubviewToBack:currentCard];
        [currentCard restoreNormalCard];
        
        if (completionBlock) completionBlock(currentCard);
        
        [self updateCards];
    }];
}

#pragma mark - Action
- (void)didPanCard:(UIPanGestureRecognizer *)pan
{
    self.translationPoint = [pan translationInView:self];

    if (pan.state == UIGestureRecognizerStateBegan) {
        self.isPanning = YES;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self convertCoordinateToStatusWithX:self.translationPoint.x withY:self.translationPoint.y];
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        self.isPanning = NO;
        [self convertCoordinateToStatusWithX:self.translationPoint.x withY:self.translationPoint.y];
    }
}

- (void)convertCoordinateToStatusWithX:(CGFloat)x withY:(CGFloat)y
{
    CGFloat ratio = CGRectGetHeight(self.frame) / CGRectGetWidth(self.frame);
    
    CGFloat offsetX = abs(x);
    CGFloat offsetY = offsetX * ratio;
    
    if (y < -offsetY) {
        [self setStatus:WZPhotoStackStatusLike];
    } else if (y >  offsetY) {
        [self setStatus:WZPhotoStackStatusHate];
    } else if (x > 0) {
        [self setStatus:WZPhotoStackStatusSkip];
    } else {
        [self setStatus:WZPhotoStackStatusPullBack];
    }
}

- (void)setStatus:(WZPhotoStackStatus)status
{
    _status = status;
    
    switch (_status) {
        case WZPhotoStackStatusLike:
            if (self.isPanning) [self animateRateStatus];
            else                [self finishLikeStatus];
            break;
        
        case WZPhotoStackStatusHate:
            if (self.isPanning) [self animateRateStatus];
            else                [self finishAverageStatus];
            break;
            
        case WZPhotoStackStatusSkip:
            if (self.isPanning) [self animateSkipStatus];
            else                [self finishSkipStatus];
            break;
            
        case WZPhotoStackStatusPullBack:
            if (self.isPanning) [self animatePullBackStatus];
            else                [self finishPullbacStatus];
            break;
            
        default:
            break;
    }
}

- (void)animateRateStatus
{
    self.isPulling = NO;
    
    WZCardView *currentCard = self.cardPools[self.cardPoolsUsingIndex];
    [currentCard moveByTranslation:self.translationPoint];
    [currentCard updateOverlay];
    [currentCard updateRotation];
}

- (void)finishLikeStatus
{
    [self animationPhotoWithBlock:^(WZCardView *currentCard){
        currentCard.center = CGPointMake([UIScreen mainScreen].bounds.size.width + currentCard.frame.size.width,
                                         -currentCard.frame.size.height);
    } completion:^(WZCardView *currentCard) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRatePhotoAsLike:inStackView:)]) {
            [self.delegate didRatePhotoAsLike:currentCard.photo inStackView:self];
        }
    }];
}

- (void)finishAverageStatus
{
    [self animationPhotoWithBlock:^(WZCardView *currentCard) {
        currentCard.center = CGPointMake(-currentCard.frame.size.width ,
                                         [UIScreen mainScreen].bounds.size.height + currentCard.frame.size.height);
    } completion:^(WZCardView *currentCard) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRatePhotoAsHate:inStackView:)]) {
            [self.delegate didRatePhotoAsHate:currentCard.photo inStackView:self];
        }
    }];
}

- (void)animateSkipStatus
{
    self.isPulling = NO;
    [self sendSubviewToBack:self.skipPullBackCard];
    [self.skipPullBackCard restoreNormalCard];
    
    WZCardView *currentCard = self.cardPools[self.cardPoolsUsingIndex];
    
    [currentCard moveByTranslation:self.translationPoint];
    [currentCard updateRotation];
}

- (void)finishSkipStatus
{
    WZCardView *currentCard = self.cardPools[self.cardPoolsUsingIndex];
    CGFloat xPos = CGRectGetMidX(self.bounds) + CGRectGetWidth(currentCard.frame);
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         currentCard.center = CGPointMake(xPos, CGRectGetMidY(self.bounds));
                     }
                     completion:^(BOOL finished){
                         [self sendSubviewToBack:currentCard];
                         [UIView animateWithDuration:0.15f animations:^{
                             [currentCard restoreNormalCard];
                         } completion:^(BOOL finished) {
                             if (self.delegate &&
                                 [self.delegate respondsToSelector:@selector(didSkipPhoto:inStackView:)]) {
                                 [self.delegate didSkipPhoto:currentCard.photo inStackView:self];
                             }
                             
                             [self updateCards];
                         }];
                     }];
}

- (void)animatePullBackStatus
{
    if (!self.isPulling) {
        if ([self.dataSource numberOfSkipPhotosInStack:self] == 0) {
            return;
        }
        
        self.isPulling = YES;
        [self.skipPullBackCard setPhoto:[self.dataSource photoForSkipQueueInStack:self]];
    }
    
    for (WZCardView *card in self.cardPools) {
        [card restoreNormalCard];
    }
    
    self.skipPullBackCard.hidden = NO;
    self.skipPullBackCard.center = CGPointMake(self.skipPullBackCard.center.x + self.translationPoint.x,
                                      self.skipPullBackCard.center.y + self.translationPoint.y);
}

- (void)finishPullbacStatus
{
    if (!self.isPulling) return;
    CGFloat xPos = CGRectGetMidX(self.bounds) - CGRectGetWidth(self.skipPullBackCard.frame);
    
    [UIView animateWithDuration:0.1
                     animations:^{
                          self.skipPullBackCard.center = CGPointMake(xPos, CGRectGetMidY(self.bounds));
                     }
                     completion:^(BOOL finished){
                         [self bringSubviewToFront: self.skipPullBackCard];
                         [UIView animateWithDuration:0.15f animations:^{
                             [self.skipPullBackCard restoreNormalCard];
                         } completion:^(BOOL finished) {
                             [self sendSubviewToBack:self.skipPullBackCard];
                             [self swapDataWithPhoto:self.skipPullBackCard.photo];
                             
                             [self.skipPullBackCard setPhoto:nil];
                             self.skipPullBackCard.hidden = YES;
                             self.isPulling = NO;
                         }];
                     }];
}

- (void)updateCards
{
    WZCardView *otherCard = self.cardPools[1 - self.cardPoolsUsingIndex];
    [self bringSubviewToFront:otherCard];
    
    WZCardView *card = self.cardPools[self.cardPoolsUsingIndex];
    [card restoreNormalCard];
    [card setPhoto:[self.dataSource photoForRatingQueueInStack:self]];
    if (card.photo == nil) {
        if (![self.dataSource canFetchMoreDataInStack:self] &&
            [self.dataSource numberOfRatingPhotosInStack:self] == 0) {
            
            if ([self.dataSource numberOfSkipPhotosInStack:self] == 0 && otherCard.photo == nil) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishRateAllPhotosInStackView:)]) {
                    [self.delegate didFinishRateAllPhotosInStackView:self];
                }
                return;
            } else {
                [self.dataSource fetchSkipPhotosInStack:self];
                [card setPhoto:[self.dataSource photoForRatingQueueInStack:self]];
            }
        }
    }
    
    self.cardPoolsUsingIndex = 1 - self.cardPoolsUsingIndex;
    
    if ([self.dataSource numberOfRatingPhotosInStack:self] <= 2 && [self.dataSource canFetchMoreDataInStack:self]) {
        [self.dataSource fetchMoreDataFromCoreDataInStack:self];
    }
}

- (void)swapDataWithPhoto:(UIImage *)photo
{
    WZCardView *otherCard = self.cardPools[1 - self.cardPoolsUsingIndex];
    WZCardView *currentCard = self.cardPools[self.cardPoolsUsingIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBringBackPhoto:inStackView:)]) {
        [self.delegate didBringBackPhoto:otherCard.photo inStackView:self];
    }
    
    [otherCard setPhoto:currentCard.photo];
    [currentCard setPhoto:photo];
}

#pragma mark - Override
- (void)setDataSource:(id<WZPhotoStackViewDataSource>)dataSource
{
    _dataSource = dataSource;
    if (dataSource == nil) return;
    [self initCardView];
}

@end
