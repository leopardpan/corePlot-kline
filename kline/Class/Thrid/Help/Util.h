//
//  Util.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

/**************************  factory     *************************/

/** 实例化一个Button*/
- (UIButton *)initializeCustomButtonFrame:(CGRect)rect title:(NSString *)title target:(id)object action:(SEL)action;

/** 实例化一个线框View*/
+ (UIView *)initializeCustomViewFrame:(CGRect)rect borderColor:(NSString *)colorName;

/** 实例化一个线框View*/
+ (UILabel *)initializeCustomLabelFrame:(CGRect)rect textColor:(NSString *)colorName title:(NSString *)title textAlignment:(NSTextAlignment)textAlignment;
/** 实例化一个线框View*/
+ (UILabel *)creatMovelLineLabelFrame:(CGRect)rect;

/*********************    ModelManager   ***********************/

/** 从数组里取出对应的点*/
- (NSNumber *)sumArrayWithData:(NSArray*)data andRange:(NSRange)range;

/** 跟句字典和键 把NSNumber转换成NSString*/
- (NSString *)numberWithStringDic:(NSDictionary *)dic str:(NSString *)str;

/** 跟句字典和键 把NSNumber转换成NSString--时间*/
- (NSString *)numberChangeStringDateDic:(NSDictionary *)dic str:(NSString *)str;

/** 根据文件名拼成沙盒路径*/
- (NSString*)filePath:(NSString *)fileName;

/** 把请求下来的字典的值全部转成字符串*/
- (NSDictionary *)dictionarChangeDic:(NSDictionary *)dic;

/** Moving bed cleaning the inside of the box of cache*/
- (void)removeAllCache:(NSString *)path;

/** CGFloat Change PriceNSString*/
+ (NSString*)changePrice:(CGFloat)price;

- (float) getMaxWithNum1:(float)num1 num2:(float)num2 num3:(float)num3;

- (float) getMinWithNum1:(float)num1 num2:(float)num2 num3:(float)num3;

@end
