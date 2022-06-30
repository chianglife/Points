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
//    [self test_createNSTread];
//    [self test_dispatch_apply];
//    [self test_dispatch_group2];
    [self test_dispatch_group_wait];
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

- (void)test_dispatch_apply{
    /*
     dispatch_apply将指定的Block追加到指定的队列中重复执行，并等到全部的处理执行结束——相当于线程安全的for循环

     应用场景：用来拉取网络数据后提前算出各个控件的大小，防止绘制时计算，提高表单滑动流畅性
     - 添加到串行队列中——按序执行
     - 添加到主队列中——死锁
     - 添加到并发队列中——乱序执行
     - 添加到全局队列中——乱序执行
     */
    
    dispatch_queue_t queue = dispatch_queue_create("Chiang", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"dispatch_apply前");
    /**
         param1：重复次数
         param2：追加的队列
         param3：执行任务
         */
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"dispatch_apply 的线程 %zu - %@", index, [NSThread currentThread]);
    });
    NSLog(@"dispatch_apply后");
}


- (void)test_dispatch_group1{
    /*
     dispatch_group_t：调度组将任务分组执行，能监听任务组完成，并设置等待时间

     应用场景：多个接口请求之后刷新页面
     */
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"请求一完成");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"请求二完成");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新页面");
    });
}

- (void)test_dispatch_group2{
    /*
     dispatch_group_enter和dispatch_group_leave成对出现，使进出组的逻辑更加清晰
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"请求一完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"请求二完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新界面");
    });
}


- (void)test_dispatch_group_wait{
    /*
     long dispatch_group_wait(dispatch_group_t group, dispatch_time_t timeout)

     group：需要等待的调度组
     timeout：等待的超时时间（即等多久）
        - 设置为DISPATCH_TIME_NOW意味着不等待直接判定调度组是否执行完毕
        - 设置为DISPATCH_TIME_FOREVER则会阻塞当前调度组，直到调度组执行完毕


     返回值：为long类型
        - 返回值为0——在指定时间内调度组完成了任务
        - 返回值不为0——在指定时间内调度组没有按时完成任务

     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"请求一完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"请求二完成");
        dispatch_group_leave(group);
    });
//    long timeout = dispatch_group_wait(group, DISPATCH_TIME_NOW);
//    long timeout = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    long timeout = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 1 *NSEC_PER_SEC));
    NSLog(@"timeout = %ld", timeout);
    if (timeout == 0) {
        NSLog(@"按时完成任务");
    }else{
        NSLog(@"超时");
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新界面");
    });
}
@end
