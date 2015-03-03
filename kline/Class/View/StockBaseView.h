//
//  StockBaseView.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "StockHeard.h"
#import "StockGraphHostingView.h"
#import "StockCrossShapedView.h"

#define COLOR_LINE_RED @"#EE0000"
#define COLOR_LINE_GREEN @"#00CD00"


/**
 * @brief StockBaseViewProtocol
 * 股票行情绘图协议，子类实现
 */
@protocol StockBaseViewProtocol <NSObject>
/**
 * @brief       修改xy轴的设置
 * @param       xLen        x轴长度
 * @param       dataSource  数据源
 * @return      NSArray
 */
- (void)changeXYAxisWithXLen:(int)xLen dataSource:(NSArray *)dataSource;
/**
 * @brief       创建需要绘制的图形，要将创建的图形加入的数组中
 */
- (void)createMyPlot;
@end

/**
 * @brief StockBaseViewDelegate
 * 将事件交给委托处理
 */
@protocol StockBaseViewDelegate <CPTScatterPlotDataSource, CPTScatterPlotDelegate, CPTBarPlotDataSource, CPTBarPlotDelegate>

@required
- (void)whenTapEvent:(UITapGestureRecognizer *)sender tag:(NSString *)tag;
- (void)whenPanEvent:(UIPanGestureRecognizer *)sender tag:(NSString *)tag;
- (void)whenPinchEvent:(UIPinchGestureRecognizer *)sender tag:(NSString *)tag;
- (NSString *)showValueWithType:(NSString *)type :(NSObject *)obj;
/**
 * @brief       显示的数据源
 * @return      NSArray
 */
- (NSArray *)showDataSource;
/**
 * @brief       获取x轴长度
 */
- (int)xAxisLen;
@end

@interface StockBaseView : UIView <StockCrossShapedViewDelegate, StockBaseViewProtocol> {
    __weak id<StockBaseViewDelegate> delegate; //!< 委托.
    StockPadding padding; //!< CPTGraph的padding.
    NSString *tag; //!< 标签.
}
/**
 * @brief 绘制十字线的view
 */
@property (nonatomic, readwrite, strong) StockCrossShapedView *crossView;
/**
 * @brief 绘制十字线的view
 */
@property (nonatomic, readwrite, strong) StockGraphHostingView *hostingView;
/**
 * @brief plotArray
 */
@property (nonatomic, readwrite, strong) NSMutableArray *plotArray;
/**
 * @brief       初始化方法
 * @param       frame
 * @param       mTag
 * @param       mPadding
 * @param       mDrawInfo
 * @param       mGesture
 * @param       mDelegate
 */
- (id)initWithFrame:(CGRect)frame tag:(NSString *)mTag padding:(StockPadding)mPadding drawInfo:(StockDrawInfo)mDrawInfo gesture:(StockGesture)mGesture delegate:(id)mDelegate isKline:(BOOL)isKline;
/**
 * @brief       数据源修改
 */
- (void)dataSourceChanged;
/**
 * @brief       画十字线
 * @param       point
 * @param       infoMap
 */
- (void)drawCrossLine:(CGPoint)point info:(NSDictionary *)infoMap;
/**
 * @brief       隐藏十字线
 */
- (void)hideCrossLine;

@end
