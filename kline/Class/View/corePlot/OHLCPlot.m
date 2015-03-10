//
//  OHLCPlot.m
//  CorePlotGallery
//

#import "OHLCPlot.h"
#import "StockKlineData.h"
#import "Util.h"

static const NSTimeInterval oneDay = 24 * 60 * 60;

@interface OHLCPlot()

@property (nonatomic, readwrite, strong) CPTGraph *graph;
@property (nonatomic, readwrite, strong) NSMutableArray *plotData;

@property (nonatomic, strong) Util *util;

@end

@implementation OHLCPlot

@synthesize graph;
@synthesize plotData;


-(id)init
{
    if ( (self = [super init]) ) {
        graph    = nil;
        plotData = nil;

        self.title   = @"k线测试";
        self.section = kFinancialPlots;
        self.util = [[Util alloc] init];
    }

    return self;
}

-(void)generateData
{
    
    NSArray *array = [[StockKlineData new] loadStockTestData];
    
    if ( self.plotData ) {
        [self.plotData removeAllObjects];
    }
    
        NSMutableArray *newData = [NSMutableArray array];
        for ( NSUInteger i = abs(self.panOffset); i < 40; i++ ) {
            NSTimeInterval x = oneDay * i;


            NSDictionary *dic = array[i];

            [newData addObject:
             @{ @(CPTTradingRangePlotFieldX): @(x),
                @(CPTTradingRangePlotFieldOpen): dic[@"open"],
                @(CPTTradingRangePlotFieldHigh): dic[@"high"],
                @(CPTTradingRangePlotFieldLow): dic[@"low"],
                @(CPTTradingRangePlotFieldClose): dic[@"close"] }
            ];
        }

        self.plotData = newData;
    
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    float maxValueY = 0.0f, minValueY = 0.0f;
    
    // 先循环一次datasource获得最高价和最低价
    for (NSDictionary *map in self.plotData) {
        
        float mZGCJ = [(NSNumber *)[map objectForKey:@(CPTTradingRangePlotFieldHigh)] floatValue];
        float mZDCJ = [(NSNumber *)[map objectForKey:@(CPTTradingRangePlotFieldLow)] floatValue];
        float mADJ = [(NSNumber *)[map objectForKey:@(CPTTradingRangePlotFieldClose)] floatValue];
        float max = [self.util getMaxWithNum1:mZDCJ num2:mZGCJ num3:mADJ];
        float min = [self.util getMinWithNum1:mZDCJ num2:mZGCJ num3:mADJ];
        
        if (maxValueY == 0 || max > maxValueY) {
            maxValueY = max;
        }
        if (minValueY == 0 || min < minValueY) {
            minValueY = min;
        }
    }
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];

    CGRect bounds = hostingView.bounds;


    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:newGraph toHostingView:hostingView];
    [self applyTheme:theme toGraph:newGraph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];

    // 外边框
    CPTMutableLineStyle *borderLineStyle   = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor              = [CPTColor grayColor];
    borderLineStyle.lineWidth              = 1.0;
    newGraph.plotAreaFrame.borderLineStyle = borderLineStyle;
    newGraph.plotAreaFrame.paddingTop      = self.titleSize * CPTFloat(0.5);
    newGraph.plotAreaFrame.paddingRight    = self.titleSize * CPTFloat(0.5);
    newGraph.plotAreaFrame.paddingBottom   = self.titleSize * CPTFloat(1.25);
    newGraph.plotAreaFrame.paddingLeft     = self.titleSize * CPTFloat(1.5);
    newGraph.plotAreaFrame.masksToBorder   = NO;

    self.graph = newGraph;

    // Axes
    CPTXYAxisSet *xyAxisSet         = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *xAxis                = xyAxisSet.xAxis;
    
    xAxis.majorIntervalLength       = CPTDecimalFromDouble(oneDay*10);
    xAxis.minorTicksPerInterval     = 0;
    xAxis.minorTickLineStyle = nil;
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(minValueY-3.7);
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle         = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate     = refDate;
    xAxis.labelFormatter            = timeFormatter;

    /*
    // 给x轴画箭头
    CPTLineCap *lineCap  = [[CPTLineCap alloc] init];
    lineCap.lineStyle    = xAxis.axisLineStyle;
    lineCap.lineCapType  = CPTLineCapTypeOpenArrow;
    lineCap.size         = CGSizeMake( self.titleSize * CPTFloat(0.5), self.titleSize * CPTFloat(0.5) );
    xAxis.axisLineCapMax = lineCap;
     */
    

    CPTXYAxis *yAxis     = xyAxisSet.yAxis;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble( oneDay );
    yAxis.minorTickLineStyle = nil;
    
    // Line plot with gradient fill
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
    dataSourceLinePlot.identifier      = @"Data Source Plot";
    dataSourceLinePlot.title           = @"Close Values";
    dataSourceLinePlot.dataLineStyle   = nil;
    dataSourceLinePlot.dataSource      = self;
    [newGraph addPlot:dataSourceLinePlot];

    
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(1.0) green:CPTFloat(1.0) blue:CPTFloat(1.0) alpha:CPTFloat(1.0)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle        = -90.0; // 填充渐变的角度
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill       = areaGradientFill;
    dataSourceLinePlot.areaBaseValue  = CPTDecimalFromDouble(0.0);

    // OHLC plot
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 2.0;

    CPTMutableLineStyle *redLineStyle = [whiteLineStyle mutableCopy];
    redLineStyle.lineColor = [CPTColor redColor];

    CPTMutableLineStyle *greenLineStyle = [whiteLineStyle mutableCopy];
    greenLineStyle.lineColor = [CPTColor greenColor];

    // 设置每个k线的文字
    CPTMutableTextStyle *blackTextStyle = [CPTMutableTextStyle textStyle];
    blackTextStyle.color = [CPTColor blackColor];

    CPTTradingRangePlot *ohlcPlot = [[CPTTradingRangePlot alloc] initWithFrame:newGraph.bounds];
    ohlcPlot.identifier = @"OHLC";

    // 分别设置不同的k先颜色
    ohlcPlot.lineStyle         = whiteLineStyle;
    ohlcPlot.increaseLineStyle = greenLineStyle;
    ohlcPlot.decreaseLineStyle = redLineStyle;

    ohlcPlot.labelTextStyle    = blackTextStyle;
    ohlcPlot.labelOffset       = 0.0;
    ohlcPlot.stickLength       = 10.0;
    ohlcPlot.dataSource        = self;
    ohlcPlot.delegate          = self;
    ohlcPlot.plotStyle         = CPTTradingRangePlotStyleCandleStick; // kLine
    [newGraph addPlot:ohlcPlot];

    // Add legend
    newGraph.legend                    = [CPTLegend legendWithGraph:newGraph];
