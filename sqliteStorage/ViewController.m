//
//  ViewController.m
//  sqliteStorage
//
//  Created by 爱赚校园 on 16/3/29.
//  Copyright © 2016年 ck_chan. All rights reserved.
//

#import "ViewController.h"
#import "CKSqlStorage.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[CKSqlStorage shareInstance] setValue:@"89757" forKey:KEY_USER_UID];
    [[CKSqlStorage shareInstance] setValue:@"CK_chan" forKey:KEY_USER_NAME];
    [[CKSqlStorage shareInstance] setValue:@"020-100000" forKey:KEY_USER_PHONE];
    
    NSLog(@"%@  %@",[[CKSqlStorage shareInstance] getValueForKey:KEY_USER_NAME], [[CKSqlStorage shareInstance] getValueForKey:KEY_USER_PHONE]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
