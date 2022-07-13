//
//  LittleTestViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/7/13.
//

#import "LittleTestViewController.h"

@interface LittleTestViewController ()
@property(nonatomic, strong)UIView *testView;

@end

@implementation LittleTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小测试";

    _testView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 200, 200)];
    _testView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_testView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapEvent {
    
    if (_testView.frame.size.height == 200) {
        _testView.frame = CGRectMake(0, 64, 400, 400);
    } else {
        _testView.frame = CGRectMake(0, 64, 200, 200);
    }
    
    [UIView animateWithDuration:3 animations:^{
        _testView.alpha = 0;
    }];
}

@end
