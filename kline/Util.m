//
//  Util.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "Util.h"

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
    //    NSString *date_value = [rs stringForColumn:@"DATA"];
    //    double open_value = [rs doubleForColumn:@"OPEN"];
    //    double high_value = [rs doubleForColumn:@"HIGH"];
    //    double low_value = [rs doubleForColumn:@"LOW"];
    //    double close_value = [rs doubleForColumn:@"CLOSE"];
    //    long volume_value = [rs longForColumn:@"VOLUME"];
    //    double adj_value = [rs doubleForColumn:@"ADJ"];
    
    for (NSString *key in keys) {
        if ([key isEqualToString:@"date"]) {
            //             [myDict setValue:[self numberChangeStringDateDic:dic str:key] forKey:@"DATA"];
            [myDict setValue:[dic objectForKey:key] forKey:@"DATA"];
        }else {
            if ([key isEqualToString:@"open"]) {
                [myDict setValue:dic[key] forKey:@"OPEN"];
            }else if ([key isEqualToString:@"close"]) {
                [myDict setValue:dic[key] forKey:@"CLOSE"];
            }else if ([key isEqualToString:@"low"]) {
                [myDict setValue:dic[key] forKey:@"LOW"];
            }else if ([key isEqualToString:@"volume"]) {
                [myDict setValue:dic[key] forKey:@"VOLUME"];
            }else if ([key isEqualToString:@"high"]) {
                [myDict setValue:dic[key] forKey:@"HIGH"];
            }
            
            
            if ([key isEqualToString:@"close"]) {
                [myDict setValue:dic[key] forKey:@"ADJ"];
            }
            //            [myDict setValue:[self numberWithStringDic:dic str:key] forKey:key];
        }
    }
    
    return myDict;
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
