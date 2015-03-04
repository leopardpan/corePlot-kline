//
//  MyKlineViewController.m
//  kline
//
//  Created by leopard on 15-3-4.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "MyKlineViewController.h"
#import "StockKlineViewController.h"
#import "myKlineLittleViewController.h"

@interface MyKlineViewController()
@property (nonatomic, strong) StockKlineViewController* klineVC;

@end

@implementation MyKlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//     self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    StockKlineViewController *klineVC = [[StockKlineViewController alloc] init];
    self.klineVC              = klineVC;
    self.klineVC.isHorizontal = NO;
    self.klineVC.view.frame   = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    [self.view addSubview:self.klineVC.view];
    
    [self addChildViewController:klineVC];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 40, 60)];
    [btn setTitle:@"横屏" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(enterHorizontal:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = item;
   
}

- (void)enterHorizontal:(UIButton *)sender
{
    myKlineLittleViewController *littlrVC = [[myKlineLittleViewController alloc] init];
    [self.navigationController pushViewController:littlrVC animated:YES];

}
@end
