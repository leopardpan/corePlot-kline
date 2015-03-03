//
//  StockKlineData.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockKlineData.h"
#import "Util.h"

@implementation StockKlineData
- (NSArray *) loadStockTestData
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
  
    Util *util = [[Util alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil];
    NSArray *dataSource = [NSArray arrayWithContentsOfFile:path];
    
    for (int i = 0; i < dataSource.count ; i++) {
        
        NSDictionary *dic = dataSource[i];
        NSDictionary  *dicData = [util dictionarChangeDic:dic];
        
      
        
        [data addObject:dicData];
    }
    
    return [data mutableCopy];
}

@end
