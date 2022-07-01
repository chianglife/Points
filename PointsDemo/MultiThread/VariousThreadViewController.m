//
//  VariousThreadViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/29.
//

#import "VariousThreadViewController.h"

@interface VariousThreadViewController ()
//@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation VariousThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSThread & GCD & NSOperation";
//    [self test_createNSTread];
//    [self test_dispatch_apply];
//    [self test_dispatch_group2];
//    [self test_dispatch_group_wait];
//    [self test_dispatch_barrier_serial];
//    [self test_semaphore];
//    [self test_dispatch_source];
//    [self test_NSInvocationOperation];
//    [self test_NSBlockOperation];
//    [self test_TestOperation];
//    [self test_NSOperationQueue];
//    [self test_queueSequence];
//    [self test_operationQuality];
//    [self test_operationMaxCount];
//    [self test_operationDependency];
    [self test_operationNoti];
}

#pragma mark - NSThread

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


#pragma mark - GCD

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


- (void)test_dispatch_barrier_serial{
    //串行队列使用栅栏函数
    
    dispatch_queue_t queue = dispatch_queue_create("Chiang", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"开始 - %@", [NSThread currentThread]);
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"延迟2s的任务1 - %@", [NSThread currentThread]);
    });
    NSLog(@"第一次结束 - %@", [NSThread currentThread]);
    
    //栅栏函数的作用是将队列中的任务进行分组，所以我们只要关注任务1、任务2
    dispatch_barrier_async(queue, ^{
        NSLog(@"------------栅栏任务------------%@", [NSThread currentThread]);
    });
    NSLog(@"栅栏结束 - %@", [NSThread currentThread]);
    
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"延迟2s的任务2 - %@", [NSThread currentThread]);
    });
    NSLog(@"第二次结束 - %@", [NSThread currentThread]);
}

- (void)test_dispatch_barrier_concurrent{
    //并发队列使用栅栏函数
    
    dispatch_queue_t queue = dispatch_queue_create("Chiang", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"开始 - %@", [NSThread currentThread]);
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"延迟2s的任务1 - %@", [NSThread currentThread]);
    });
    NSLog(@"第一次结束 - %@", [NSThread currentThread]);
    
    //由于并发队列异步执行任务是乱序执行完毕的，所以使用栅栏函数可以很好的控制队列内任务执行的顺序
    dispatch_barrier_async(queue, ^{
        NSLog(@"------------栅栏任务------------%@", [NSThread currentThread]);
    });
    NSLog(@"栅栏结束 - %@", [NSThread currentThread]);
    
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"延迟2s的任务2 - %@", [NSThread currentThread]);
    });
    NSLog(@"第二次结束 - %@", [NSThread currentThread]);
}


- (void)test_semaphore{
    /*
     应用场景：同步当锁, 控制GCD最大并发数

     - dispatch_semaphore_create()：创建信号量
     - dispatch_semaphore_wait()：等待信号量，信号量减1。当信号量< 0时会阻塞当前线程，根据传入的等待时间决定接下来的操作——如果永久等待将等到信号（signal）才执行下去
     - dispatch_semaphore_signal()：释放信号量，信号量加1。当信号量>= 0 会执行wait之后的代码

     */
    dispatch_queue_t queue = dispatch_queue_create("Chiang", DISPATCH_QUEUE_CONCURRENT);
    
//    for (int i = 0; i < 10; i++) {
//        dispatch_async(queue, ^{
//            NSLog(@"当前 - %d， 线程 - %@", i, [NSThread currentThread]);
//        });
//    }
    
    //利用信号量来改写
    //如果是0，wait在signal后面，则最大并发为1，等同于串行队列
    //如果是1，wait在signal前面，则最大并发为1，等同于串行队列
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"当前 - %d， 线程 - %@", i, [NSThread currentThread]);
            
            dispatch_semaphore_signal(sem);
        });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
}


- (void)test_dispatch_source{
    /*
     dispatch_source
     
     应用场景：GCDTimer
     在iOS开发中一般使用NSTimer来处理定时逻辑，但NSTimer是依赖Runloop的，而Runloop可以运行在不同的模式下。如果NSTimer添加在一种模式下，当Runloop运行在其他模式下的时候，定时器就挂机了；又如果Runloop在阻塞状态，NSTimer触发时间就会推迟到下一个Runloop周期。因此NSTimer在计时上会有误差，并不是特别精确，而GCD定时器不依赖Runloop，计时精度要高很多
     
     dispatch_source是一种基本的数据类型，可以用来监听一些底层的系统事件
        - Timer Dispatch Source：定时器事件源，用来生成周期性的通知或回调
        - Signal Dispatch Source：监听信号事件源，当有UNIX信号发生时会通知
        - Descriptor Dispatch Source：监听文件或socket事件源，当文件或socket数据发生变化时会通知
        - Process Dispatch Source：监听进程事件源，与进程相关的事件通知
        - Mach port Dispatch Source：监听Mach端口事件源
        - Custom Dispatch Source：监听自定义事件源

     主要使用的API：
        - dispatch_source_create: 创建事件源
        - dispatch_source_set_event_handler: 设置数据源回调
        - dispatch_source_merge_data: 设置事件源数据
        - dispatch_source_get_data： 获取事件源数据
        - dispatch_resume: 继续
        - dispatch_suspend: 挂起
        - dispatch_cancle: 取消
     */
    
    //1.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //2.创建timer
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //3.设置timer首次执行时间，间隔，精确度
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC, 0*NSEC_PER_SEC);
    //4.设置timer事件回调
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"GCDTimer");
//        dispatch_suspend(timer);
        dispatch_cancel(timer);//必须有挂起或者取消才会执行block，如果timer是全局变量可以
    });
    //5.默认是挂起状态，需要手动激活
    dispatch_resume(timer);
    
}


