//
//  KVOViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/27.
//

#import "KVOViewController.h"
#import "BaseTestModel.h"

@interface KVOViewController ()
@property(nonatomic, strong)BaseTestModel *test;
@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KVO";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStylePlain target:self action:@selector(push)];

    self.test = [BaseTestModel sharedInstance];
    [self.test addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)push {
    KVOViewController *vc = [[KVOViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.test.value2 = @"1";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@ - %@",keyPath, change);
}

- (void)dealloc {
    //此时如果不移除观察者，会有类似野指针崩溃。
    //多次增加观察者，如果观察者被释放之前没有移除，属性变化的时候会通知所有观察者，而观察者被释放，形成野指针
    [self.test removeObserver:self forKeyPath:@"count"];
}
@end
