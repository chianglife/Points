//
//  MemoryAreaViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/28.
//

#import "MemoryAreaViewController.h"

@interface MemoryAreaViewController ()

@property(nonatomic, strong)NSString *area1;
@property(nonatomic, strong)NSString *area2;
@property(nonatomic, strong)NSObject *object;

@end

@implementation MemoryAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"内存五区";
    
    [self test];
}

/*  iOS主线程栈大小是1MB
    其他线程是512KB
    MAC只有8M
 */

- (void)test{
    //地址最高的是栈区,栈区是连续的，向低地址扩展
    //其次是堆区，不是连续的，向高地址扩展
    
    NSInteger i = 123;
    NSLog(@"i的内存地址：%p", &i);//栈区

    NSString *string = @"Chiang";
    NSLog(@"string的内存地址：%p", string);//常量区
    NSLog(@"&string的内存地址：%p", &string);//栈区
    
    NSObject *obj = [[NSObject alloc] init];
    NSLog(@"obj的内存地址：%p", obj);//堆区
    NSLog(@"&obj的内存地址：%p", &obj);//栈区
    
    NSObject *obj1 = [[NSObject alloc] init];
    NSLog(@"obj的内存地址：%p", obj1);//堆区
    NSLog(@"&obj的内存地址：%p", &obj1);//栈区
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    NSLog(@"%p", self);
}
@end
