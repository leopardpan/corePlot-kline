//
//  StockCrossShapedView.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "StockCrossShapedView.h"
#import "UIColor+Style.h"

#define DEFAULT_LABEL_WIDTH 35.0
#define DEFAULT_LABEL_HEIGHT 20.0
#define DEFAULT_LABEL_PADDING 3.0

#define LABEL_BGCOLOR @"#C67171"
#define LINE_COLOR @"#6b3c0d"
#define LABEL_TEXTCOLOR @"#ffffff"

@implementation StockCrossShapedView
- (id) initWithFrame:(CGRect)frame drawInfo:(StockDrawInfo)mDrawInfo gesture:(StockGesture)mGesture delegate:(id)mDelegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化数据
        delegate = mDelegate;
        
        showCrossShaped = NO;
        drawInfo = mDrawInfo;
        
        StockPadding mPadding = {0.0f, 0.0f, 0.0f, 0.0f};
        padding = mPadding;
        
        point = CGPointMake(0, 0);
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        // 绑定手势
        if (mGesture.tap) {
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventHandle:)];
            // 手指数
            tapGesture.numberOfTouchesRequired = 1;
            // tap次数
            tapGesture.numberOfTapsRequired = 1;
            [self addGestureRecognizer:tapGesture];
        }
        if (mGesture.pan) {
            panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventHandle:)];
            [self addGestureRecognizer:panGesture];
        }
        if (mGesture.pinch) {
            pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEventHandle:)];
            [self addGestureRecognizer:pinchGesture];
        }
    }
    return self;
}

#pragma mark -
#pragma mark 手势处理方法，具体处理操作全部交给委托
- (void)pinchEventHandle:(UIPinchGestureRecognizer *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(whenPinchEvent:)]) {
        [delegate whenPinchEvent:sender];
    }
}

- (void)tapEventHandle:(UITapGestureRecognizer *)sender
{
    if(sender.numberOfTapsRequired == 1) {
        //单指单击
        if (delegate && [delegate respondsToSelector:@selector(whenTapEvent:)]) {
            [delegate whenTapEvent:sender];
        }
    }else if(sender.numberOfTapsRequired == 2){
        //单指双击 do nothing
    }
}

- (void)panEventHandle:(UIPanGestureRecognizer *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(whenPanEvent:)]) {
        [delegate whenPanEvent:sender];
    }
}
#pragma mark -
#pragma mark 覆写drawRect方法
// 先移除全部label，计算坐标绘制垂直线及水平线，绘制四周显示的值
- (void)drawRect:(CGRect)rect
{
    // 先清除所有子view
    for (UIView *subView in [self subviews]) {
        [subView removeFromSuperview];
    }
    if (point.x == 0 && point.y == 0) {
        return;
    }
    if (!showCrossShaped) {
        return;
    }
    
    CGFloat leftPos = padding.left;
    CGFloat topPos = padding.top;
    CGFloat rightPos = self.frame.size.width - padding.right;
    CGFloat bottomPos = self.frame.size.height- padding.bottom;
    
    // 设置线参数
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexString:LINE_COLOR] CGColor]);
    
    // 绘制虚线
    CGFloat lenghts[] = {3.0f, 2.0f};
    CGContextSetLineDash(context, 0, lenghts, 2);
    
    // 绘制竖直线
    CGContextMoveToPoint(context, point.x, topPos);
    CGContextAddLineToPoint(context, point.x, bottomPos);
    CGContextStrokePath(context);
    
    if (drawInfo.showHorizontal) {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexString:LINE_COLOR] CGColor]);
        // 绘制横直线
        CGContextMoveToPoint(context, leftPos, point.y);
        CGContextAddLineToPoint(context, rightPos, point.y);
        CGContextStrokePath(context);
    }
    for(NSString *key in [arroundValue allKeys]){
        [self drawLabelWithTag:key];
    }
}
#pragma mark -
#pragma mark 自定义方法
// 绘制十字线，交由uiviewcontroller调用
- (void)drawCrossShapedAtPoint:(CGPoint)mPoint showCrossShaped:(BOOL)mShowCrossShaped padding:(StockPadding)mPadding arroundValue:(NSDictionary *)mArround
{
    showCrossShaped = mShowCrossShaped;
    padding = mPadding;
    arroundValue = mArround;
    point.x = mPoint.x;
    point.y = mPoint.y;
    
    [self setNeedsDisplay];
}
// 根据tag绘制四周的值
- (void) drawLabelWithTag:(NSString *)tag
{
    if ([tag isEqualToString:TAG_BOTTOM] && !drawInfo.showBottom) {
        return;
    } else if ([tag isEqualToString:TAG_TOP] && !drawInfo.showTop) {
        return;
    } else if ([tag isEqualToString:TAG_LEFT] && !drawInfo.showLeft) {
        return;
    } else if ([tag isEqualToString:TAG_RIGHT] && !drawInfo.showRight) {
        return;
    }
    
    NSObject *value = [arroundValue objectForKey:tag];
    if (!value) {
        return;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:[self frameWithTag:tag]];
    label.backgroundColor = [UIColor colorWithHexString:LABEL_BGCOLOR];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    //    label.alpha = 0.3;
    if ([tag isEqualToString:TAG_TOP]) {
        label.textAlignment = NSTextAlignmentLeft;
    }
    //    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    label.font = [UIFont systemFontOfSize:12];
    //超过长度时添加上省略号
    //    label.textColor = [UIColor colorWithHexString:LABEL_TEXTCOLOR];
    label.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *mvalue = (NSNumber *)value;
        [label setText:[mvalue stringValue]];
    } else {
        NSString *mvalue = (NSString *)value;
        [label setText:mvalue];
    }
    [self addSubview:label];
}
// 计算绘制的label的frame
- (CGRect) frameWithTag:(NSString *)tag
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat widht = DEFAULT_LABEL_WIDTH;
    CGFloat height = DEFAULT_LABEL_HEIGHT;
    if ([tag isEqualToString:TAG_LEFT]) {
        x = padding.left - DEFAULT_LABEL_WIDTH - DEFAULT_LABEL_PADDING;
        y = point.y - height / 2;
    } else if ([tag isEqualToString:TAG_TOP]) {
        //        widht = self.frame.size.width - padding.left - padding.right;
        widht = self.frame.size.width;
        //        x = padding.left;
        x = 0;
        height = DEFAULT_LABEL_HEIGHT;
        y = padding.top;
    } else if ([tag isEqualToString:TAG_RIGHT]) {
        x = self.frame.size.width - padding.right + DEFAULT_LABEL_PADDING;
        y = point.y - height / 2;
    } else if ([tag isEqualToString:TAG_BOTTOM]) {
        widht = DEFAULT_LABEL_WIDTH * 2;
        x = point.x - widht / 2;
        y = self.frame.size.height - padding.bottom + DEFAULT_LABEL_PADDING + 10;
    }
    //    NSLog(@"lable frame = %@",NSStringFromCGRect(CGRectMake(x, y, widht, height)));
    return CGRectMake(x, y, widht, height);
}


@end
