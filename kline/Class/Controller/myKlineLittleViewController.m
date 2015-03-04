//
//  myKlineLittleViewController.m
//  kline
//
//  Created by leopard on 15-3-4.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "myKlineLittleViewController.h"
#import "StockKlineViewController.h"

@interface myKlineLittleViewController()
@property (nonatomic, strong) StockKlineViewController* klineVC;

@end

@implementation myKlineLittleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    StockKlineViewController *klineVC = [[StockKlineViewController alloc] init];
    self.klineVC = klineVC;
    self.klineVC.isHorizontal = YES;
    self.klineVC.view.frame = CGRectMake(64, 0, self.view.frame.size.height, self.view.frame.size.width);
    [self.view addSubview:self.klineVC.view];
    
    [self addChildViewController:klineVC];
    
}
@end
