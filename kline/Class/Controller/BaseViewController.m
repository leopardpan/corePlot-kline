//
//  BaseViewController.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController



#pragma mark -
#pragma mark 初始化方法
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // 初始化map
        stockBaseViewMap = [NSMutableDictionary dictionaryWithCapacity:1];
        dataSource = [NSMutableArray arrayWithCapacity:10];
        showDataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

#pragma mark -
#pragma mark 覆写UIViewController方法
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark -
#pragma mark KDVIEWStockBaseViewDelegate
- (int)xAxisLen
{
    return xAxisLen;
}

- (NSArray *)showDataSource
{
    return showDataSource;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [showDataSource count];
}

#pragma mark -
#pragma mark 事件处理方法
/*
 拖动事件
 1.如果当前在显示十字线，则获得当前手指所在的点，调用绘图方法更新十字线位置；
 2.如果当前不显示十字线，则获得移动的距离，重新获取数据源；
 */
- (void)whenPanEvent:(UIPanGestureRecognizer *)sender tag:(NSString *)tag
{
    if (showCrossLine) {
        [self showCrossLine:sender tag:tag];
    } else {
        if (loadingData) {
            return;
        }
        StockBaseView *view = [stockBaseViewMap objectForKey:tag];
        CGPoint point = [sender translationInView:view.crossView];
       
        CGFloat panCount = panOffset + point.x;
        [self loadDataByPan:panCount tag:tag];
        NSLog(@"pancount                  =============            %f",panOffset);
        if (sender.state  == UIGestureRecognizerStateEnded) {

            panOffset = panOffset + point.x;

        }
    }
}
/*
 点击事件
 1.如果当前在显示十字线，则隐藏十字线；
 2.如果当前不显示十字线，则获得点击的点，绘制十字线；
 */
- (void)whenTapEvent:(UITapGestureRecognizer *)sender tag:(NSString *)tag
{
    if (showCrossLine) {
        [self hideCrossLine];
        showCrossLine = NO;
    } else {
        [self showCrossLine:sender tag:tag];
        showCrossLine = YES;
    }
}
/*
 放大、缩小事件
 1.如果当前在显示十字线，则不处理；
 2.如果当前不显示十字线，如果在获取数据中，则不处理，否则，重新获取数据源
 */
- (void)whenPinchEvent:(UIPinchGestureRecognizer *)sender tag:(NSString *)tag
{
    
    if (showCrossLine) {
        return;
    } else {
        if (loadingData) {
            return;
        } else {
            if (sender.state == UIGestureRecognizerStateEnded) {
                [self loadDataByPinch:sender.scale tag:tag];
            }
        }
    }
}
#pragma mark -
#pragma mark 自定义方法
/*
 绘制十字线
 首先获得手势在crossview的点crosspoint，将crosspoint转成coreplot graph中的点
 获得数据，根据数据获得显示信息，最后绘制十字线及显示信息
 */
- (void)showCrossLine:(UIGestureRecognizer *)sender tag:(NSString *)tag
{
    StockBaseView *view = [stockBaseViewMap objectForKey:tag];
    CGPoint point = [sender locationInView:view.crossView];
    // 处理x,y
    CGFloat minX = view.hostingView.stockPadding.left;
    CGFloat maxX = view.hostingView.frame.size.width - view.hostingView.stockPadding.right;
    point.x = point.x < minX ? minX : point.x;
    point.x = point.x > maxX ? maxX : point.x;
    // 此处将x转成整数
    point.x = (int) point.x;
    //    if (point.x > [dataSource count]) {
    //        point.x = [dataSource count] - 1;
    //    }
    
    CGFloat minY = view.hostingView.stockPadding.top;
    CGFloat maxY = view.hostingView.frame.size.height - view.hostingView.stockPadding.bottom;
    point.y = point.y < minY ? minY : point.y;
    point.y = point.y > maxY ? maxY : point.y;
    
    // 将crossview的坐标转成graph的坐标
    CGPoint graphPoint = CGPointMake(point.x, view.hostingView.frame.size.height - point.y);
    CGPoint pointInPlotArea = [view.hostingView.hostedGraph convertPoint:graphPoint toLayer:view.hostingView.hostedGraph.plotAreaFrame];
    NSDecimal dataPoint[2];
    [view.hostingView.hostedGraph.defaultPlotSpace plotPoint:dataPoint forPlotAreaViewPoint:pointInPlotArea];
    
    
    NSMutableDictionary *arroundValueMap = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSUInteger idx = CPTDecimalUnsignedIntValue(dataPoint[CPTCoordinateX]);
    if (idx == NSNotFound) {
        idx = 0;
    }
    NSObject *obj = nil;
    if (idx < [showDataSource count]) {
        obj = [showDataSource objectAtIndex:idx];
    }
    
    NSString *yValue = [NSString stringWithFormat:@"%.2f", CPTDecimalFloatValue(dataPoint[CPTCoordinateY])];
    [arroundValueMap setObject:yValue forKey:TAG_LEFT];
    if (obj) {
        [arroundValueMap setObject:[self showValueWithType:TAG_TOP :obj] forKey:TAG_TOP];
        [arroundValueMap setObject:[self showValueWithType:TAG_BOTTOM :obj] forKey:TAG_BOTTOM];
        [arroundValueMap setObject:[self showValueWithType:TAG_RIGHT :obj] forKey:TAG_RIGHT];
    }
    
    for (NSString *tag in [stockBaseViewMap allKeys]) {
        
        StockBaseView *baseView = [stockBaseViewMap objectForKey:tag];
        [baseView drawCrossLine:point info:arroundValueMap];
    }
}
// 隐藏十字线
- (void)hideCrossLine
{
    for (NSString *tag in [stockBaseViewMap allKeys]) {
        StockBaseView *baseView = [stockBaseViewMap objectForKey:tag];
        [baseView hideCrossLine];
    }
}
- (void)dataSourceChange
{
    [self checkShowRange];
    [showDataSource removeAllObjects];
    [showDataSource addObjectsFromArray:[dataSource subarrayWithRange:showRange]];
    
    if ([stockBaseViewMap isKindOfClass:[NSDictionary class]]) {
        for (NSString *tag in [stockBaseViewMap allKeys]) {
            
            if (tag.length > 0) {
                StockBaseView *baseView = [stockBaseViewMap objectForKey:tag];
                
                [baseView dataSourceChanged];
            }
            
        }
        
    }
    
    
}

- (void)checkShowRange
{
    int location = (int)showRange.location;
    int len = showRange.length = xAxisLen;
    int count = (int)[dataSource count];
    if (location > [dataSource count] - 1) {
        showRange.location = count - xAxisLen < 0 ? 0 : [dataSource count] - xAxisLen - 1;
    }
    if (location + len > count) {
        showRange.length = count - location;
    }
    NSLog(@"location = %lu    lenght = %lu  count = %lu  xAxisLen = %d", (unsigned long)showRange.location,(unsigned long)showRange.length,(unsigned long)dataSource.count,xAxisLen);
}


@end
