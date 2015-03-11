
//
//  QKZoomImageView.m
//  QKZoomImageDemo
//
//  Created by 钱凯 on 15/3/5.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "QKZoomPhotoView.h"
#import "PureLayout.h"

@interface QKZoomPhotoView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation QKZoomPhotoView
{
    UIImageView *_imageView;
    CGPoint _beginPoint;
    BOOL _inTouching;
    UIPanGestureRecognizer *_panReconginzer;
}

#pragma mark - Lifecycle
#pragma mark -


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

- (void)loadView {
    _kScaleProportion = 3.5f;
    _displayBGColor = [UIColor blackColor];
    [self registerForNotifications];
}

- (void)displayImage:(UIImage *)image {
    [self clearAll];
    [self setupWithImage:image];
}

#pragma mark - Helpers
#pragma mark -

- (void)clearAll {
    
    for (UIGestureRecognizer *recognizer in _imageView.gestureRecognizers) {
        [_imageView removeGestureRecognizer:recognizer];
    }
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    _imageView = nil;
    
}

- (void)calculateToSetZoomScales {
    
    if (_imageView.frame.size.width * _imageView.frame.size.height == 0) {
        return;
    }
    
    CGFloat minScale = MIN(CGRectGetWidth(self.bounds) / CGRectGetWidth(_imageView.bounds), CGRectGetHeight(self.bounds) / CGRectGetHeight(_imageView.bounds));
    
    CGFloat maxScale = minScale * _kScaleProportion;
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
}

- (void)removePanGestureRecognizer {

}

- (void)addPanGestureRecognizer {

}

- (void)setupWithImage:(UIImage *)image {
    
    _imageView = [[UIImageView alloc] initWithImage:image];
    
    _imageView.center = self.center;
    _imageView.userInteractionEnabled = YES;
    
    self.delegate = self;
    
    [self addSubview:_imageView];
    
    self.contentSize = _imageView.frame.size;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    UITapGestureRecognizer *doubleTapReconginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _panReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMyPan:)];
    
    [doubleTapReconginzer setNumberOfTapsRequired:2];
    [tapRecognizer requireGestureRecognizerToFail:doubleTapReconginzer];
    [_panReconginzer setMaximumNumberOfTouches:1];
    
    _panReconginzer.delegate = self;
    
    [_imageView addGestureRecognizer:tapRecognizer];
    [_imageView addGestureRecognizer:doubleTapReconginzer];
    [_imageView addGestureRecognizer:_panReconginzer];
    
    [self calculateToSetZoomScales];
    
    [self setZoomScale:self.minimumZoomScale animated:NO];
}

#pragma mark - Properties
#pragma mark -

- (UIImage *)image {
    return _imageView.image;
}

- (void)setImage:(UIImage *)contentImage {
    
    _imageView.image = contentImage;
}

- (void)setDisplayBGColor:(UIColor *)displayBGColor {
    _displayBGColor = displayBGColor;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = displayBGColor;
    }];
}

- (void)setKScaleProportion:(CGFloat)kScaleProportion {
    _kScaleProportion = kScaleProportion;
    [self calculateToSetZoomScales];
}

#pragma mark - Layout
#pragma mark -

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat xPoint, yPoint;
    
    if (CGRectGetWidth(self.bounds) > self.contentSize.width) {
        xPoint = (CGRectGetWidth(self.bounds) - self.contentSize.width) / 2.0;
    } else {
        xPoint = 0.0;
    }
    
    if (CGRectGetHeight(self.bounds) > self.contentSize.height) {
        yPoint = (CGRectGetHeight(self.bounds) - self.contentSize.height) / 2.0;
    } else {
        yPoint = 0.0;
    }
    
    _imageView.frame = CGRectMake(xPoint, yPoint, CGRectGetWidth(_imageView.frame), CGRectGetHeight(_imageView.frame));
    
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat xPoint, yPoint;
    
    if (CGRectGetWidth(self.bounds) > self.contentSize.width) {
        xPoint = (CGRectGetWidth(self.bounds) - self.contentSize.width) / 2.0;
    } else {
        xPoint = 0.0;
    }
    
    if (CGRectGetHeight(self.bounds) > self.contentSize.height) {
        yPoint = (CGRectGetHeight(self.bounds) - self.contentSize.height) / 2.0;
    } else {
        yPoint = 0.0;
    }
    
    _imageView.frame = CGRectMake(xPoint, yPoint, CGRectGetWidth(_imageView.frame), CGRectGetHeight(_imageView.frame));
    
}

#pragma mark - UIGestureRecognizerDelegate
#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panReconginzer) {
        if (self.zoomScale == self.minimumZoomScale) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Actions
