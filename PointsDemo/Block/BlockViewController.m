//
//  BlockViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/7/2.
//

#import "BlockViewController.h"

typedef void(^Block)(void);
typedef void(^TestBlock)(BlockViewController *vc);

@interface BlockViewController ()
@property(nonatomic, strong)Block block;
@property(nonatomic, strong)TestBlock testBlock;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSTimer *timer;

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"block";
//    [self test_blockType];
//    [self test_retainCycle];
    [self test_NSProxy];
}

/*
 block直接存储在全局区
 如果block访问外界变量，并进行block相应拷贝，即copy
 如果此时的block是强引用，则block存储在堆区，即堆区block
 如果此时的block通过__weak变成了弱引用，则block存储在栈区，即栈区block
 */
- (void)test_blockType {
//    void(^block)(void) = ^{
//        NSLog(@"Chiang");
//    };
//    NSLog(@"%@", block);//__NSGlobalBlock__
    
    
//    int a = 10;
//    void(^block)(void) = ^{
//        NSLog(@"Chiang - %d", a);
//    };
//    NSLog(@"%@", block);//__NSMallocBlock__
    
    int a = 10;
    void(^__weak block)(void) = ^{
       NSLog(@"Chiang - %d", a);
    };
    NSLog(@"%@", block);//__NSStackBlock__
}

- (void)test_retainCycle {
    self.name = @"Chiang";
//    self.block = ^(void){
//        NSLog(@"%@",self.name);
//    };
//    self.block();
    
    //1.weak-stong-dance
    //此时的weakSelf 和 self 指向同一片内存空间，且使用__weak不会导致self的引用计数发生变化
//    __weak typeof(self) weakSelf = self;
//    self.block = ^{
//        NSLog(@"%@",weakSelf.name);
//    };
//    self.block();
    
    
    //如果block内部嵌套block，需要同时使用__weak 和 __strong
//    __weak typeof(self) weakSelf = self;
//    self.block = ^(void){
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"%@",strongSelf.name);
//        });
//    };
//    self.block();
    
    //2.__block修饰变量
    //通过__block修饰对象，主要是因为__block修饰的对象是可以改变的,注意block必须调用，如果不调用block，vc就不会置空，那么依旧是循环引用，self和block都不会被释放
//    __block BlockViewController *vc = self;
//    self.block = ^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"%@", vc.name);
//            vc = nil;
//        });
//    };
//    self.block();
    
    
    //3.对象self作为参数
//    self.testBlock = ^(BlockViewController *vc){
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"%@",vc.name);
//        });
//    };
//    self.testBlock(self);
    
    //NSProxy虚拟类
}


- (void)test_NSProxy {
//    Dog *dog = [[Dog alloc] init];
//    Cat *cat = [[Cat alloc] init];
//    TestProxy *proxy = [TestProxy alloc];
//
//    [proxy transformObjc:cat];
//    [proxy performSelector:@selector(eat)];
//
//    [proxy transformObjc:dog];
//    [proxy performSelector:@selector(shut)];
    
    //Proxy解决定时器中self的强引用问题
    self.timer = [NSTimer timerWithTimeInterval:1 target:[TestProxy proxyWithObjc:self] selector:@selector(print) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)print {
    NSLog(@"tick");
}

@end


@interface TestProxy ()
@property(nonatomic, weak, readonly) NSObject *objc;

@end

@implementation TestProxy

- (id)transformObjc:(NSObject *)objc{
   _objc = objc;
    return self;
}

+ (instancetype)proxyWithObjc:(id)objc{
    return  [[self alloc] transformObjc:objc];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    if ([self.objc respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.objc];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature;
    if (self.objc) {
        signature = [self.objc methodSignatureForSelector:sel];
    } else {
        signature = [super methodSignatureForSelector:sel];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.objc respondsToSelector:aSelector];
}

@end

@implementation Cat
- (void)eat{
   NSLog(@"猫吃鱼");
}
@end

@implementation Dog
- (void)shut{
    NSLog(@"狗叫");
}
@end
