//
//  StockKlineViewController.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "StockKlineView.h"
#import "StockKlineVolumeView.h"
#import "StockKlineData.h"

@interface StockKlineViewController : BaseViewController
{
    NSDictionary *stopStartObj;
    NSDictionary *stopEndObj;
    int nScale;
}

@end
