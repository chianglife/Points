//
//  MultiThreadViewController.m
//  PointsDemo
//
//  Created by Chiang on 2021/4/2.
//

#import "MultiThreadViewController.h"

@implementation MyTestOperation
//可以通过重写 main 或者 start 方法 来定义自己的 NSOperation 对象。重写main方法比较简单，我们不需要管理操作的状态属性 isExecuting 和 isFinished
- (void)main {
    if (!self.isCancelled) {
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3];
            NSLog(@"MyTestOperation---%@", [NSThread currentThread]);
        }
    }
}

@end

@interface MultiThreadViewController () {
    NSMutableDictionary *dict;
    dispatch_queue_t concurrent_queue;
}

@property (nonatomic, assign) NSInteger ticketSurplusCount;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation MultiThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dict = [NSMutableDictionary dictionary];
    concurrent_queue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
//    [self deadlock];
    [self test8];

}

//死锁问题
- (void)deadlock {
    dispatch_queue_t queue = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);//自定义串行队列不会死锁
    dispatch_sync(queue, ^{
        NSLog(@"1");
    });
    
    dispatch_sync(dispatch_get_main_queue(), ^{//如果是主队列就会死锁
        NSLog(@"1");
    });
}

//同步并发,12345
- (void)test1 {
    NSLog(@"1");
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"2");
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//栅栏函数，实现多读单写
- (void)test2 {
    for (int i = 0; i < 10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setObject:[NSString stringWithFormat:@"value_%d",i] forKey:[NSString stringWithFormat:@"key_%d",i]];
            id obj1 = [self objectForKey:[NSString stringWithFormat:@"key_%d",i]];
            NSLog(@"%@", obj1);
        });
    }
}

- (id)objectForKey:(NSString *)key {
    __block id obj;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(concurrent_queue, ^{
        __strong typeof(self) self = weakSelf;
        obj = [self->dict objectForKey:key];
    });
    return obj;
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(concurrent_queue, ^{
        __strong typeof(self) self = weakSelf;
        [self->dict setObject:obj forKey:key];
    });
}

//组，模拟真实网络请求
- (void)test3 {
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, concurrent_queue, ^{
            dispatch_group_enter(group);//如果有异步操作，必须要手动加入组，再手动离开组
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"%d", i);
                dispatch_group_leave(group);
            });
        });
    }
    dispatch_group_notify(group, concurrent_queue, ^{
        NSLog(@"that's all");
    });
}


#pragma mark - NSOperation
//不使用NSOperationQueue
//NSOperation 是个抽象类，不能用来封装操作。我们只有使用它的子类来封装操作。我们有三种方式来封装操作。
- (void)test4 {
    //1.使用子类 NSInvocationOperation
    //在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    [operation start];
    
    //2.使用子类 NSBlockOperation
    //没有使用 NSOperationQueue操作是在当前线程执行的，并没有开启新线程
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        [self task1];
    }];
    //通过 addExecutionBlock: 就可以为 NSBlockOperation 添加额外的操作。这些操作（包括 blockOperationWithBlock 中的操作）可以在不同的线程中同时（并发）执行, 由系统来决定是否开启新线程
    [blockOp addExecutionBlock:^{
        [self task1];
    }];
    
    [blockOp start];
    
    //3.自定义继承自 NSOperation 的子类，通过实现内部相应的方法来封装操作。
    //没有使用 NSOperationQueue操作是在当前线程执行的，并没有开启新线程
    MyTestOperation *myOperation = [[MyTestOperation alloc] init];
    [myOperation start];
}

//使用NSOperationQueue
- (void)test5 {
    //1.先创建操作，再将创建好的操作加入到创建好的队列中去
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"task3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"task4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    //当一个操作的所有依赖都已经完成时，操作对象通常会进入准备就绪状态，等待执行，没有依赖的操作会先进入就绪状态
    //queuePriority 属性决定了进入准备就绪状态下的操作之间的开始执行顺序。并且，优先级不能取代依赖关系, 优先级只作用于已经处于就绪状态的操作
    [op2 addDependency:op1]; // 让op2 依赖于 op1，则先执行op1，在执行op2
    [op3 addDependency:op2];

    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
    // 2.无需先创建操作，在 block 中添加操作，直接将包含操作的 block 加入到队列中
//    [queue addOperationWithBlock:^{
//        for (int i = 0; i < 2; i++) {
//            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
//            NSLog(@"block1---%@", [NSThread currentThread]); // 打印当前线程
//        }
//    }];
//    [queue addOperationWithBlock:^{
//        for (int i = 0; i < 2; i++) {
//            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
//            NSLog(@"block2---%@", [NSThread currentThread]); // 打印当前线程
//        }
//    }];
//    [queue addOperationWithBlock:^{
//        for (int i = 0; i < 2; i++) {
//            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
//            NSLog(@"block3---%@", [NSThread currentThread]); // 打印当前线程
//        }
//    }];
}

//NSOperationQueue 控制串行执行、并发执行
- (void)test6 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 默认情况下为-1，表示不进行限制，可进行并发执行
//    queue.maxConcurrentOperationCount = 1; // 串行队列
//     queue.maxConcurrentOperationCount = 2; // 并发队列
     queue.maxConcurrentOperationCount = 8; // 并发队列
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

//线程间通信
- (void)test7 {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}
- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
        NSLog(@"task1---%@", [NSThread currentThread]); // 打印当前线程
    }
}

- (void)task2 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:0.3]; // 模拟耗时操作
        NSLog(@"task2---%@", [NSThread currentThread]); // 打印当前线程
    }
}

//卖火车票问题
/**
 * 线程安全：使用 NSLock 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */

- (void)test8 {
    NSLog(@"currentThread---%@",[NSThread currentThread]); // 打印当前线程

    self.ticketSurplusCount = 50;

    self.lock = [[NSLock alloc] init];  // 初始化 NSLock 对象

    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 4;

    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
//    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
//    queue2.maxConcurrentOperationCount = 1;

    // 3.创建卖票操作 op1
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];

    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];

    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    // 5.添加操作，开始卖票
    [queue1 addOperations:@[op1,op2,op3,op4] waitUntilFinished:YES];
//    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 加锁
        [self.lock lock];

        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.1];
        }

        // 解锁
        [self.lock unlock];

        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}
@end

