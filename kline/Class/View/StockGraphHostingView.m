//
//  StockGraphHostingView.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockGraphHostingView.h"

@implementation StockGraphHostingView

- (StockPadding) stockPadding
{
    CPTGraph *hostedGraph = self.hostedGraph;
    StockPadding padding = {
        hostedGraph.paddingLeft + [hostedGraph.plotAreaFrame paddingLeft],
        hostedGraph.paddingTop + [hostedGraph.plotAreaFrame paddingTop],
        hostedGraph.paddingRight + [hostedGraph.plotAreaFrame paddingRight],
        hostedGraph.paddingBottom + [hostedGraph.plotAreaFrame paddingBottom]
    };
    return padding;
}

@end
