//
//  ViewController.m
//  PointsDemo
//
//  Created by Chiang on 2020/11/18.
//

#import "ViewController.h"
#import "Masonry.h"
#define kCellIdentifier @"kCellIdentifier"
#import "objc/runtime.h"
#import <CoreLocation/CoreLocation.h>

#import "AliveThread.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) AliveThread *aliveThread;

@end

@implementation ViewController{
    BOOL isLoopRunning;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试";
        
//    _dataArray = @[@"multithreaded",@"runtime",@"block",@"runloop",@"design patterns"];
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    
//    [self test_NSMapTable];
//    [self creatAndStartThread];
}


/*
    1.NSMapTable能够自动管理内存
*/
- (void)test_NSMapTable {
    //指定key为强引用，value为弱引用
    NSMapTable *aMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    {
        NSObject *keyObject = [[NSObject alloc] init];
        NSObject *valueObject = [[NSObject alloc] init];
        [aMapTable setObject:valueObject forKey:keyObject];
        NSLog(@"NSMapTable:%@", aMapTable);
    }
    //作用域外会自动释放掉key-value
    NSLog(@"NSMapTable:%@", aMapTable);
}

/*
    2.在子线程中调用timer，需要手动创建并且运行runLoop
 
    当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。
    当调用 performSelector:onThread: 时，实际上其会创建一个 Timer 加到对应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效。
*/
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"1");
//        [self addObserver];//添加观察者到runloop
//        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
//        [self performSelector:@selector(testPerform) withObject:nil afterDelay:1];//
//        [runLoop run];
//        NSLog(@"3");
//    });
//}


- (void)testPerform{
    //如果没有加入runloop则不会打印
    NSLog(@"2");
}

- (void)addObserver {
    /*
     kCFRunLoopEntry = (1UL << 0),1
     kCFRunLoopBeforeTimers = (1UL << 1),2
     kCFRunLoopBeforeSources = (1UL << 2), 4
     kCFRunLoopBeforeWaiting = (1UL << 5), 32
     kCFRunLoopAfterWaiting = (1UL << 6), 64
     kCFRunLoopExit = (1UL << 7),128
     kCFRunLoopAllActivities = 0x0FFFFFFFU
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case 1:
            {
                NSLog(@"进入runloop");
            }
                break;
            case 2:
            {
                NSLog(@"timers");
            }
                break;
            case 4:
            {
                NSLog(@"sources");
            }
                break;
            case 32:
            {
                NSLog(@"即将进入休眠");
            }
                break;
            case 64:
            {
                NSLog(@"唤醒");
            }
                break;
            case 128:
            {
                NSLog(@"退出");
            }
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);//将观察者添加到common模式下，这样当default模式和UITrackingRunLoopMode两种模式下都有回调。
    CFRelease(observer);
}


/*
    3.线程保活和runloop退出
 */
- (void)creatAndStartThread {
    AliveThread *thread = [[AliveThread alloc] initWithTarget:self selector:@selector(threadAction) object:nil];
    [thread start];
    
    self.aliveThread = thread;
}

- (void)threadAction {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    //这里因为这个RunLoop既没有Timer，也没有Sources,为了防止RunLoop自己退出，所以舔加了一个[NSMachPort port]，让runloop一直等待唤醒
    [runloop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    [runloop run];
//    [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];//5秒后退出runloop
//    isLoopRunning = YES;
//    while (isLoopRunning && [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(aliveTreadAction) onThread:self.aliveThread withObject:nil waitUntilDone:NO];
}

- (void)aliveTreadAction {
    NSLog(@"我还活着");
//    isLoopRunning = NO;
//    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorInset = UIEdgeInsetsMake(0, -15, 0, 0);
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}
@end


