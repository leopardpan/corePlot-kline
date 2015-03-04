//
//  StockPriceMovementUtil.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockPriceMovementUtil.h"
#import "UIColor+Style.h"

#define DEFAULT_NUM 6

@implementation StockPriceMovementUtil
// 绘制股票走势X轴
+ (void) drawPriceMovementXAxis:(CPTXYGraph *)graph stockCode:(NSString *)code
{
    
    MarketID marketId = EM_MARKET_ID_SH;
    
    CGFloat xLength = 0;
    NSMutableDictionary *mapTimeInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (EM_MARKET_ID_FT_CFFEX == marketId) {
        // 股指期货 开市时间:9:15-11:30 13:00-15:15
        [mapTimeInfo setObject:[NSNumber numberWithInt:15] forKey:@"9:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:75] forKey:@"10:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:135] forKey:@"11:30/13:00"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:195] forKey:@"14:00"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:255] forKey:@"15:00"];
        xLength = 255;
    } else if (EM_MARKET_ID_FT_MIN < marketId && marketId < EM_MARKET_ID_FT_MAX) {
        // 大连/郑州/上海期货 开市时间:9:00-10:15 10:30-11:30 13:30-15:00
        [mapTimeInfo setObject:[NSNumber numberWithInt:0] forKey:@"9:00"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:90] forKey:@"10:15/10:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:150] forKey:@"11:30/13:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:210] forKey:@"14:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:270] forKey:@"15:00"];
        xLength = 270;
    } else {
        // 开市时间：9:30-11:30/13:00-15:00
        [mapTimeInfo setObject:[NSNumber numberWithInt:0] forKey:@"9:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:60] forKey:@"10:30"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:120] forKey:@"11:30/13:00"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:180] forKey:@"14:00"];
        [mapTimeInfo setObject:[NSNumber numberWithInt:240] forKey:@"15:00"];
        xLength = 240;
    }
    
    // 设置plotSpace
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(xLength)];
    // 设置X轴
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPTDecimalFromString(@"60");
    x.title = nil;
    
    [self drawAxisLabel:x labels:mapTimeInfo textColor:nil];
}

// 根据时间获得X轴的值
+ (NSNumber *) xValueFromData:(int)data stockCode:(NSString *)code
{
    NSNumber *num = nil;
    MarketID marketId = EM_MARKET_ID_SH;
    
    if (EM_MARKET_ID_FT_CFFEX == marketId) {
        // 股指期货 开市时间:9:15-11:30 13:00-15:15
        if (data >= 130000) {
            int timeDiff = data - 130000;
            return [NSNumber numberWithInt:(timeDiff / 10000 * 60 + timeDiff % 10000 / 100 + 135)];
        } else {
            int timeDiff = data - 91500;
            return [NSNumber numberWithInt:timeDiff / 10000 * 60 + timeDiff % 10000 / 100];
        }
        
    } else if (EM_MARKET_ID_FT_MIN < marketId && marketId < EM_MARKET_ID_FT_MAX) {
        // 大连/郑州/上海期货 开市时间:9:00-10:15 10:30-11:30 13:30-15:00
        if (data <= 101500) {
            int timeDiff = data - 90000;
            return [NSNumber numberWithInt:(timeDiff / 10000 * 60 + timeDiff % 10000 / 100 + 120)];
        } else if (data <= 113000){
            int timeDiff = data - 103000;
            return [NSNumber numberWithInt:(timeDiff / 10000 * 60 + timeDiff % 10000 / 100 + 75)];
        } else {
            int timeDiff = data - 133000;
            return [NSNumber numberWithInt:(timeDiff / 10000 * 60 + timeDiff % 10000 / 100 + 135)];
        }
    } else {
        // 开市时间：9:30-11:30/13:00-15:00
        if (data >= 130000) {
            int timeDiff = (data / 10000 - (130000 / 10000)) * 60 + (data % 10000 / 100) + 120;
            num = [NSNumber numberWithInt:timeDiff];
        } else {
            int timeDiff = (data / 10000 - (93000 / 10000)) * 60 + ((data % 10000 / 100) - (93000 % 10000 / 100));
            num = [NSNumber numberWithInt:timeDiff];
        }
    }
    return num;
}

+ (NSString *) dataFromXValue:(int)xValue stockCode:(NSString *)code
{
    MarketID marketId = EM_MARKET_ID_SH;
    if (EM_MARKET_ID_FT_CFFEX == marketId) {
        
    } else if (EM_MARKET_ID_FT_MIN < marketId && marketId < EM_MARKET_ID_FT_MAX) {
        
    } else {
        
    }
    return nil;
}

#pragma mark - 绘制x轴
+ (void)drawAxisLabel:(CPTXYAxis *)axis labels:(NSDictionary *)labels textColor:(NSString *)color
{
    axis.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[labels count]];
    for (NSObject *key in [labels allKeys]) {
        NSNumber *location = [labels objectForKey:key];
        CPTMutableTextStyle *textStyle = [axis.labelTextStyle mutableCopy];
        UIColor *textColor = [UIColor whiteColor];
        if (color) {
            textColor = [UIColor colorWithHexString:color];
        }
        textStyle.color = [CPTColor colorWithCGColor:textColor.CGColor];
        NSString *text = nil;
        if ([key isKindOfClass:[NSNumber class]]) {
            text = [(NSNumber *)key stringValue];
        }  else {
            text = (NSString *)key;
        }
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:text textStyle:textStyle];
        label.tickLocation = CPTDecimalFromInt([location intValue]);
     
        // 离x轴的偏移量
        label.offset = 10.0f;
        //        label.rotation = 0.5;
        [customLabels addObject:label];
    }
    axis.axisLabels =  [NSSet setWithArray:customLabels];
}
+ (void)changeYAxisMajorTick:(CPTXYAxis *)yAxis start:(CGFloat)vStart end:(CGFloat)vEnd
{
    int num = DEFAULT_NUM;
    float len = (vEnd - vStart) / num;
    NSMutableSet *majorTicks = [NSMutableSet setWithCapacity:num];
    for (int i = 0 ; i <= num ; i++) {
        float fLen = vStart + i * len;
        fLen = [[NSString stringWithFormat:@"%.2f", fLen] floatValue];
        [majorTicks addObject:[NSNumber numberWithFloat:fLen]];
    }
    yAxis.majorTickLocations = majorTicks;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyLocationsProvided;
}
@end
