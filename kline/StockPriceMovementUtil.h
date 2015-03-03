//
//  StockPriceMovementUtil.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "StockBaseView.h"

@interface StockPriceMovementUtil : NSObject


// 绘制股票走势X轴
+ (void)drawPriceMovementXAxis:(CPTXYGraph *)graph stockCode:(NSString *)code;

// 根据时间获得X轴的值
+ (NSNumber *)xValueFromData:(int)data stockCode:(NSString *)code;

+ (NSString *)dataFromXValue:(int)xValue stockCode:(NSString *)code;

+ (void)drawAxisLabel:(CPTXYAxis *)axis labels:(NSDictionary *)labels textColor:(NSString *)color;

+ (void)changeYAxisMajorTick:(CPTXYAxis *)yAxis start:(CGFloat)vStart end:(CGFloat)vEnd;

@end
