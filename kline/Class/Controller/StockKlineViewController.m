//
//  StockKlineViewController.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockKlineViewController.h"
#import "StockHeard.h"
#import "UIColor+Style.h"

// view默认宽度
#define k_screen_width [[UIScreen mainScreen] bounds].size.width
#define DEFAULT_SCALE_LEN 25
#define DEFAULT_MAX_SCALE 4

#define SCROLL_SPEED 5

@interface StockKlineViewController ()

@end

@implementation StockKlineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    
    return [self init];
}

- (id)init
{
    self = [super init];
    if (self) {
        xAxisLen = 150;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#515151"];
    
    StockPadding uiviewPadding = {50,0,30,10};
    StockDrawInfo uiview1DrawInfo = {YES,YES,YES,NO,YES};
    StockGesture uiview1Gesture = {YES,YES,YES};
    
    // k线图
    StockKlineView *uiview1 = [[StockKlineView alloc] initWithFrame:CGRectMake(0, 20, k_screen_width, 350) tag:@"kline" padding:uiviewPadding drawInfo:uiview1DrawInfo gesture:uiview1Gesture delegate:self isKline:YES];
    uiview1.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    
    [stockBaseViewMap setObject:uiview1 forKey:@"kline"];
    StockDrawInfo uiview2DrawInfo = {NO,NO,NO,YES,NO};
    StockGesture uiview2Gesture = {NO, NO, NO};
    
    // 成交量图
    StockKlineVolumeView *uiview2 = [[StockKlineVolumeView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(uiview1.frame)+20, k_screen_width, 150) tag:@"kline" padding:uiviewPadding drawInfo:uiview2DrawInfo gesture:uiview2Gesture delegate:self isKline:NO];
    //     uiview2.backgroundColor = [UIColor colorWithHexString:@"#B7B7B7"];
    
    [stockBaseViewMap setObject:uiview2 forKey:@"volume"];
    NSArray *array = [[StockKlineData new] loadStockTestData];
    
    dataSource = [array mutableCopy];
    
    showRange.location = 0;
    [self dataSourceChange];
    
    [self.view addSubview:uiview1];
    [self.view addSubview:uiview2];
}

// 返回十字架上的lable
- (NSString *)showValueWithType:(NSString *)type :(NSObject *)obj
{
    NSDictionary *infoMap = (NSDictionary *)obj;
    if ([type isEqualToString:TAG_TOP]) {
        return [NSString stringWithFormat:@"  日期：%i 开：%.2f 高：%.2f 低：%.2f 收：%.2f 成交量：%lli",
                [[infoMap objectForKey:@"DATA"] intValue]
                , [(NSNumber *)[infoMap objectForKey:@"OPEN"] floatValue]
                , [(NSNumber *)[infoMap objectForKey:@"HIGH"] floatValue]
                , [(NSNumber *)[infoMap objectForKey:@"LOW"] floatValue]
                , [(NSNumber *)[infoMap objectForKey:@"CLOSE"] floatValue]
                , [[infoMap objectForKey:@"VOLUME"] longLongValue]];
    } else if ([type isEqualToString:TAG_LEFT]) {
        return @"";
    } else if ([type isEqualToString:TAG_BOTTOM]) {
        
        return [infoMap objectForKey:@"DATA"];
    } else if ([type isEqualToString:TAG_RIGHT]) {
        return @"";
    }
    return @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 拖拽手势
- (void)loadDataByPan:(CGFloat)len tag:(NSString *)tag
{
    NSLog(@"\n\t\t\t\t\t\tlen = %f\n",len);
    loadingData = YES;
    if (len > 0) {
        // 右移, 向后取数据
        if (showRange.location == 0) {
            loadingData = NO;
        } else {
            //            showRange.location = showRange.location < SCROLL_SPEED ? 0 : showRange.location - SCROLL_SPEED;
            showRange.location = len/SCROLL_SPEED;
            [self dataSourceChange];
            loadingData = NO;
        }
    } else {
        //        int mLocation = (int)showRange.location + SCROLL_SPEED;
        //        showRange.location = mLocation >= [dataSource count] ? [dataSource count] - SCROLL_SPEED : mLocation;
        showRange.location = -len/SCROLL_SPEED;
        [self dataSourceChange];
        loadingData = NO;
    }
}

#pragma mark - 缩放手势
- (void)loadDataByPinch:(CGFloat)scale tag:(NSString *)tag
{
    xAxisLen = (1/scale)*xAxisLen;
    if (xAxisLen > 700) {
        xAxisLen = 700;
    }else if (xAxisLen < 20){
        xAxisLen =  20;
    }
    [self dataSourceChange];
    NSLog(@"scale = %f",scale);
}

#pragma mark - CPTBarPlotDataSource
#pragma mark - 返回k线的填充颜色
- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    NSDictionary *infomap = [showDataSource objectAtIndex:idx];
    NSNumber *m1 = [NSNumber numberWithFloat:[[infomap objectForKey:@"OPEN"] floatValue]];
    NSNumber *m2 = [NSNumber numberWithFloat:[[infomap objectForKey:@"CLOSE"] floatValue]];
    if ([m1 isLessThan:m2]) {
        
        return [CPTFill fillWithColor:[CPTColor colorWithHexString:COLOR_LINE_RED]];
    } else {
        return [CPTFill fillWithColor:[CPTColor colorWithHexString:COLOR_LINE_GREEN]];
    }
}

#pragma mark - 返回k线、平均线、成交量的y值
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSDictionary *infomap = [showDataSource objectAtIndex:idx];
    
    NSNumber *num = nil;
    
    NSString *key = (NSString *)plot.identifier;
    
    
    if ([key isEqualToString:kPlotKP]) {
        if (fieldEnum == CPTBarPlotFieldBarLocation) {
            num = [NSNumber numberWithInt:(int)idx];
        } else if (fieldEnum == CPTBarPlotFieldBarTip || fieldEnum == CPTBarPlotFieldBarBase) {
            NSNumber *m1 = [NSNumber numberWithFloat:[[infomap objectForKey:@"OPEN"] floatValue]];
            NSNumber *m2 = [NSNumber numberWithFloat:[[infomap objectForKey:@"CLOSE"] floatValue]];
            if (fieldEnum == CPTBarPlotFieldBarTip) {
                
                num = [m1 isLessThan:m2] ? m2 : m1;
                //                            num = @44;
            } else if (fieldEnum == CPTBarPlotFieldBarBase) {
                num = [m1 isLessThan:m2] ? m1 : m2;
                //                            num = @44;
            }
            
        }
    } else if ([key isEqualToString:kPlotCJ]) {
        if (fieldEnum == CPTBarPlotFieldBarLocation) {
            num = [NSNumber numberWithInt:(int)idx];
        } else if (fieldEnum == CPTBarPlotFieldBarTip) {
            
            // 返回high ---》中间的竖线，最上面的值
            num = [NSNumber numberWithFloat:[[infomap objectForKey:@"HIGH"] floatValue]];
            //            num = @54;
        } else if (fieldEnum == CPTBarPlotFieldBarBase) {
            
            // 返回low ---》中间的竖线，最下面的值
            num = [NSNumber numberWithFloat:[[infomap objectForKey:@"LOW"] floatValue]];
            //            num = @54;
        }
        
    } else if ([key isEqualToString:kPlotAvg]) {
        if(fieldEnum == CPTScatterPlotFieldX){
            num = [NSNumber numberWithInt:(int)idx];
        } else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:[[infomap objectForKey:@"ADJ"] floatValue]];
        }
        
    } else if ([key isEqualToString:kPlotVolume]) {
        if(fieldEnum == CPTScatterPlotFieldX){
            num = [NSNumber numberWithInt:(int)idx];
        } else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:[[infomap objectForKey:@"VOLUME"] floatValue]];
            //            num = @77;
        }
    }
    //    NSLog(@"key = %@   num = %@",key,num);
    return num;
}

@end
