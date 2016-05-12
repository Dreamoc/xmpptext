//
//  ViewController.m
//  xmpptext
//
//  Created by eall_linger on 16/4/26.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%d",[[XMPPManager sharedInstance] connect]);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onclick:(id)sender {
    [[XMPPManager sharedInstance] sendMsg:@"123"];
}

@end
