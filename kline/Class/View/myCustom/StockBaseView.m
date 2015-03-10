//
//  StockBaseView.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockBaseView.h"
#import "UIColor+Style.h"

@implementation StockBaseView

@synthesize hostingView, crossView, plotArray;

#pragma mark -
#pragma mark 自定义初始化方法
- (id)initWithFrame:(CGRect)frame tag:(NSString *)mTag padding:(StockPadding)mPadding drawInfo:(StockDrawInfo)mDrawInfo gesture:(StockGesture)mGesture delegate:(id)mDelegate isKline:(BOOL)isKline
{
    self = [super initWithFrame:frame];
    if (self) {
        
        tag = mTag;
        padding = mPadding;
        delegate = mDelegate;
        plotArray = [NSMutableArray arrayWithCapacity:1];
        if (isKline) {
            
            hostingView = [[StockGraphHostingView alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, frame.size.height-20)];
        }else{
            
            hostingView = [[StockGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        }
        
        [self configHostingView];
        [self createMyPlot];
        crossView = [[StockCrossShapedView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) drawInfo:mDrawInfo gesture:mGesture delegate:self];
    }
    return self;
}
#pragma mark -
#pragma mark 创建CPTXYGraph并进行初始化设置
- (void)configHostingView
{
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    // 用于显示标题及刻度
    graph.plotAreaFrame.masksToBorder = NO;
    // 设置graph padding
    graph.paddingTop = padding.top;
    graph.paddingBottom = padding.bottom;
    graph.paddingLeft = padding.left;
    graph.paddingRight = padding.right;
    hostingView.hostedGraph = graph;
    // 设置plotspace使用户不能移动
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    
    // 系统主题
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    
    [graph applyTheme:theme];
}

- (void)configCrossView
{
}
#pragma mark -
#pragma mark 数据源变化
/*
 数据源变化
 1.先改修改xy轴显示
 2.遍历图形数组，进行更新图形
 */
- (void)dataSourceChanged
{
    
    // 修改XY轴
    [self changeXYAxisWithXLen:[delegate xAxisLen] dataSource:[delegate showDataSource]];
    //    NSLog(@"showDataSource = %@",[delegate showDataSource]);
    // 重绘plot
    for (CPTPlot *plot in plotArray) {
        [plot reloadData];
    }
    
}

#pragma mark -
#pragma mark 重写drawrect方法
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self addSubview:hostingView];
    [self addSubview:crossView];
}
#pragma mark -
#pragma mark 将捕获的事件交委托处理
- (void) whenTapEvent:(UITapGestureRecognizer *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(whenTapEvent:tag:)]) {
        [delegate whenTapEvent:sender tag:tag];
    }
}

- (void) whenPanEvent:(UIPanGestureRecognizer *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(whenPanEvent:tag:)]) {
        [delegate whenPanEvent:sender tag:tag];
    }
}

- (void) whenPinchEvent:(UIPinchGestureRecognizer *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(whenPinchEvent:tag:)]) {
        [delegate whenPinchEvent:sender tag:tag];
    }
}
#pragma mark -
#pragma mark 自定义方法：隐藏及绘制十字线
- (void)hideCrossLine
{
    [crossView drawCrossShapedAtPoint:CGPointMake(0, 0) showCrossShaped:NO padding:[hostingView stockPadding] arroundValue:nil];
}

- (void)drawCrossLine:(CGPoint)point info:(NSDictionary *)infoMap
{
    [crossView drawCrossShapedAtPoint:point showCrossShaped:YES padding:[hostingView stockPadding] arroundValue:infoMap];
}
@end