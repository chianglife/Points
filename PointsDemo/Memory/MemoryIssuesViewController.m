//
//  MemoryIssuesViewController.m
//  
//
//  Created by Chiang on 2021/4/16.
//

#import "MemoryIssuesViewController.h"

@interface MemoryIssuesViewController ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MemoryIssuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self testTagedPointer];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"启动定时器" style:UIBarButtonItemStylePlain target:self action:@selector(begin)];
    
    //NStimer引起的循环应用问题
    if (self.navigationController.childViewControllers.count > 1) {
        self.navigationItem.rightBarButtonItem = nil;
        
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

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
