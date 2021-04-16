//
//  MemoryIssuesViewController.m
//  
//
//  Created by Chiang on 2021/4/16.
//

#import "MemoryIssuesViewController.h"

@interface MemoryIssuesViewController ()
@property (nonatomic, copy) NSString *name;
@end

@implementation MemoryIssuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testTagedPointer];
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


@end
