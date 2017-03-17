//
//  ViewController.m
//  SQLiteUseInAPP
//
//  Created by 敬庭超 on 2017/3/16.
//  Copyright © 2017年 敬庭超. All rights reserved.
//

#import "ViewController.h"
#import "Product.h"
#import "DBAccess.h"
@interface ViewController ()
@property(nonatomic,strong) NSMutableArray  *products;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DBAccess *dbAccess = [[DBAccess alloc] init];
    self.products = [dbAccess getAllProducts];
    //使用完成之后，一定要关闭
    [dbAccess closeDatabase];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.products.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.products[indexPath.row] name];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
