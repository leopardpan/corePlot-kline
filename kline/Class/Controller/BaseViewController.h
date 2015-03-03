//
//  BaseViewController.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StockBaseView.h"

/**
 * @brief StockBaseViewControllerProtocol
 * 协议，子类实现
 */
@protocol StockBaseViewControllerProtocol <NSObject>
@required
/**
 * @brief       滑动事件处理，如果len<0向左，如果len>0向右
 * @param       len     滑动步长
 * @param       tag     标示
 */
- (void)loadDataByPan:(CGFloat)len tag:(NSString *)tag;
/**
 * @brief       放大、缩小事件处理
 * @param       scale   缩放大小
 * @param       tag     标示
 */
- (void)loadDataByPinch:(CGFloat)scale tag:(NSString *)tag;

@end
@interface BaseViewController : UIViewController <StockBaseViewDelegate, StockBaseViewControllerProtocol>
{
    @protected
    NSMutableDictionary *stockBaseViewMap; //!< 保存stockview键值对.
    BOOL showCrossLine; //!< 当前是否显示十字线.
    NSMutableArray *dataSource; //!< 数据源.
    NSMutableArray *showDataSource; //!< 显示的数据源.
    BOOL loadingData; //!< 当前是否在加载数据.
    NSRange showRange; //!< .
    CGFloat panOffset; // 拖拽偏移量
    int xAxisLen; //!< x轴显示长度.
}
/**
 * @brief       修改数据源触发
 */
- (void)dataSourceChange;
@end
