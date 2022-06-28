//
//  KVOViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/27.
//

#import "KVOViewController.h"
#import "BaseTestModel.h"
#import <objc/runtime.h>

@interface KVOViewController ()
@property(nonatomic, strong)BaseTestModel *test;
@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KVO";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStylePlain target:self action:@selector(push)];
    
//    self.test = [BaseTestModel sharedInstance];
    self.test = [[BaseTestModel alloc] init];
    //count和value1，value2绑定一起被监听
//    [self.test addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:NULL];//
//    [self.test addObserver:self forKeyPath:@"dataArray" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    
    //观察中间类
    const char *className = object_getClassName(self.test);
    NSLog(@"%s", className);//BaseTestModel
    [self.test addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
    //在注册观察者后，实例对象的isa指针指向由BaseTestModel类变为了NSKVONotifying_BaseTestModel中间类，即实例对象的isa指针指向发生了变化
    const char *classNameObserved = object_getClassName(self.test);
    NSLog(@"%s", classNameObserved);//NSKVONotifying_BaseTestModel
    Class superClass = class_getSuperclass(objc_getClass("NSKVONotifying_BaseTestModel"));
    NSLog(@"%s", object_getClassName(superClass));//NSKVONotifying_BaseTestModel是BaseTestModel的子类
    
    /* 打印中间类的方法列表
        2022-06-28 12:00:06.665040+0800 PointsDemo[19910:1153699] setValue:-0x182ef5974
        2022-06-28 12:00:06.665222+0800 PointsDemo[19910:1153699] class-0x182ee00b4
        2022-06-28 12:00:06.665287+0800 PointsDemo[19910:1153699] dealloc-0x182f27afc
        2022-06-28 12:00:06.665375+0800 PointsDemo[19910:1153699] _isKVOA-0x182f87ff0
     */
    [self printClassAllMethod:objc_getClass("NSKVONotifying_BaseTestModel")];
    
    /* 总结
         实例对象isa的指向在注册KVO观察者之后，由原有类更改为指向中间类
         中间类重写了观察属性的setter方法、class、dealloc、_isKVOA方法
         dealloc方法中，移除KVO观察者之后，实例对象isa指向由中间类更改为原有类
         中间类从创建后，就一直存在内存中，不会被销毁
     */
}

- (void)push {
    KVOViewController *vc = [[KVOViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.test.value2 = @"1";//同事监听多个属性
//    self.test->value3 = @"1";
//    [self.test.dataArray addObject:@"1"];//addObject不会触发kvo
//    [[self.test mutableArrayValueForKey:@"dataArray"] addObject:@"1"];//这样就能触发kvo
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@ - %@",keyPath, change);
}

#pragma mark - 遍历方法-ivar-property
- (void)printClassAllMethod:(Class)cls{
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        IMP imp = class_getMethodImplementation(cls, sel);
        NSLog(@"%@-%p",NSStringFromSelector(sel),imp);
    }
    free(methodList);
}

- (void)dealloc {
    //此时如果不移除观察者，会有类似野指针崩溃。
    //多次增加观察者，如果观察者被释放之前没有移除，属性变化的时候会通知所有观察者，而观察者被释放，形成野指针
    [self.test removeObserver:self forKeyPath:@"value"];
}
@end
