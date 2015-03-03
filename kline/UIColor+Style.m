//
//  UIColor+Style.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "UIColor+Style.h"

@implementation UIColor (Style)
+ (UIColor *)randomColor
{
    CGFloat r = ((CGFloat)(arc4random() % 255))/255.0;
    CGFloat g = ((CGFloat)(arc4random() % 255))/255.0;
    CGFloat b = ((CGFloat)(arc4random() % 255))/255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

+ (UIColor *)colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString isEqualToString:@"RED"]) {
        return [UIColor redColor];
    } else if([cString isEqualToString:@"BLUE"]) {
        return [UIColor blueColor];
    } else if([cString isEqualToString:@"BROWN"]) {
        return [UIColor brownColor];
    } else if([cString isEqualToString:@"GRAY"]) {
        return [UIColor grayColor];
    } else if([cString isEqualToString:@"GREEN"]) {
        return [UIColor greenColor];
    } else if([cString isEqualToString:@"YELLOW"]) {
        return [UIColor yellowColor];
    } else if([cString isEqualToString:@"ORANGE"]) {
        return [UIColor orangeColor];
    } else if([cString isEqualToString:@"WHITE"]) {
        return [UIColor whiteColor];
    };
    
    if ([cString length] < 6) {
        return [UIColor blackColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    };
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        return [UIColor blackColor];
    }
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end

@implementation CPTColor (Style)



+ (CPTColor *)colorWithHexString:(NSString *)colorStr
{
    
    UIColor *color = [UIColor colorWithHexString:colorStr];
    return [CPTColor colorWithCGColor:color.CGColor];
}

@end
