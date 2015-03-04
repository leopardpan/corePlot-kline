//
//  getData.h
//  Kline
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface getData : NSObject
@property (nonatomic,retain) NSMutableArray *data;
@property (nonatomic,retain) NSArray *dayDatas;
@property (nonatomic,retain) NSMutableArray *category;
@property (nonatomic,retain) NSString *lastTime;
@property (nonatomic,assign) BOOL isFinish;
@property (nonatomic,assign) CGFloat maxValue;
@property (nonatomic,assign) CGFloat minValue;
@property (nonatomic,assign) CGFloat volMaxValue;
@property (nonatomic,assign) CGFloat volMinValue;
@property (nonatomic,assign) NSInteger kCount;
@property (nonatomic,retain) NSString *req_type;

/** 判断是否要把拖动清零*/
@property (nonatomic, assign) BOOL isZoer;

/** 判断是否要把拖动变成最大值*/
@property (nonatomic, assign) BOOL isPanChangeMax;

/** 拖动时候的滑动速度*/
@property (nonatomic, assign) CGFloat scroolSpeed;

/** 记录滑动的位置*/
@property (nonatomic,assign) NSInteger kPage;

/**
 *  拖拽手势
 *
 *  @param panCount 拖拽偏移量
 */
- (void)panChangeDataSource:(int)panCount;

-(id)initWithUrl:(NSString*)url;

+ (id)sharedGetData;

@end
