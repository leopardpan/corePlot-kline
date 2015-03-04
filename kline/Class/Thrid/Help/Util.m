//
//  Util.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "Util.h"
#import "UIColor+helper.h"


@implementation Util
{
    NSDateFormatter *dateFormatter ;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}
- (UIButton *)initializeCustomButtonFrame:(CGRect)rect title:(NSString *)title target:(id)obj action:(SEL)action
{
    
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:obj action:action forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor colorWithHexString:@"#EBEBEB" withAlpha:1];
    return btn;
}

+ (UIView *)initializeCustomViewFrame:(CGRect)rect borderColor:(NSString *)colorName
{
    UIView *view = [[UIView alloc] initWithFrame:rect];
    // 主视图的边框颜色
    view.layer.borderColor = [UIColor colorWithHexString:colorName withAlpha:1].CGColor;
    
    // 主视图的边框宽度
    view.layer.borderWidth = 0.5;
    view.userInteractionEnabled = YES;
    
    return view;
}

+ (UILabel *)initializeCustomLabelFrame:(CGRect)rect textColor:(NSString *)colorName title:(NSString *)title textAlignment:(NSTextAlignment)textAlignment
{
    
    UILabel * label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:8];
    label.text = title;
    label.textAlignment = textAlignment;
    label.textColor = [UIColor colorWithHexString:colorName withAlpha:1];
    //    [label sizeToFit];
    return label;
}
+ (UILabel *)creatMovelLineLabelFrame:(CGRect)rect
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont systemFontOfSize:8];
    label.layer.cornerRadius = 5;
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentCenter;
    label.alpha = 0.8;
    
    return label;
}


- (NSNumber *)sumArrayWithData:(NSArray *)data andRange:(NSRange)range
{
    CGFloat value = 0;
    if (data.count - range.location > range.length) {
        NSArray *newArray = [data objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
        for (NSDictionary *dic in newArray) {
            
            value += [dic[@"close"] floatValue];
        }
        if (value>0) {
            value = value / newArray.count;
        }
    }
    return [NSNumber numberWithFloat:value];
}

#pragma mark - 把NSNumber转换成NSString
- (NSString *)numberWithStringDic:(NSDictionary *)dic str:(NSString *)str
{
    CGFloat flot = [(NSNumber*)[dic objectForKey:str] floatValue];
    NSString *strop = [NSString stringWithFormat:@"%.2f",flot];
    return strop;
}

#pragma mark - 把毫秒时间转化为字符串
- (NSString *)numberChangeStringDateDic:(NSDictionary *)dic str:(NSString *)str
{
    double time = [(NSNumber *)[dic objectForKey:str] doubleValue];
    
    NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:time/1000.0];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *date = [dateFormatter stringFromDate:d];
    
    return date;
}


- (NSDictionary *)dictionarChangeDic:(NSDictionary *)dic
{
    NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
    
    NSArray *keys = [dic allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:@"date"]) {

            [myDict setValue:[dic objectForKey:key] forKey:key];
        }else {

            [myDict setValue:dic[key] forKey:key];
            
            if ([key isEqualToString:@"close"]) {
                [myDict setValue:dic[key] forKey:@"adj"];
            }

        }
    }
    
    return myDict;
}

- (float) getMaxWithNum1:(float)num1 num2:(float)num2 num3:(float)num3
{
    float max = num1;
    max = max > num2 ? max : num2;
    max = max > num3 ? max : num3;
    return max;
}

- (float) getMinWithNum1:(float)num1 num2:(float)num2 num3:(float)num3
{
    float min = num1;
    min = min < num2 ? min : num2;
    min = min < num3 ? min : num3;
    return min;
}

- (NSString*)filePath:(NSString *)fileName
{
    NSString *path=NSHomeDirectory();
    path=[path stringByAppendingPathComponent:@"Documents"];
    
    NSFileManager *fm=[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        if (fileName&& [fileName length]!=0) {
            path=[path stringByAppendingPathComponent:fileName];
        }
    }
    else{
        NSLog(@"指定目录不存在");
    }
    
    return path;
}
- (void)removeAllCache:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //获得指定路径path的所有内容(文件和文件夹)
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *obj in array) {
        NSString *name = [path stringByAppendingPathComponent:obj];
        [fileManager removeItemAtPath:name error:nil];
    }
}

+ (NSString*)changePrice:(CGFloat)price{
    CGFloat newPrice = 0;
    NSString *danwei = @"万";
    if ((int)price>10000) {
        newPrice = price / 10000 ;
    }
    if ((int)price>10000000) {
        newPrice = price / 10000000 ;
        danwei = @"千万";
    }
    if ((int)price>100000000) {
        newPrice = price / 100000000 ;
        danwei = @"亿";
    }
    NSString *newstr = [[NSString alloc] initWithFormat:@"%.0f%@",newPrice,danwei];
    return newstr;
}


@end
