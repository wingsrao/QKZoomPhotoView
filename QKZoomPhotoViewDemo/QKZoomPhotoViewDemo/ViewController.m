//
//  ViewController.m
//  QKZoomPhotoViewDemo
//
//  Created by 钱凯 on 15/3/11.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "ViewController.h"
#import "QKZoomPhotoView.h"
#import "PureLayout.h"

@interface ViewController ()<QKZoomPhotoViewDelegate>
{
    QKZoomPhotoView *zoomPhotoView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    zoomPhotoView = [[QKZoomPhotoView alloc] initWithFrame:self.view.bounds];
    zoomPhotoView.displayBGColor = [UIColor blackColor];
    zoomPhotoView.kScaleProportion = 4.0;
    [zoomPhotoView displayImage:[UIImage imageNamed:@"PhotoBoothIcon"]];
    zoomPhotoView.zoomViewDelegate = self;
    
    [self.view addSubview:zoomPhotoView];
    
    //Layout with PureLayout
    [zoomPhotoView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didCatchDoubleTap:(QKZoomPhotoView *)zoomView {
    NSLog(@"Double Tap!");
}

- (void)didCatchSignleTap:(QKZoomPhotoView *)zoomView {
    static BOOL black;
    UIColor *color;
    color = black ? [UIColor blackColor] : [UIColor whiteColor];
    [zoomPhotoView setDisplayBGColor:color];
    black = !black;
    NSLog(@"Single Tap!");
}

- (void)didCatchPanMove:(QKZoomPhotoView *)zoomView BeginPoint:(CGPoint)beginPoint EndPoint:(CGPoint)endPoint InBounds:(CGRect)bounds {
    NSLog(@"Catch Pan, Begin Point: %@, End Point: %@, in Bounds: %@",NSStringFromCGPoint(beginPoint),NSStringFromCGPoint(endPoint),NSStringFromCGRect(bounds));
}

@end
