//
//  lineView.m
//  Kline
//


#import "lineView.h"
#import "lines.h"
#import "UIColor+helper.h"
#import "getData.h"
#import "Util.h"

#define urkKline @"http://rest.office.caishuo.com:80/v1/stocks/k.json?base_stock_id=1&type=%@"

#define avgLineTag 90

@interface lineView()<UIGestureRecognizerDelegate>
{
    UIView *mainboxView; // k线图控件
    UIView *bottomBoxView; // 成交量
    getData *getdata;
    UIView *movelineone; // 手指按下后显示的两根白色十字线
    UIView *movelinetwo;
    UILabel *movelineoneLable;
    UILabel *movelinetwoLable;
    NSMutableArray *pointArray; // k线所有坐标数组
    CGFloat MADays;
    UILabel *MA5; // 5均线显示
    UILabel *MA10; // 10均线
    UILabel *MA20; // 20均线
    UILabel *startDateLab;
    UILabel *endDateLab;
    UILabel *volMaxValueLab; // 显示成交量最大值
    BOOL isUpdate;
    BOOL isUpdateFinish;
    UIPinchGestureRecognizer *pinchGesture;
    CGPoint touchViewPoint;
    BOOL isPinch;
    
    /** 用来判断滑动方向*/
    int scrollDirection;
    
    /** 滑动次数*/
    int timerCount;
    
    /** 拖拽偏移量*/
    int panCount;
    
    /** 临时拖拽偏移量*/
    int tempPanOffset;
    
    /** 记录当前的拖拽位置*/
    int flagPanCount;
    
    /** 记录手指在屏幕上还是不在*/
    BOOL isUpInSide;
    
    /** 自定义滑动定时器*/
    NSTimer *_timer;
}

@end

@implementation lineView

-(id)init{
    self = [super init];
    [self initSet];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         [self initSet];
        
    }
    return self;
}

-(void)initSet{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        self.yHeight = 200; // k线图高度
        self.bottomBoxHeight = 80; // 底部成交量图的高度
        self.xWidth = self.frame.size.width; // k线图宽度
    } else {
        
        self.yHeight = 150; // k线图高度
        self.bottomBoxHeight = 50; // 底部成交量图的高度
        self.xWidth = self.frame.size.width; // k线图宽度
    }
   
    self.kLineWidth = 5;// k线实体的宽度
    self.kLinePadding = 1; // k实体的间隔
    self.req_type = @"day"; // 日K线类型
    self.endDate = [NSDate date];
    
    self.font = [UIFont systemFontOfSize:8];
    MADays = 20;
    isUpdate = NO;
    isUpdateFinish = YES;
    isPinch = NO;
    timerCount = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(cunstomScroll) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopScroll:) name:@"stop" object:nil];
    
    self.finishUpdateBlock = ^(id self){
        [self updateNib];
    };
}

#pragma mark - 开始绘制k线
-(void)start{
    
    [self drawBox];
    [self drawLine];
}

-(void)update{
    
    if (self.kLineWidth>20)
        self.kLineWidth = 20;
    if (self.kLineWidth<1)
        self.kLineWidth = 1;
    isUpdate = YES;
    
    [self drawLine];
}

-(void)updateSelf{
    
    if (isUpdateFinish) {
        
        if (self.kLineWidth>20)
            self.kLineWidth = 20;
        if (self.kLineWidth<1)
            self.kLineWidth = 1;
        isUpdateFinish = NO;
        isUpdate = YES;
        self.data = nil;
        self.category = nil;
        pointArray = nil;
        
        [self drawLine];
    }
}

