//
//  QKZoomImageView.h
//  QKZoomImageDemo
//
//  Created by 钱凯 on 15/3/5.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QKZoomPhotoViewDelegate;

@interface QKZoomPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, assign) CGFloat kScaleProportion;

@property (nonatomic, strong) UIColor *displayBGColor;

@property (nonatomic, weak) id<QKZoomPhotoViewDelegate> zoomViewDelegate;

- (void)displayImage:(UIImage *)image;

@end

@protocol QKZoomPhotoViewDelegate <NSObject>

- (void)didCatchSignleTap:(QKZoomPhotoView *)zoomView;
- (void)didCatchDoubleTap:(QKZoomPhotoView *)zoomView;
- (void)didCatchPanMove:(QKZoomPhotoView *)zoomView BeginPoint:(CGPoint)beginPoint EndPoint:(CGPoint)endPoint InBounds:(CGRect)bounds;

@end
