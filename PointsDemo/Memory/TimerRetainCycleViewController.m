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
@property (nonatomic, strong) TestTimer *test_timer;

@end

@implementation TimerRetainCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"计时器循环引用";
    
//    [self test_timer1];
//    [self test_timer_2];
//    [self test_timerBlock];
//    [self test_timer_3];
    [self test_timer_4];

}

- (void)test_timer1 {
//    weakSelf 和 self 的内存地址是不一样，都指向同一片内存空间
    __weak typeof(self) weakSelf = self;//无效,循环引用，不会走dealloc, RunLoop对整个对象的空间有强持有
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

//方法3：中介者模式，中断循环持有链
- (void)test_timer_2 {
    NSObject *object= [[NSObject alloc] init];
    class_addMethod([NSObject class], @selector(fire), (IMP)testfire, "v@:");//共用imp
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:object selector:@selector(fire) userInfo:nil repeats:YES];
}

//方法3：自定义timer，对self弱引用，中断循环持有链
- (void)test_timer_3 {
    self.test_timer = [[TestTimer alloc] initWithTimeInterval:1 target:self selector:@selector(fireTimer) userInfo:nil repeats:YES];
}

//方法4：利用NSProxy虚基类的子类，对self弱引用, 中断循环持有链
- (void)test_timer_4 {
    TimerProxy *proxy = [TimerProxy proxyWithObject:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:proxy selector:@selector(fireTimer) userInfo:nil repeats:YES];
}

void testfire(id obj) {
    NSLog(@"fire!!!");
}

- (void)fireTimer {
    NSLog(@"fire timer!!!");
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    
    [self.test_timer test_invalidate];
    
}

@end

#import <objc/message.h>
@interface TestTimer()
@property(nonatomic ,weak)id target;
@property(nonatomic ,assign)SEL selector;
@property(nonatomic ,strong)NSTimer *timer;

@end

@implementation TestTimer

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    self = [super init];
    if (self) {
        self.target = aTarget;
        self.selector = aSelector;
        if ([self.target respondsToSelector:self.selector]) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(fire) userInfo:userInfo repeats:yesOrNo];
        }
    }
    return self;
}

- (void)fire {
    if (self.target) {
        void (*lg_msgSend)(void *,SEL) = (void *)objc_msgSend;
        lg_msgSend((__bridge void *)self.target, self.selector);
    }
}

- (void)test_invalidate {
    [self.timer invalidate];
    self.timer = nil;
}


- (void)dealloc {
    //VC里面dealloc释放timer后才会到这里
    NSLog(@"%s", __func__);
}
@end


@interface TimerProxy()
@property(nonatomic, weak)id object;
@end

@implementation TimerProxy
+ (instancetype)proxyWithObject:(id)object{
    TimerProxy *proxy = [TimerProxy alloc];
    proxy.object = object;
    return proxy;
}

-(id)forwardingTargetForSelector:(SEL)aSelector {
    return self.object;
}

@end
