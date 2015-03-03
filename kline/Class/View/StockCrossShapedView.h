//
//  StockCrossShapedView.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StockHeard.h"

#define TAG_LEFT @"left"
#define TAG_TOP @"top"
#define TAG_RIGHT @"right"
#define TAG_BOTTOM @"bottom"

/**
 * @brief 委托
 * 将KDVIEWStockCrossShapedView获得的手势事件，交由委托处理
 */
@protocol StockCrossShapedViewDelegate <NSObject>
/**
 * @brief       点击
 * @param       sender
 */
- (void)whenTapEvent:(UITapGestureRecognizer *)sender;
/**
 * @brief       拖动
 * @param       sender
 */
- (void)whenPanEvent:(UIPanGestureRecognizer *)sender;
/**
 * @brief       放大、缩小
 * @param       sender
 */
- (void)whenPinchEvent:(UIPinchGestureRecognizer *)sender;
@end

@interface StockCrossShapedView : UIView {
    
    UITapGestureRecognizer *tapGesture; //!< 点击手势.
    UIPanGestureRecognizer *panGesture; //!< 移动手势.
    UIPinchGestureRecognizer *pinchGesture; //!< 捏合手势.
    CGPoint point; //!< 绘制点坐标.
    BOOL showCrossShaped; //!< 当前是否显示垂直线.
    StockPadding padding; //!< 空白值.
    NSDictionary *arroundValue; //!< 绘制四周的值.
    StockDrawInfo drawInfo; //!< 绘制信息枚举.
    StockGesture gesture; //!< 绑定手势枚举.
    id<StockCrossShapedViewDelegate> delegate; //!< 委托.
    
}

/**
 * @brief       绘制十字线
 * @param       mPoint
 * @param       mshowCrossShaped
 * @param       mPadding
 * @param       mArround
 */
- (void)drawCrossShapedAtPoint:(CGPoint)mPoint showCrossShaped:(BOOL)mshowCrossShaped padding:(StockPadding)mPadding arroundValue:(NSDictionary *) mArround;
/**
 * @brief       自定义初始化方法
 * @param       frame
 * @param       mDrawInfo
 * @param       mGesture
 * @param       mDelegate
 */
- (id)initWithFrame:(CGRect)frame drawInfo:(StockDrawInfo)mDrawInfo gesture:(StockGesture)mGesture delegate:(id)mDelegate;

@end
