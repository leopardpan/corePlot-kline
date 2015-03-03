//
//  ViewController.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "ViewController.h"
#import "StockKlineViewController.h"

@interface ViewController ()

@property (nonatomic, strong) StockKlineViewController* klineVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    StockKlineViewController *klineVC = [[StockKlineViewController alloc] init];
    self.klineVC = klineVC;

    self.klineVC.view.frame = self.view.frame;
    [self.view addSubview:self.klineVC.view];

    [self addChildViewController:klineVC];

}

@end