#pragma mark -

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (_zoomViewDelegate && [_zoomViewDelegate respondsToSelector:@selector(didCatchSignleTap:)]) {
        [_zoomViewDelegate didCatchSignleTap:self];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.zoomScale != self.minimumZoomScale) {
        
        [self setZoomScale:self.minimumZoomScale animated:YES];
        
    } else {
        
        CGPoint locationInImageView = [gestureRecognizer locationInView:_imageView];
        
        CGFloat zoomHeight = CGRectGetHeight(self.bounds) / self.maximumZoomScale;
        CGFloat zoomWidth = CGRectGetWidth(self.bounds) / self.maximumZoomScale;
        
        CGFloat x,y;
        
        x = locationInImageView.x - zoomWidth / 2.0;
        y = locationInImageView.y - zoomHeight / 2.0;
        
        if ((locationInImageView.x + zoomWidth / 2.0) > CGRectGetWidth(_imageView.bounds)) {
            x = CGRectGetWidth(_imageView.bounds) - zoomWidth;
        }
        
        if ((locationInImageView.y + zoomHeight / 2.0) > CGRectGetHeight(_imageView.bounds)) {
            y = CGRectGetHeight(_imageView.bounds) - zoomHeight;
        }
        
        if (locationInImageView.x < zoomWidth / 2.0) {
            x = 0;
        }
        
        if (locationInImageView.y < zoomHeight / 2.0) {
            y = 0;
        }
        
        [self zoomToRect:CGRectMake(x, y, MIN(zoomWidth, CGRectGetWidth(_imageView.bounds)), MIN(zoomHeight, CGRectGetHeight(_imageView.bounds))) animated:YES];
    }
    
    if (_zoomViewDelegate && [_zoomViewDelegate respondsToSelector:@selector(didCatchDoubleTap:)]) {
        [_zoomViewDelegate didCatchDoubleTap:self];
    }
}

- (void)handleMyPan:(UIPanGestureRecognizer *)panRecognizer {
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {

        if (self.zoomScale != self.minimumZoomScale) {
            _inTouching = NO;
            return;
        }
        CGPoint point = [panRecognizer locationInView:_imageView];
        if (CGRectContainsPoint(_imageView.bounds, point)) {
            _inTouching = YES;
            _beginPoint = point;
        }
        
    } else if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (!_inTouching) {
            return;
        }
        
        _inTouching = NO;
        
        CGPoint endPoint = CGPointZero;
        
        CGPoint point = [panRecognizer locationInView:_imageView];
        
        if (CGRectContainsPoint(_imageView.bounds, point)) {
            endPoint = point;
        } else if(point.y == _beginPoint.y) {
            endPoint = CGPointMake(point.x > _beginPoint.x ? CGRectGetWidth(_imageView.bounds) : 0, point.y);
        } else if (point.x == _beginPoint.x) {
            endPoint = CGPointMake(point.x, point.y > _beginPoint.y ? CGRectGetHeight(_imageView.bounds) : 0);
        } else {
            CGFloat a1 = _beginPoint.x;
            CGFloat b1 = _beginPoint.y;
            
            CGFloat a2 = point.x;
            CGFloat b2 = point.y;
            
            CGFloat X = CGRectGetWidth(_imageView.bounds);
            CGFloat Y = CGRectGetHeight(_imageView.bounds);
            
            CGFloat x1,y1,x2,y2,x3,y3,x4,y4;
            
            //Point 1
            x1 = 0;
            y1 = (x1 - a1) * (b1 - b2) / (a1 - a2) + b1;
            
            //Point 2
            x2 = X;
            y2 = (x2 - a1) * (b1 - b2) / (a1 - a2) + b1;
            
            //Point 3
            y3 = 0;
            x3 = (y3 - b1) * (a1 - a2) / (b1 -b2) + a1;
            
            //Point 4
            y4 = Y;
            x4 = (y4 - b1) * (a1 - a2) / (b1 -b2) + a1;
            
            //Choose the right point
            if ((x1 - a1) * (a2 - x1) > 0 && (y1 - b1) * (b2 - y1) > 0 &&  0 <= x1 <= X && 0 <= y1 <= Y) {
                endPoint = CGPointMake(x1, y1);
            } else if ((x2 - a1) * (a2 - x2) > 0 && (y2 - b1) * (b2 - y2) > 0 &&  0 <= x2 <= X && 0 <= y2 <= Y) {
                endPoint = CGPointMake(x2, y2);
            } else if ((x3 - a1) * (a2 - x3) > 0 && (y3 - b1) * (b2 - y3) > 0 &&  0 <= x3 <= X && 0 <= y3 <= Y) {
                endPoint = CGPointMake(x3, y3);
            } else if ((x4 - a1) * (a2 - x4) > 0 && (y4 - b1) * (b2 - y4) > 0 &&  0 <= x4 <= X && 0 <= y4 <= Y) {
                endPoint = CGPointMake(x4, y4);
            }
        }
        
        if ((endPoint.x != 0 || endPoint.y != 0) && _zoomViewDelegate && [_zoomViewDelegate respondsToSelector:@selector(didCatchPanMove:BeginPoint:EndPoint:InBounds:)]) {
            [_zoomViewDelegate didCatchPanMove:self BeginPoint:_beginPoint EndPoint:endPoint InBounds:_imageView.bounds];
        }
        
    } else if (panRecognizer.state == UIGestureRecognizerStateFailed || panRecognizer.state == UIGestureRecognizerStateCancelled) {
        _inTouching = NO;
    }
}

#pragma mark - Notifactions
#pragma mark -

- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)unregisterFromNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    
    if (_imageView) {
        
        CGFloat minScale = MIN(CGRectGetHeight(self.bounds) / CGRectGetWidth(_imageView.bounds), CGRectGetWidth(self.bounds) / CGRectGetHeight(_imageView.bounds));
        
        CGFloat maxScale = minScale * _kScaleProportion;
        
        self.maximumZoomScale = maxScale;
        self.minimumZoomScale = minScale;
        
        //if image is not full screen, update to normal size after rotation.
        BOOL notFull = CGRectGetWidth(_imageView.frame) <= CGRectGetWidth(self.bounds) || CGRectGetHeight(_imageView.frame) <= CGRectGetHeight(self.bounds);
        
        if (notFull) {
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
    }
}

@end
