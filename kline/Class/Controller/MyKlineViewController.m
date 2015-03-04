//
//  MyKlineViewController.m
//  kline
//
//  Created by leopard on 15-3-4.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "MyKlineViewController.h"
#import "StockKlineViewController.h"

@interface MyKlineViewController()
@property (nonatomic, strong) StockKlineViewController* klineVC;

@end

@implementation MyKlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    StockKlineViewController *klineVC = [[StockKlineViewController alloc] init];
    self.klineVC = klineVC;
    
    self.klineVC.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    [self.view addSubview:self.klineVC.view];
    
    [self addChildViewController:klineVC];
    
}
@end
