//
//  MemoryIssuesViewController.m
//  
//
//  Created by Chiang on 2021/4/16.
//

#import "MemoryIssuesViewController.h"
#define KLog(_c) NSLog(@"%@ -- %p -- %@",_c,_c,[_c class]);

@interface MemoryIssuesViewController ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_queue_t testQueue;

@end

@implementation MemoryIssuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testTagedPointer];
    [self test_NSString];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"启动定时器" style:UIBarButtonItemStylePlain target:self action:@selector(begin)];
    
    //NStimer引起的循环应用问题
    if (self.navigationController.childViewControllers.count > 1) {
        self.navigationItem.rightBarButtonItem = nil;
        
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

/*  当name是简单字符串（123）的时候，类型是NSTaggedPointerString，存储在常量区。因为name在alloc分配时在堆区，由于较小，所以经过xcode中iOS的优化，成了NSTaggedPointerString类型，存储在常量区
    当name是长字符串（qwertyuiopasdfghjkl）的时候类型是 NSCFString类型，存储在堆上
*/
- (void)testTagedPointer {
    NSString *str = [NSString stringWithFormat:@"123"];
    NSString *str1 = [NSString stringWithFormat:@"qwertyuiopasdfghjkl"];
    NSLog(@"%@  %@",[str class],[str1 class]);//NSTaggedPointerString  __NSCFString

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0 );
    for (int i = 0 ; i < 10000; i ++) {
        dispatch_async(queue, ^{
            //-(void)setName:(NSString *)name{
            //    if (_name != name) {
            //        [_name release];
            //        _name = [name copy];
            //    }
            //}
            //相当于多个线程有可能同时去 release，所以会崩溃
            //如果换成简单字符串就不会崩溃，值会放在指针中，不会在堆中创建OC对象，就没有release
            self.name = [NSString stringWithFormat:@"%@",@"qwertyuiopasdfghjkl"];
        });
    }
}

/*
 Tagged Pointer 总结
 Tagged Pointer小对象类型（用于存储NSNumber、NSDate、小NSString），小对象指针不再是简单的地址，而是地址 + 值，即真正的值，所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而以。所以可以直接进行读取。优点是占用空间小 节省内存
 Tagged Pointer小对象 不会进入retain 和 release，而是直接返回了，意味着不需要ARC进行管理，所以可以直接被系统自主的释放和回收
 Tagged Pointer的内存并不存储在堆中，而是在常量区中，也不需要malloc和free，所以可以直接读取，相比存储在堆区的数据读取，效率上快了3倍左右。创建的效率相比堆区快了近100倍左右
 所以，综合来说，taggedPointer的内存管理方案，比常规的内存管理，要快很多
 Tagged Pointer的64位地址中，前4位代表类型，后4位主要适用于系统做一些处理，中间56位用于存储值
 优化内存建议：对于NSString来说，当字符串较小时，建议直接通过@""初始化，因为存储在常量区，可以直接进行读取。会比WithFormat初始化方式更加快速
 */



/*
 NSString的内存管理主要分为3种
 1.__NSCFConstantString：字符串常量，是一种编译时常量，retainCount值很大，对其操作，不会引起引用计数变化，存储在字符串常量区
 2.__NSCFString：是在运行时创建的NSString子类，创建后引用计数会加1，存储在堆上
 3.NSTaggedPointerString：标签指针，是苹果在64位环境下对NSString、NSNumber等对象做的优化。对于NSString对象来说
 当字符串是由数字、英文字母组合且长度小于等于9时，会自动成为NSTaggedPointerString类型，存储在常量区
 当有中文或者其他特殊符号时，会直接成为__NSCFString类型，存储在堆区
 */
- (void)test_NSString{
    //初始化方式一：通过 WithString + @""方式
    NSString *s1 = @"1";//通过@""方式都存储在常量区
    NSString *s2 = [[NSString alloc] initWithString:@"222"];
    NSString *s3 = [NSString stringWithString:@"33"];

    KLog(s1);
    KLog(s2);
    KLog(s3);

    //初始化方式二：通过 WithFormat
    //通过format默认存储在堆区，依据字符串长度来决定是否进行小对象优化
    //字符串长度在9以内
    NSString *s4 = [NSString stringWithFormat:@"123456789"];
    NSString *s5 = [[NSString alloc] initWithFormat:@"123456789"];
    
    //字符串长度大于9
    NSString *s6 = [NSString stringWithFormat:@"1234567890"];
    NSString *s7 = [[NSString alloc] initWithFormat:@"1234567890"];
    
    KLog(s4);
    KLog(s5);
    KLog(s6);
    KLog(s7);
}

- (void)begin {
    MemoryIssuesViewController *vc = [[MemoryIssuesViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)timerAction {
    NSLog(@"tiktok");
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
