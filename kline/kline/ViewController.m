//
//  ViewController.m
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#import "ViewController.h"
#import "MyKlineViewController.h"
#import "CorePlotKlineViewController.h"
#import "MyCustomKlineViewController.h"


@interface ViewController()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *tableViewDataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = @[@"MyKlineViewController",@"CorePlotKlineViewController",@"MyCustomKlineViewController"];
    self.tableViewDataSource =  data;
    
    [self creatUI];

}
- (void)creatUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewDataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID= @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = self.tableViewDataSource[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class vcName = NSClassFromString(self.tableViewDataSource[indexPath.row]);
    UIViewController *vc = [[vcName alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
