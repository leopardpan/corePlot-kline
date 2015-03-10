//
//  StockKlineView.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockKlineView.h"
#import "StockPriceMovementUtil.h"
#import "Util.h"

@interface StockKlineView()

@property (nonatomic, strong) Util *util;

@end

@implementation StockKlineView

- (void)changeXYAxisWithXLen:(int)xLen dataSource:(NSArray *)dataSource
{
    
    if (!self.util) {
        self.util = [[Util alloc] init];
    }
    
    float maxValueY = 0.0f, minValueY = 0.0f;
    
    // 先循环一次datasource获得最高价和最低价
    for (NSDictionary *map in dataSource) {
        float mZGCJ = [(NSNumber *)[map objectForKey:@"high"] floatValue];
        float mZDCJ = [(NSNumber *)[map objectForKey:@"low"] floatValue];
        float mADJ = [(NSNumber *)[map objectForKey:@"adj"] floatValue];
        float max = [self.util getMaxWithNum1:mZDCJ num2:mZGCJ num3:mADJ];
        float min = [self.util getMinWithNum1:mZDCJ num2:mZGCJ num3:mADJ];
        
        if (maxValueY == 0 || max > maxValueY) {
            maxValueY = max;
        }
        if (minValueY == 0 || min < minValueY) {
            minValueY = min;
        }
    }
    
    float yStart = minValueY - 0.1 < 0 ? 0 : minValueY - 0.1;
    float yEnd = maxValueY + 0.1;
    
    NSLog(@"设置X轴和Y轴");
    CPTXYGraph *graph         = (CPTXYGraph *)super.hostingView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    // 设置y轴的长度及起点
    plotSpace.yRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(yStart) length:CPTDecimalFromCGFloat(yEnd - yStart)];
    // 设置x轴的长度及起点
    plotSpace.xRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-1) length:CPTDecimalFromInt(xLen + 1)];
    
    CPTXYAxisSet *axisSet         = (CPTXYAxisSet *)graph.axisSet;

    // 设置y轴
    CPTXYAxis *y                  = axisSet.yAxis;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(-1); // 轴位置
    y.labelingPolicy              = CPTAxisLabelingPolicyNone;
    
//    y.majorIntervalLength         = CPTDecimalFromInt(0.15);
//    y.title                       = @"单位：手";
//    y.titleOffset                 = -1;
//    y.titleRotation               = 0.01;
//    y.titleLocation               = CPTDecimalFromFloat(57.5);

    // Y轴精度
    NSNumberFormatter *yLabelFormatter = [[NSNumberFormatter alloc] init];
    [yLabelFormatter setMaximumFractionDigits:3];
    [yLabelFormatter setMinimumFractionDigits:2];
    y.labelFormatter = yLabelFormatter;
    // 绘制Y轴
    [StockPriceMovementUtil changeYAxisMajorTick:y start:yStart end:yEnd];

    // 设置x轴
    CPTXYAxis *x = axisSet.xAxis;
    // 设置x轴原点
    x.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(yStart);
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

#pragma mark 画k线和平均线
- (void)createMyPlot
{
    NSLog(@"绘制k线和平均线");
    NSMutableArray *array = super.plotArray;
    CPTXYGraph *graph = (CPTXYGraph *)super.hostingView.hostedGraph;
    
    graph.plotAreaFrame.borderColor = [UIColor lightGrayColor].CGColor;
    graph.plotAreaFrame.borderWidth = 0.5f;
    
    // 创建粗柱
    CPTBarPlot *kpPlot = [[CPTBarPlot alloc] init];
    // 设置数据源
    kpPlot.dataSource = delegate;
    kpPlot.delegate = delegate;
    // 设置柱状图的线条
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    // 阴影宽度
    borderLineStyle.lineWidth = 0.0f;
    kpPlot.lineStyle = borderLineStyle;
    // 设置柱状图的宽度
    kpPlot.barWidth = CPTDecimalFromString(@"0.8");
    // 设置柱状图的开始位置
    kpPlot.baseValue = CPTDecimalFromString(@"0");
    // 设置柱状图的底部是否可变
    kpPlot.barBasesVary = YES;
    // 设置tag
    kpPlot.identifier = kPlotKP;
    // 设置偏移
    //kpPlot.barOffset = CPTDecimalFromString(@"0.5");
    // 添加到图层
    [graph addPlot:kpPlot];
    // 添加到list中
    [array addObject:kpPlot];
    
    // 创建粗柱
    CPTBarPlot *cjPlot = [[CPTBarPlot alloc] init];
    // 设置数据源
    cjPlot.dataSource = delegate;
    cjPlot.delegate = delegate;
    // 设置柱状图的线条
    CPTMutableLineStyle *cjPlotLineStyle = [CPTMutableLineStyle lineStyle];
    cjPlotLineStyle.lineWidth = 0.0f;
    cjPlot.lineStyle = borderLineStyle;
    // 设置柱状图的宽度
    cjPlot.barWidth = CPTDecimalFromString(@"0.1");
    // 设置柱状图的开始位置
    cjPlot.baseValue = CPTDecimalFromString(@"0");
    // 设置柱状图的底部是否可变
    cjPlot.barBasesVary = YES;
    // 设置tag
    cjPlot.identifier = kPlotCJ;
    // 设置偏移
    //cjPlot.barOffset = CPTDecimalFromString(@"0.5");
    // 添加到图层
    [graph addPlot:cjPlot];
    // 添加到list中
    [array addObject:cjPlot];
    
    // 画平均线
    CPTScatterPlot *avgPricePlot = [[CPTScatterPlot alloc] init];
    avgPricePlot.identifier = kPlotAvg;
    avgPricePlot.dataSource = delegate;
    avgPricePlot.delegate = delegate;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor orangeColor];
    avgPricePlot.dataLineStyle = lineStyle;
    avgPricePlot.opacity = 1.0f;
    
    [graph addPlot:avgPricePlot];
    [array addObject:avgPricePlot];
}



@end
