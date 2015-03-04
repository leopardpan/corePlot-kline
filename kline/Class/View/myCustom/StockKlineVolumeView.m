//
//  StockKlineVolumeView.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockKlineVolumeView.h"
#import "StockPriceMovementUtil.h"

@implementation StockKlineVolumeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)changeXYAxisWithXLen:(int)xLen dataSource:(NSArray *)dataSource
{
    long maxVolume = 0;
    // 先循环一次datasource获得最高价和最低价
    for (NSDictionary *map in dataSource) {
        NSString *value = (NSString *)[map objectForKey:@"volume"];
        
        long long mVolume = [value longLongValue];
        if (maxVolume == 0 || maxVolume < mVolume) {
            maxVolume = mVolume;
        }
    }
    
    CPTXYGraph *graph = (CPTXYGraph *)super.hostingView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    // 设置y轴的长度及起点
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(0) length:CPTDecimalFromCGFloat(maxVolume)];
    // 设置x轴的长度及起点
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-1) length:CPTDecimalFromInt(xLen + 1)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    // 设置y轴
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromFloat(50);
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
 
    
    NSMutableDictionary *dic = [[NSMutableDictionary  alloc] init];
    NSNumberFormatter *yLabelFormatter = [[NSNumberFormatter alloc] init];
    [yLabelFormatter setMaximumFractionDigits:0];
    [yLabelFormatter setMinimumFractionDigits:0];
    y.labelFormatter = yLabelFormatter;
//    [dic setValue:@"10" forKey:@"1千万"];
    [dic setValue:@"50" forKey:@"2千万"];
    
    [StockPriceMovementUtil drawAxisLabel:y labels:dic textColor:@"#000000"];
    
    // 设置x轴
    CPTXYAxis *x = axisSet.xAxis;
    x.title = @"时间";
    x.titleOffset = 10;
    // 设置x轴原点
    x.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(0);
    x.majorIntervalLength = CPTDecimalFromInt(1);
    [self changeXLabel:x dataSource:dataSource];
}

- (void)changeXLabel:(CPTXYAxis *)xAxis dataSource:(NSArray *)dataSource
{
    NSMutableDictionary *labels = [NSMutableDictionary dictionaryWithCapacity:5];
    NSArray *indexs = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:(int)[dataSource count] - 1], nil];
  
    for (NSNumber *idx in indexs) {
        NSDictionary *infoMap = (NSDictionary *)[dataSource objectAtIndex:[idx intValue]];
        if ([idx intValue] == 0) {
            [labels setObject:[NSNumber numberWithInt:([idx intValue] + 5)] forKey:[infoMap objectForKey:@"date"]];
        } else {
            [labels setObject:[NSNumber numberWithInt:([idx intValue] - 5)] forKey:[infoMap objectForKey:@"date"]];
        }
        
    }
    [StockPriceMovementUtil drawAxisLabel:xAxis labels:labels textColor:nil];
}

- (void)createMyPlot
{
    NSMutableArray *array = super.plotArray;
    CPTXYGraph *graph = (CPTXYGraph *)super.hostingView.hostedGraph;
    
    CPTBarPlot *vPlot = [[CPTBarPlot alloc] init];
    vPlot.dataSource = delegate;
    vPlot.identifier = kPlotVolume;
    vPlot.delegate = delegate;
    // 设置柱状图的线条
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineWidth = 0.0f;
    vPlot.lineStyle = borderLineStyle;
    // 设置柱状图的宽度
    vPlot.barWidth = CPTDecimalFromString(@"0.8");
    // 设置柱状图的开始位置
    vPlot.baseValue = CPTDecimalFromString(@"0");
    // 设置柱状图的底部是否可变
    vPlot.barBasesVary = NO;
    // 添加到图层
    [graph addPlot:vPlot];
    // 添加到list中
    [array addObject:vPlot];
}
@end
