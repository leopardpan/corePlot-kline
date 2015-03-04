//
//  CorePlotKlineViewController.m
//  kline
//
//  Created by leopard on 15-3-4.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "CorePlotKlineViewController.h"
#import "PlotItem.h"
#import "OHLCPlot.h"

@interface CorePlotKlineViewController()

@property (strong, nonatomic) OHLCPlot *ohlCPlot;

@end

@implementation CorePlotKlineViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    OHLCPlot *oh = [[OHLCPlot alloc] init];
    self.ohlCPlot = oh;
    
    [self setupView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.view addGestureRecognizer:pan];
}

- (void)panGesture:(UIPanGestureRecognizer *)pan
{
    CGPoint panOffset = [pan translationInView:self.view];
    NSLog(@"panOffset =  %f",panOffset.x);
    self.ohlCPlot.panOffset = panOffset.x;
    
//    [self setupView];

}
-(void)setupView
{
    
    [self.ohlCPlot renderInView:self.view withTheme:[CPTTheme themeNamed:nil] animated:YES];
}
#pragma mark -
#pragma mark Managing the detail item

-(void)setDetailItem:(PlotItem *)newDetailItem
{
    
    NSLog(@"PlotItem = %@",newDetailItem);
    
}
@end
