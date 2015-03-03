//
//  StockGraphHostingView.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "StockHeard.h"


@interface StockGraphHostingView : CPTGraphHostingView

/**
 * @brief       获得CPTGraph的padding
 * @return      KDVIEWStockPadding
 */

- (StockPadding) stockPadding;
@end
