//
//  getData.m
//  Kline
//


#import "getData.h"
#import "Util.h"
#import "StockKlineData.h"

static getData *shareGetData;

@implementation getData
{
    Util *util;
    int pan;
}


-(id)init{
    self = [super init];
    if (self){
        self.isFinish = NO;
        self.maxValue = 0;
        self.minValue = CGFLOAT_MAX;
        self.volMaxValue = 0;
        self.volMinValue = CGFLOAT_MAX;
        util = [[Util alloc] init];
        
        
    }
    return  self;
}

+ (id)sharedGetData
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareGetData = [[super allocWithZone:NULL] init];
    });
    return shareGetData;
}

#pragma mark - 数据加载，本地有就直接取，没有就去网络请求
-(id)initWithUrl:(NSString*)url{
    
    if (self){
     
        NSArray *array = [[StockKlineData new] loadStockTestData];
        
        [self changeData:array];
    }
    return self;
}

- (void)panChangeDataSource:(int)panCount
{
    pan = panCount;
    // 从本地读取数据
   
    NSArray* stuList = [[StockKlineData new] loadStockTestData];
    
    NSArray *newArray = nil;
    if (panCount > 0) {
        newArray =  [self addPartDataSourceTotal:stuList isLeft:0 right:panCount/self.scroolSpeed];
        self.kPage = panCount/self.scroolSpeed;
        
    } else {
        
        newArray =  [self addPartDataSourceTotal:stuList isLeft:-panCount/self.scroolSpeed right:0];
        self.kPage = -panCount/self.scroolSpeed;
    }
    
    [self addAlldataSource:stuList newArray:newArray];
}

#pragma mark - 从数据源中取出局部数据
- (NSArray *)addPartDataSourceTotal:(NSArray *)dataSource isLeft:(NSInteger)leftSwipeCount right:(NSInteger)rightSwipeCount
{
    self.isZoer = NO;
    self.isPanChangeMax = NO;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    if (leftSwipeCount) {
        
        NSUInteger lenght = self.kCount >= dataSource.count?newArray.count:self.kCount;
        if (leftSwipeCount > 0) {
            self.isZoer = YES;
            leftSwipeCount = 0;
        }
        for (int i = (int)leftSwipeCount ; i < lenght + leftSwipeCount ; i++)
        {
            NSDictionary *dic = dataSource[i];
            if (![dic[@"open"] isEqualToString:@""]) {
                [newArray addObject:dic];
            }
        }
        
    }else if (rightSwipeCount){
        
        NSUInteger lenght = self.kCount >= dataSource.count?newArray.count:self.kCount;
        
        if (rightSwipeCount + self.kCount >= dataSource.count) {
            rightSwipeCount = dataSource.count - self.kCount;
            NSLog(@"ringht = %f",(long)rightSwipeCount*self.scroolSpeed);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stop" object:[NSNumber numberWithInteger:rightSwipeCount*self.scroolSpeed]];
            self.isPanChangeMax = YES;
        }
        
        for (int i = (int)rightSwipeCount; i < lenght + rightSwipeCount ; i++)
        {
            NSDictionary *dic = dataSource[i];
            if (![dic[@"open"] isEqualToString:@""]) {
                [newArray addObject:dic];
            }
        }
    }else{
        
        newArray = (NSMutableArray *)dataSource;
        
        NSUInteger length = self.kCount >=newArray.count?newArray.count:self.kCount;
        
        if (self.kPage >= newArray.count - length) {
            self.kPage = newArray.count - length;
        }
        
        newArray = (NSMutableArray *)[newArray objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(self.kPage, self.kCount>=newArray.count?newArray.count:self.kCount)]]; // 只要前面指定的数据
        
    }
    return newArray;
}

#pragma mark - 根据原始总数据源和取出的局部数据更新，数据坐标数据源
- (void)addAlldataSource:(NSArray *)lines newArray:(NSArray *)newArray
{
    
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    NSInteger idx;
    int MA5=5,MA10=10,MA20=20; // 均线统计
    self.maxValue = CGFLOAT_MIN,self.minValue = CGFLOAT_MAX;
    self.volMaxValue = CGFLOAT_MIN,self.volMinValue = CGFLOAT_MAX;
    
    for (idx = newArray.count-1; idx >= 0; idx--)
    {
        NSDictionary *dic = [newArray objectAtIndex:idx];
        
        if([dic[@"open"] isEqualToString:@""]){
            continue;
        }
        // 收盘价的最小值和最大值
        if ([dic[@"high"] floatValue] > self.maxValue) {
            self.maxValue = [dic[@"high"] floatValue];
        }
        if (([dic[@"low"] floatValue] < self.minValue) && ([dic[@"low"] floatValue] != 0)) {
            self.minValue = [dic[@"low"] floatValue];
        }
        // 成交量的最大值最小值
        if ([dic[@"volume"] floatValue] > self.volMaxValue) {
            self.volMaxValue = [dic[@"volume"] floatValue];
        }
        if (([dic[@"volume"] floatValue] < self.volMinValue)&& ([dic[@"volume"] floatValue] != 0)) {
            self.volMinValue = [dic[@"volume"] floatValue];
        }
        
        NSMutableArray *item =[[NSMutableArray alloc] init];
        [item addObject:dic[@"open"]]; // open
        [item addObject:dic[@"high"]]; // high
        [item addObject:dic[@"low"]]; // low
        [item addObject:dic[@"close"]]; // close
        [item addObject:dic[@"volume"]]; // volume 成交量
        CGFloat  idxLocation = [lines indexOfObject:dic];
        
        [item addObject:[util sumArrayWithData:lines andRange:NSMakeRange(idxLocation, MA5)]];
        [item addObject:[util sumArrayWithData:lines andRange:NSMakeRange(idxLocation, MA10)]];
        [item addObject:[util sumArrayWithData:lines andRange:NSMakeRange(idxLocation, MA20)]];
        
        // 前面二十个数据不要了，因为只是用来画均线的
        [category addObject:dic[@"date"]]; // date
        [data addObject:item];
    }
    if(data.count == 0){
        NSLog(@"数据源为空");
        return;
    }
    
    self.data = data; // Open,High,Low,Close,Adj Close,Volume
    
    self.category = category; // Date
    //NSLog(@"%@",data);
}

#pragma mark - 把请求下来最原始的数据转换成 可以直接使用的k线值
-(void)changeData:(NSArray*)lines{
    
    NSArray *newArray = [self addPartDataSourceTotal:lines isLeft:0 right:0];
    [self addAlldataSource:lines newArray:newArray];
}



@end