#pragma mark 画框框和平均线
-(void)drawBox{
    
    // 画个k线图的框框
    if (mainboxView==nil) {
        
        CGFloat mainX;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mainX = 50;
        }else {
            mainX = 30;
        }
        NSLog(@"width = %f",self.frame.size.width);
        mainboxView = [Util initializeCustomViewFrame:CGRectMake(mainX, 20, self.xWidth-mainX-10, self.yHeight) borderColor:@"#444444"];
        
        [self addSubview:mainboxView];
        // 添加手指捏合手势，放大或缩小k线图
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(touchBoxAction:)];
        [mainboxView addGestureRecognizer:pinchGesture];
        
        // 长按手势
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        [longPressGestureRecognizer setMinimumPressDuration:0.3f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        [mainboxView addGestureRecognizer:longPressGestureRecognizer];
        
        // 拖拽手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGest:)];
        [mainboxView addGestureRecognizer:pan];
    }
    
    // 画个成交量的框框
    if (bottomBoxView==nil) {
        
        bottomBoxView = [Util initializeCustomViewFrame:CGRectMake(0,mainboxView.frame.size.height+20, mainboxView.frame.size.width, self.bottomBoxHeight) borderColor:@"#444444"];
        [mainboxView addSubview:bottomBoxView];
    }
    
    // 把显示开始结束日期放在成交量的底部左右两侧
    // 显示开始日期控件
    if (startDateLab==nil) {
        
        startDateLab = [Util initializeCustomLabelFrame:CGRectMake(bottomBoxView.frame.origin.x, bottomBoxView.frame.origin.y+bottomBoxView.frame.size.height, 50, 15) textColor:@"#000000" title:@"--" textAlignment:2];
        
        [mainboxView addSubview:startDateLab];
    }
    
    // 显示结束日期控件
    if (endDateLab==nil) {
        
        endDateLab = [Util initializeCustomLabelFrame:CGRectMake(mainboxView.frame.size.width-50, startDateLab.frame.origin.y, 50, 15) textColor:@"#000000" title:@"--" textAlignment:2];
        [mainboxView addSubview:endDateLab];
    }
    
    // 显示成交量最大值
    if (volMaxValueLab==nil) {
        volMaxValueLab = [Util initializeCustomLabelFrame:CGRectMake(0, bottomBoxView.frame.origin.y+19, mainboxView.frame.origin.x, self.font.lineHeight) textColor:@"#000000" title:@"--" textAlignment:2];
        [self addSubview:volMaxValueLab];
    }
    
    // 添加平均线值显示
    CGRect mainFrame = mainboxView.frame;
    
    // MA5 均线价格显示控件
    if (MA5==nil) {
        MA5 = [Util initializeCustomLabelFrame:CGRectMake(mainFrame.origin.x, 0, 30, 15) textColor:@"#6B8E23" title:@"MA5:--" textAlignment:1];
        [self addSubview:MA5];
    }
    
    // MA10 均线价格显示控件
    if (MA10==nil) {
        
        MA10 = [Util initializeCustomLabelFrame:CGRectMake(MA5.frame.origin.x +MA5.frame.size.width +10, 0, 30, 15) textColor:@"#FF9900" title:@"MA10:--" textAlignment:1];
        [self addSubview:MA10];
    }
    
    // MA20 均线价格显示控件
    if (MA20==nil) {
        MA20 = [Util initializeCustomLabelFrame:CGRectMake(MA10.frame.origin.x +MA10.frame.size.width +10, 0, 30, 15) textColor:@"#FF00FF" title:@"MA20:--" textAlignment:1];
        [self addSubview:MA20];
    }
    
    if (!isUpdate) {
        // 分割线
        CGFloat padRealValue = mainboxView.frame.size.height / 6;
        for (int i = 0; i<7; i++) {
            CGFloat y = mainboxView.frame.size.height-padRealValue * i;
            lines *line = [[lines alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
            line.color = @"#404040";
            line.startPoint = CGPointMake(0, y);
            line.endPoint = CGPointMake(mainboxView.frame.size.width, y);
            [mainboxView addSubview:line];
        }
    }
}

#pragma mark 画k线 --- 在子线程里面,网络请求
-(void)drawLine{
    
    self.kCount = self.xWidth / (self.kLineWidth+self.kLinePadding) + 1; // K线中实体的总数
    getdata = [getData sharedGetData];
    getdata.scroolSpeed = (self.kLineWidth*10/15);
    getdata.kCount = self.kCount;
    
    panCount =   getdata.kPage * getdata.scroolSpeed;
    getdata.req_type = self.req_type;
    getdata = [getdata initWithUrl:[NSString stringWithFormat:urkKline,self.req_type]];
    
    self.data = getdata.data;
    self.category = getdata.category;
    
    // 开始画K线图
    [self drawBoxWithKline];
    
    if (_finishUpdateBlock && isPinch) {
        _finishUpdateBlock(self);
    }
    isUpdateFinish = YES;
    
}

#pragma mark 改变最大值和最小值
-(void)changeMaxAndMinValue{
    
    CGFloat padValue = (getdata.maxValue - getdata.minValue) / 6;
    getdata.maxValue += padValue;
    getdata.minValue -= padValue;
    
}
#pragma mark 均线重新赋值
- (void)hiddenAvgLine
{
    CGFloat itemPointX = 0;
    
    for (NSArray *item in pointArray) {
        CGPoint itemPoint = CGPointFromString([item objectAtIndex:3]);  // 收盘价的坐标
        
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = 0;
        
        if (itemX == pointX || 0 - itemX <= self.kLineWidth/2) {
            
            // 均线值显示
            MA5.text = [[NSString alloc] initWithFormat:@"MA5:%.2f",[[item objectAtIndex:5] floatValue]];
            [MA5 sizeToFit];
            MA10.text = [[NSString alloc] initWithFormat:@"MA10:%.2f",[[item objectAtIndex:6] floatValue]];
            [MA10 sizeToFit];
            MA10.frame = CGRectMake(MA5.frame.origin.x+MA5.frame.size.width+10, MA10.frame.origin.y, MA10.frame.size.width, MA10.frame.size.height);
            MA20.text = [[NSString alloc] initWithFormat:@"MA20:%.2f",[[item objectAtIndex:7] floatValue]];
            [MA20 sizeToFit];
            MA20.frame = CGRectMake(MA10.frame.origin.x+MA10.frame.size.width+10, MA20.frame.origin.y, MA20.frame.size.width, MA20.frame.size.height);
            break;
        }
    }
}

#pragma mark 在框框里画k线
-(void)drawBoxWithKline{
    
    [self changeMaxAndMinValue];
    // 平均线
    CGFloat padValue = (getdata.maxValue - getdata.minValue) / 6;
    CGFloat padRealValue = mainboxView.frame.size.height / 6;
    for (int i = 0; i<7; i++) {
        
        UILabel *left = (UILabel *)[mainboxView viewWithTag:i+10];
        if (left) {
            left.text = [[NSString alloc] initWithFormat:@"%.2f",padValue*i+getdata.minValue];
            
        }else{
            CGFloat y = mainboxView.frame.size.height-padRealValue * i;
            // lable
            left = [[UILabel alloc] initWithFrame:CGRectMake(-40, y-30/2, 38, 30)];
            left.tag = i+ 10;
            left.text = [[NSString alloc] initWithFormat:@"%.2f",padValue*i+getdata.minValue];
            left.textColor = [UIColor colorWithHexString:@"#080808" withAlpha:1];
            left.font = self.font;
            left.textAlignment = UITextAlignmentRight;
            left.backgroundColor = [UIColor clearColor];
            [mainboxView addSubview:left];
        }
    }
    
    // 开始画连接线
    // x轴从0 到 框框的宽度 mainboxView.frame.size.width 变化  y轴为每个间隔的连线，如，今天的点连接明天的点
    
    // MA5
    [self drawMAWithIndex:5 andColor:@"#8B008B"];
    // MA10
    [self drawMAWithIndex:6 andColor:@"#4B0082"];
    // MA20
    [self drawMAWithIndex:7 andColor:@"#CD8500"];
    
    
    // 开始画连K线
    // x轴从0 到 框框的宽度 mainboxView.frame.size.width 变化  y轴为每个间隔的连线，如，今天的点连接明天的点
    NSArray *ktempArray = [self changeKPointWithData:getdata.data]; // 换算成实际每天收盘价坐标数组
    
    lines *kline = (lines *)[mainboxView viewWithTag:99];
    if (kline) {
        kline.points = ktempArray;
        kline.lineWidth = self.kLineWidth;
        [kline setNeedsDisplay];
    }else{
        kline = [[lines alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
        kline.points = ktempArray;
        kline.tag = 99;
        kline.lineWidth = self.kLineWidth;
        kline.isK = YES;
        [mainboxView addSubview:kline];
    }
    
    // 开始画连成交量
    NSArray *voltempArray = [self changeVolumePointWithData:getdata.data]; // 换算成实际成交量坐标数组
    
    
    [self hiddenAvgLine];
    
    
    lines *volLine = (lines *)[bottomBoxView viewWithTag:98];
    if (volLine) {
        volLine.points = voltempArray;
        volLine.lineWidth = self.kLineWidth;
        volMaxValueLab.text = [Util changePrice:getdata.volMaxValue];
        [volLine setNeedsDisplay];
        
    }else{
        volLine = [[lines alloc] initWithFrame:CGRectMake(0, 0, bottomBoxView.frame.size.width, bottomBoxView.frame.size.height)];
        volLine.points = voltempArray;
        volLine.lineWidth = self.kLineWidth;
        volLine.tag = 98;
        volLine.isK = YES;
        volLine.isVol = YES;
        [bottomBoxView addSubview:volLine];
        volMaxValueLab.text = [Util changePrice:getdata.volMaxValue];
    }
}

#pragma mark 画各种均线
-(void)drawMAWithIndex:(int)index andColor:(NSString*)color{
    
    lines *lineAvg = (lines *)[mainboxView viewWithTag:avgLineTag+index];
    NSArray *tempArray = [self changePointWithData:getdata.data andMA:index]; // 换算成实际坐标数组
    if (lineAvg) {
        lineAvg.points = tempArray;
        [lineAvg setNeedsDisplay];
    }else{
        
        lineAvg = [[lines alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
        lineAvg.color = color;
        lineAvg.points = tempArray;
        lineAvg.tag = avgLineTag+index;
        lineAvg.isK = NO;
        [mainboxView addSubview:lineAvg];
        
    }
}

#pragma mark 手指捏合动作
-(void)touchBoxAction:(UIPinchGestureRecognizer*)pGesture{
    
    isPinch  = NO;
    if (pGesture.state==2 && isUpdateFinish) {
        if (pGesture.scale>1) {
            // 放大手势
            self.kLineWidth ++;
            [self updateSelf];
        }else{
            // 缩小手势
            self.kLineWidth --;
            [self updateSelf];
        }
    }
    if (pGesture.state==3) {
        isUpdateFinish = YES;
    }
}

#pragma mark - 拖拽手势
- (void)panGest:(UIPanGestureRecognizer *)pan
{
    isUpInSide = YES;
    // 给偏移量重新赋值
    if (getdata.isZoer) {
        panCount = 0;
    }else if (getdata.isPanChangeMax) {
        panCount = flagPanCount;
    }
    
    CGPoint point = [pan translationInView:mainboxView]; // 拖拽偏移量
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 手指离开屏幕，记录当前偏移量，开启滚动定时器
        isUpInSide = NO;
        panCount = point.x + panCount;
//        [_timer setFireDate:[NSDate distantPast]];
        CGPoint velocityPoint = [pan velocityInView:mainboxView]; // 拖拽速度
        [self countScrollOffset:velocityPoint.x];
        return;
    }
    scrollDirection = point.x;
    [self panUpDataView:point.x + panCount];
    
}
// 计算滚动偏移量
- (void)countScrollOffset:(CGFloat)offset
{
    
    // 数值都是调试出来的，大致在这个范围
    if (fabs(offset) > 2000) {
        if (fabs(offset) > 2000 && fabs(offset) < 3000) {
            tempPanOffset = (fabs(offset) - fabs(offset)/(pow((fabs(offset)/1000), 2)))/150;
        }else{
            tempPanOffset = (fabs(offset) - fabs(offset)/(pow((fabs(offset)/1000), 2)))/230;
            if (tempPanOffset >= 18) {
                tempPanOffset = 22;
            }
        }
    }else{
        tempPanOffset = fabs(offset)/100;
    }
}
// 滑动到最末尾的时候接受通知，记录下标
- (void)stopScroll:(NSNotification *)info
{
    if (!getdata.isPanChangeMax) {
        flagPanCount = [info.object intValue];
        
    }
    
    // 更新偏移量
    if (!isUpInSide) {
        panCount =   getdata.kPage * getdata.scroolSpeed;
    }
    // 停止定时器
    [_timer setFireDate:[NSDate distantFuture]];
    timerCount = 0;
}

// 利用定时器，模仿滑动效果
- (void)cunstomScroll
{
    timerCount++;
    
    // 滑动效果停止
    if (timerCount >= tempPanOffset) {
        // 更新偏移量
        if (!isUpInSide) {
            panCount =   getdata.kPage * getdata.scroolSpeed;
        }
        // 停止定时器
        [_timer setFireDate:[NSDate distantFuture]];
        timerCount = 0;
        
        return;
    }
    
    // 根据临时偏移量来控制滚动范围
    if (scrollDirection > tempPanOffset) {
        [self panUpDataView:panCount+timerCount*tempPanOffset];
    }else{
        [self panUpDataView:panCount-timerCount*tempPanOffset];
    }
}

// 拖拽手势，更新数据，重画视图
- (void)panUpDataView:(int)count
{
    if (isUpdateFinish) {
        
        isUpdateFinish = NO;
        isUpdate = YES;
        self.data = nil;
        self.category = nil;
        pointArray = nil;
    }
    
    [getdata panChangeDataSource:count];
    
    self.data = getdata.data;
    self.category = getdata.category;
    
    // 开始画K线图
    [self drawBoxWithKline];
    
    if (_finishUpdateBlock && isPinch) {
        _finishUpdateBlock(self);
    }
    
    isUpdateFinish = YES;
}


#pragma mark 长按就开始生成十字线
-(void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)longResture{
    
    isPinch = YES;
    NSLog(@"gestureRecognizerHandle%li",longResture.state);
    touchViewPoint = [longResture locationInView:mainboxView];
    // 手指长按开始时更新一般
    if(longResture.state == UIGestureRecognizerStateBegan){
        [self update];
    }
    // 手指移动时候开始显示十字线
    if (longResture.state == UIGestureRecognizerStateChanged) {
        [self isKPointWithPoint:touchViewPoint];
    }
    
    // 手指离开的时候移除十字线
    if (longResture.state == UIGestureRecognizerStateEnded) {
        [movelineone removeFromSuperview];
        [movelinetwo removeFromSuperview];
        [movelineoneLable removeFromSuperview];
        [movelinetwoLable removeFromSuperview];
        
        movelineone = nil;
        movelinetwo = nil;
        movelineoneLable = nil;
        movelinetwoLable = nil;
        isPinch = NO;
    }
}

#pragma mark 长按更新界面
-(void)updateNib{
    NSLog(@"block");
    if (movelineone==Nil) {
        movelineone = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1,bottomBoxView.frame.size.height+bottomBoxView.frame.origin.y)];
        movelineone.backgroundColor = [UIColor grayColor];
        [mainboxView addSubview:movelineone];
    }
    if (movelinetwo==Nil) {
        movelinetwo = [[UIView alloc] initWithFrame:CGRectMake(0,0, mainboxView.frame.size.width,1)];
        movelinetwo.backgroundColor = [UIColor grayColor];
        [mainboxView addSubview:movelinetwo];
    }
    if (movelineoneLable==Nil) {
        
        CGRect oneFrame = movelineone.frame;
        oneFrame.size = CGSizeMake(50, 12);
        movelineoneLable = [Util creatMovelLineLabelFrame:oneFrame];
        [mainboxView addSubview:movelineoneLable];
    }
    if (movelinetwoLable==Nil) {
        
        CGRect oneFrame = movelinetwo.frame;
        oneFrame.size = CGSizeMake(50, 12);
        movelinetwoLable = [Util creatMovelLineLabelFrame:oneFrame];
        [mainboxView addSubview:movelinetwoLable];
    }
    
    movelineone.frame = CGRectMake(touchViewPoint.x,0, 1,bottomBoxView.frame.size.height+bottomBoxView.frame.origin.y);
    movelinetwo.frame = CGRectMake(0,touchViewPoint.y, mainboxView.frame.size.width,1);
    CGRect oneFrame = movelineone.frame;
    oneFrame.size = CGSizeMake(50, 12);
    movelineoneLable.frame = oneFrame;
    CGRect towFrame = movelinetwo.frame;
    towFrame.size = CGSizeMake(50, 12);
    movelinetwoLable.frame = towFrame;
    
    [self isKPointWithPoint:touchViewPoint];
}

#pragma mark 把股市数据换算成实际的点坐标数组  MA = 5 为MA5 MA=6 MA10  MA7 = MA20
-(NSArray*)changePointWithData:(NSArray*)data andMA:(int)MAIndex{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    CGFloat PointStartX = 0.0f; // 起始点坐标
    for (NSArray *item in data) {
        
        CGFloat currentValue = [[item objectAtIndex:MAIndex] floatValue];// 得到前五天的均价价格
        
        // 换算成实际的坐标
        CGFloat currentPointY = mainboxView.frame.size.height - ((currentValue - getdata.minValue) / (getdata.maxValue - getdata.minValue) * mainboxView.frame.size.height);
        CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
        [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    
    return tempArray;
}


#pragma mark 把股市数据换算成实际的点坐标数组
-(NSArray*)changeKPointWithData:(NSArray*)data{
    //    NSLog(@"data = %@",data);
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    pointArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2; // 起始点坐标
    for (NSArray *item in data) {
        CGFloat heightvalue = [[item objectAtIndex:1] floatValue];// 得到最高价
        CGFloat lowvalue = [[item objectAtIndex:2] floatValue];// 得到最低价
        CGFloat openvalue = [[item objectAtIndex:0] floatValue];// 得到开盘价
        CGFloat closevalue = [[item objectAtIndex:3] floatValue];// 得到收盘价
        CGFloat yHeight = getdata.maxValue - getdata.minValue ; // y的价格高度
        CGFloat yViewHeight = mainboxView.frame.size.height ;// y的实际像素高度
        
        // 换算成实际的坐标
        CGFloat heightPointY = yViewHeight * (1 - (heightvalue - getdata.minValue) / yHeight);
        CGPoint heightPoint =  CGPointMake(PointStartX, heightPointY); // 最高价换算为实际坐标值
        CGFloat lowPointY = yViewHeight * (1 - (lowvalue - getdata.minValue) / yHeight);;
        CGPoint lowPoint =  CGPointMake(PointStartX, lowPointY); // 最低价换算为实际坐标值
        CGFloat openPointY = yViewHeight * (1 - (openvalue - getdata.minValue) / yHeight);;
        CGPoint openPoint =  CGPointMake(PointStartX, openPointY); // 开盘价换算为实际坐标值
        CGFloat closePointY = yViewHeight * (1 - (closevalue - getdata.minValue) / yHeight);;
        CGPoint closePoint =  CGPointMake(PointStartX, closePointY); // 收盘价换算为实际坐标值
        // 实际坐标组装为数组
        NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                 NSStringFromCGPoint(heightPoint),
                                 NSStringFromCGPoint(lowPoint),
                                 NSStringFromCGPoint(openPoint),
                                 NSStringFromCGPoint(closePoint),
                                 [self.category objectAtIndex:[data indexOfObject:item]], // 保存日期时间
                                 [item objectAtIndex:3], // 收盘价
                                 [item objectAtIndex:5], // MA5
                                 [item objectAtIndex:6], // MA10
                                 [item objectAtIndex:7], // MA20
                                 nil];
        [tempArray addObject:currentArray]; // 把坐标添加进新数组
        //      [pointArray addObject:[NSNumber numberWithFloat:PointStartX]];
        currentArray = Nil;
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
        
        // 在成交量视图左右下方显示开始和结束日期
        if ([data indexOfObject:item] == 0) {
            startDateLab.text = [self.category objectAtIndex:[data indexOfObject:item]];
        }
        if ([data indexOfObject:item] == data.count-1) {
            endDateLab.text = [self.category objectAtIndex:[data indexOfObject:item]];
        }
    }
    pointArray = tempArray;
    return tempArray;
}

#pragma mark 把股市数据换算成成交量的实际坐标数组
-(NSArray*)changeVolumePointWithData:(NSArray*)data{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2; // 起始点坐标
    for (NSArray *item in data) {
        CGFloat volumevalue = [[item objectAtIndex:4] floatValue];// 得到没份成交量
        CGFloat yHeight = getdata.volMaxValue - getdata.volMinValue ; // y的价格高度
        CGFloat yViewHeight = bottomBoxView.frame.size.height ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY = yViewHeight * (1 - (volumevalue - getdata.volMinValue) / yHeight);
        CGPoint volumePoint =  CGPointMake(PointStartX, volumePointY); // 成交量换算为实际坐标值
        CGPoint volumePointStart = CGPointMake(PointStartX, yViewHeight);
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = [[item objectAtIndex:0] floatValue];// 得到开盘价
        CGFloat closevalue = [[item objectAtIndex:3] floatValue];// 得到收盘价
        CGPoint openPoint =  CGPointMake(PointStartX, closevalue); // 开盘价换算为实际坐标值
        CGPoint closePoint =  CGPointMake(PointStartX, openvalue); // 收盘价换算为实际坐标值
        
        // 实际坐标组装为数组
        NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                 NSStringFromCGPoint(volumePointStart),
                                 NSStringFromCGPoint(volumePoint),
                                 NSStringFromCGPoint(openPoint),
                                 NSStringFromCGPoint(closePoint),
                                 nil];
        [tempArray addObject:currentArray]; // 把坐标添加进新数组
        currentArray = Nil;
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
        
    }
    
    
    return tempArray;
}

#pragma mark 判断并在十字线上显示提示信息
-(void)isKPointWithPoint:(CGPoint)point{
    
    NSLog(@"pointx = %f",point.x);
    CGFloat itemPointX = 0;
    for (NSArray *item in pointArray) {
        CGPoint itemPoint = CGPointFromString([item objectAtIndex:3]);  // 收盘价的坐标
        
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = (int)point.x;
        
        if (itemX==pointX || point.x-itemX <= self.kLineWidth/2) {
            
            movelineone.frame = CGRectMake(itemPointX,movelineone.frame.origin.y, movelineone.frame.size.width, movelineone.frame.size.height);
            movelinetwo.frame = CGRectMake(movelinetwo.frame.origin.x,itemPoint.y, movelinetwo.frame.size.width, movelinetwo.frame.size.height);
            // 垂直提示日期控件
            movelineoneLable.text = [item objectAtIndex:4]; // 日期
            CGFloat oneLableY = bottomBoxView.frame.size.height+bottomBoxView.frame.origin.y;
            CGFloat oneLableX = 0;
            if (itemPointX<movelineoneLable.frame.size.width/2) {
                oneLableX = movelineoneLable.frame.size.width/2 - itemPointX;
            }
            if ((mainboxView.frame.size.width - itemPointX)<movelineoneLable.frame.size.width/2) {
                oneLableX = -(movelineoneLable.frame.size.width/2 - (mainboxView.frame.size.width - itemPointX));
            }
            movelineoneLable.frame = CGRectMake(itemPointX - movelineoneLable.frame.size.width/2 + oneLableX, oneLableY,
                                                movelineoneLable.frame.size.width, movelineoneLable.frame.size.height);
            // 横向提示价格控件
            movelinetwoLable.text = [[NSString alloc] initWithFormat:@"%@",[item objectAtIndex:5]]; // 收盘价
            CGFloat twoLableX ;
            // 如果滑动到了左半边则提示向右跳转
            if ((mainboxView.frame.size.width - itemPointX) > mainboxView.frame.size.width/2) {
                twoLableX = mainboxView.frame.size.width - movelinetwoLable.frame.size.width;
            }else{
                twoLableX = 0;
            }
            
            
            movelinetwoLable.frame = CGRectMake(twoLableX,itemPoint.y - movelinetwoLable.frame.size.height/2 ,
                                                movelinetwoLable.frame.size.width, movelinetwoLable.frame.size.height);
            // 均线值显示
            
            MA5.text = [[NSString alloc] initWithFormat:@"MA5:%.2f",[[item objectAtIndex:5] floatValue]];
            [MA5 sizeToFit];
            MA10.text = [[NSString alloc] initWithFormat:@"MA10:%.2f",[[item objectAtIndex:6] floatValue]];
            [MA10 sizeToFit];
            MA10.frame = CGRectMake(MA5.frame.origin.x+MA5.frame.size.width+10, MA10.frame.origin.y, MA10.frame.size.width, MA10.frame.size.height);
            MA20.text = [[NSString alloc] initWithFormat:@"MA20:%.2f",[[item objectAtIndex:7] floatValue]];
            [MA20 sizeToFit];
            MA20.frame = CGRectMake(MA10.frame.origin.x+MA10.frame.size.width+10, MA20.frame.origin.y, MA20.frame.size.width, MA20.frame.size.height);
            break;
        }
    }
}

-(void)didReceiveMemoryWarning{
    NSLog(@"内存消耗过大\n\n---------------------------------");
}

@end