//    newGraph.legend.textStyle          = xAxis.titleTextStyle;
    
    newGraph.legend.fill               = newGraph.plotAreaFrame.fill;
    newGraph.legend.borderLineStyle    = newGraph.plotAreaFrame.borderLineStyle;
    newGraph.legend.cornerRadius       = 5.0;
    newGraph.legend.swatchCornerRadius = 5.0;
    newGraph.legendAnchor              = CPTRectAnchorBottom; // 设置图标说明的位置
    newGraph.legendDisplacement        = CGPointMake( 0.0, self.titleSize * CPTFloat(3.0) );

    // Set plot ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    
    CGFloat flag = self.panOffset > 0 ? self.panOffset:1;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble( oneDay * flag) length:CPTDecimalFromDouble(oneDay * self.plotData.count)];
    NSLog(@"count = =       %f",oneDay*self.plotData.count);
 
#warning 取临时范围
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(minValueY-3) length:CPTDecimalFromInteger(maxValueY-minValueY+5)];
}

#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSLog(@"fieldEnum = %lu",(unsigned long)fieldEnum);
//    NSDecimalNumber *num = [NSDecimalNumber zero];
    NSString *num = nil;

    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        switch ( fieldEnum ) {
                
            case CPTScatterPlotFieldX:
                num = self.plotData[index][@(CPTTradingRangePlotFieldX)];
//                num = @259200;
                break;

            case CPTScatterPlotFieldY:
                num = self.plotData[index][@(CPTTradingRangePlotFieldClose)];
//                num = @3.111;
                break;

            default:
                break;
        }
        NSLog(@"num1 = %@",num);
    }
    // k线
    else {
       
        num = self.plotData[index][@(fieldEnum)];
//        num = @3.444;
         NSLog(@"num2 = %@    idextifier = %@",num,plot.identifier);
    }
    
    return num;
}

#pragma mark -
#pragma mark Plot Delegate Methods

-(void)tradingRangePlot:(CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Bar for '%@' was selected at index %d.", plot.identifier, (int)index);
}

@end