#pragma mark - NSOperation
//NSOperation是个抽象类，实际运用时中需要使用它的子类，有三种方式：

//直接处理事务，不添加隐性队列
- (void)test_NSInvocationOperation{
    //创建NSInvocationOperation对象并关联方法，之后start。
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doSomething:) object:@"Chiang"];
    [invocationOperation start];
}


- (void)test_NSBlockOperation {
    //通过addExecutionBlock这个方法可以让NSBlockOperation实现多线程。
    //NSBlockOperation创建时block中的任务是在主线程执行，而运用addExecutionBlock加入的任务是在子线程执行的。
    //执行任务是异步的
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"main task = >currentThread: %@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
            NSLog(@"task1 = >currentThread: %@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
            NSLog(@"task2 = >currentThread: %@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
            NSLog(@"task3 = >currentThread: %@", [NSThread currentThread]);
    }];
    
    [blockOperation start];
}


- (void)test_TestOperation{
    //运用继承自NSOperation的子类 首先我们定义一个继承自NSOperation的类，然后重写它的main方法。
    TestOperation *operation = [[TestOperation alloc] init];
    [operation start];
}


- (void)test_NSOperationQueue{
    /*
     NSInvocationOperation和NSBlockOperation两者的区别在于：
     - 前者类似target形式
     - 后者类似block形式——函数式编程，业务逻辑代码可读性更高
     
     NSOperationQueue是异步执行的，所以任务一、任务二的完成顺序不确定
     */
    // 初始化添加事务
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务1————%@",[NSThread currentThread]);
    }];
    // 添加事务
    [bo addExecutionBlock:^{
        NSLog(@"任务2————%@",[NSThread currentThread]);
    }];
    // 回调监听
    bo.completionBlock = ^{
        NSLog(@"完成了!!!");
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:bo];
    NSLog(@"事务添加进了NSOperationQueue");
}

//执行顺序,异步，并不是按顺序执行
- (void)test_queueSequence{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        for (int i = 0; i < 10; i++) {
            [queue addOperationWithBlock:^{
                NSLog(@"%@---%d", [NSThread currentThread], i);
            }];
        }
}


- (void)test_operationQuality{
    /*
     NSOperation设置优先级只会让CPU有更高的几率调用，不是说设置高就一定全部先完成
     - 不使用sleep——高优先级的任务一先于低优先级的任务二
     - 使用sleep进行延时——高优先级的任务一慢于低优先级的任务二
     */
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
//            sleep(1);
            NSLog(@"第一个操作 %d --- %@", i, [NSThread currentThread]);
        }
    }];
    // 设置最高优先级
    bo1.qualityOfService = NSQualityOfServiceUserInteractive;
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"第二个操作 %d --- %@", i, [NSThread currentThread]);
        }
    }];
    // 设置最低优先级
    bo2.qualityOfService = NSQualityOfServiceBackground;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:bo1];
    [queue addOperation:bo2];

}

//设置并发数
- (void)test_operationMaxCount{
    /*
     在GCD中只能使用信号量来设置并发数
     而NSOperation轻易就能设置并发数
     通过设置maxConcurrentOperationCount来控制单次出队列去执行的任务数
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"Felix";
    queue.maxConcurrentOperationCount = 3;
    
    for (int i = 0; i < 10; i++) {
        [queue addOperationWithBlock:^{ // 一个任务
            [NSThread sleepForTimeInterval:1];
            NSLog(@"%d-%@",i,[NSThread currentThread]);
        }];
    }
}


//添加依赖
- (void)test_operationDependency{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"请求token");
    }];
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"拿着token,请求数据1");
    }];
    
    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"拿着数据1,请求数据2");
    }];
    
    [bo2 addDependency:bo1];
    [bo3 addDependency:bo2];
    
    [queue addOperations:@[bo1,bo2,bo3] waitUntilFinished:YES];
    
    NSLog(@"执行完了?我要干其他事");
}


//线程间通讯
- (void)test_operationNoti{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"Felix";
    [queue addOperationWithBlock:^{
        NSLog(@"请求网络%@--%@", [NSOperationQueue currentQueue], [NSThread currentThread]);
        [NSThread sleepForTimeInterval:3];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"刷新UI%@--%@", [NSOperationQueue currentQueue], [NSThread currentThread]);
        }];
    }];

}

@end

@implementation TestOperation
- (void)main {
    for (int i = 0; i < 3; i++) {
        NSLog(@"NSOperation的子类：%@",[NSThread currentThread]);
    }
}

@end
