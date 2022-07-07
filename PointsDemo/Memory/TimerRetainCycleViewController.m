//
//  TimerRetainCycleViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/7/5.
//

#import "TimerRetainCycleViewController.h"
#import <objc/runtime.h>

@interface TimerRetainCycleViewController ()
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TimerRetainCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"计时器循环引用";
    
//    [self test_timer1];
    [self test_timer_2];
//    [self test_timerBlock];
}

- (void)test_timer1 {

    __weak typeof(self) weakSelf = self;//无效,循环引用，不会走dealloc
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)timerAction {
    NSLog(@"tiktok");
}

//方法1
//- (void)didMoveToParentViewController:(UIViewController *)parent{
//    if (parent == nil) {//pop的时候为nil
//       [self.timer invalidate];
//        self.timer = nil;
//        NSLog(@"timer 走了");
//    }
//}

//方法2，使用block形式，不会引起循环引用, 会走dealloc
- (void)test_timerBlock{
    if (@available(iOS 10.0, *)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"tiktok");
        }];
    } else {
        // Fallback on earlier versions
    }
}

//方法3：中介者模式, 和BlockViewController中test_NSProxy原理类似
- (void)test_timer_2 {
    NSObject *object= [[NSObject alloc] init];
    class_addMethod([NSObject class], @selector(fire), (IMP)testfire, "v@:");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:object selector:@selector(fire) userInfo:nil repeats:YES];
}

void testfire(id obj) {
    NSLog(@"fire!!!");
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
