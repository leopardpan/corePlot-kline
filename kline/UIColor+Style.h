//
//  UIColor+Style.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@interface UIColor (Style)

+ (UIColor *)colorWithHexString:(NSString *)colorStr;

@end

@interface CPTColor(Style)


+ (CPTColor *)colorWithHexString:(NSString *)colorStr;


@end
