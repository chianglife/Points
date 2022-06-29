//
//  VariousThreadViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/29.
//

#import "VariousThreadViewController.h"

@interface VariousThreadViewController ()

@end

@implementation VariousThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSThread & GCD & NSOperation";
    [self test_createNSTread];
}

- (void)test_createNSTread {
    
    //方式一：初始化方式，需要手动启动
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething:) object:@"thread1"];
    [thread1 start];

    //方式二：构造器方式，自动启动
    [NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:@"thread2"];

    //方式三：performSelector...方法创建,主要是用于获取主线程，以及后台线程
    [self performSelectorInBackground:@selector(doSomething:) withObject:@"thread3"];
    [self performSelectorOnMainThread:@selector(doSomething:) withObject:@"thread4" waitUntilDone:YES];
}

- (void)doSomething:(NSObject *)objc {
    //如果number=1，则表示在主线程，否则是子线程
    NSLog(@"\n%@ : %@\n", objc, [NSThread currentThread]);
}


- (void)test_dispatch_once{
    /*
     dispatch_once保证在App运行期间，block中的代码只执行一次
     应用场景：单例、method-Swizzling
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //创建单例、method swizzled或其他任务
        NSLog(@"创建单例");
    });
}

@end
