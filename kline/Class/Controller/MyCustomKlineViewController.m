//
//  MyCustomKlineViewController.m
//  kline
//
//  Created by leopard on 15-3-4.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "MyCustomKlineViewController.h"
#import "lineView.h"
#import "UIColor+helper.h"
#import "Util.h"

@interface MyCustomKlineViewController()
{
    lineView *lineview;
    Util *util;
}

@end


@implementation MyCustomKlineViewController

-(void)viewDidLoad{
    
    util = [[Util alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *btnDay = [util initializeCustomButtonFrame:CGRectMake(20, 70, 50, 30) title:@"日K" target:self action:@selector(kLine:)];
    [self.view addSubview:btnDay];
    
    UIButton *btnWeek = [util initializeCustomButtonFrame:CGRectMake(75, 70, 50, 30) title:@"周K" target:self action:@selector(kLine:)];
    [self.view addSubview:btnWeek];
    
    UIButton *btnMooth = [util initializeCustomButtonFrame:CGRectMake(130, 70, 50, 30) title:@"月K" target:self action:@selector(kLine:)];
    [self.view addSubview:btnMooth];
    
    // 放大
    UIButton *btnBig = [util initializeCustomButtonFrame:CGRectMake(185, 70, 50, 30) title:@"+" target:self action:@selector(kBigLine)];
    [self.view addSubview:btnBig];
    
    // 缩小
    UIButton *btnSmall = [util initializeCustomButtonFrame:CGRectMake(240, 70, 50, 30) title:@"-" target:self action:@selector(kSmallLine)];
    [self.view addSubview:btnSmall];
    
    
    // 添加k线图
    lineview = [[lineView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height-120)];

//    [lineview setFrame:CGRectMake(0, 120, 600, 300)];
    lineview.req_type = @"day";
    lineview.kLineWidth = 5;
    lineview.kLinePadding = 0.5;
    [self.view addSubview:lineview];
    [lineview start]; // k线图运行
    
}

- (void)kLine:(UIButton *)sender
{
    if ([sender.currentTitle isEqualToString:@"日K"]) {
        lineview.req_type = @"day";
    }else if ([sender.currentTitle isEqualToString:@"周K"]){
        lineview.req_type = @"week";
    }else if ([sender.currentTitle isEqualToString:@"月K"]){
        if (lineview.kLineWidth < 5) {
            lineview.kLineWidth = 5;
        }
        
        lineview.req_type = @"month";
    }else{
        NSLog(@"没有参数");
    }
    
    [lineview update];
}

-(void)kBigLine{
    
    lineview.kLineWidth += 1;
    [self kUpdate];
}

-(void)kSmallLine{
    lineview.kLineWidth -= 1;
    [self kUpdate];
}

-(void)kUpdate{
    
    [lineview update];
}


@end
