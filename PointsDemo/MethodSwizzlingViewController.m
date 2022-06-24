//
//  MethodSwizzlingViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/24.
//

#import "MethodSwizzlingViewController.h"
#import "objc/runtime.h"

@interface MethodSwizzlingViewController ()

@end

@implementation MethodSwizzlingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MethodSwizzling";
    
    PersonClass *person = [[PersonClass alloc] init];
    [person eat];//会先进入eat_swizzle方法
    
    StudentClass *student = [[StudentClass alloc] init];
    [student eat];
}

@end


@implementation PersonClass

- (void)eat {
    NSLog(@"%@ : %s", NSStringFromClass([self class]) ,__func__);
}
@end


@implementation StudentClass
//是否实现eat, 影响class_addMethod是否成功
@end


//如果对子类添加分类方法，交换父类的方法，[self swizzleMethod]会崩溃，因为父类找不到该方法
@implementation StudentClass(Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           [RuntimeTool methodSwizzlingWithClass:self oriSEL:@selector(eat) swizzledSEL:@selector(eat_swizzle)];
       });
}

- (void)eat_swizzle {
    [self eat_swizzle];//会调用eat方法
    NSLog(@"%@ : %s", NSStringFromClass([self class]) ,__func__);
}

@end


@implementation RuntimeTool
/*
 类方法的方法交换如下
 需要通过class_getClassMethod方法获取类方法
 在调用class_addMethod和class_replaceMethod方法添加和替换时，需要传入的类是元类，元类可以通过object_getClass方法获取类的元类
 */

+ (void)methodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL{
    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);
    
    BOOL success = class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
    if (success) {//添加成功，代表cls中没有实现oriSEL，自己去实现oriSEL
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {//添加失败，代表cls中实现了oriSEL
        method_exchangeImplementations(oriMethod, swiMethod);
    }
}
@end





#pragma mark - NSArray越界防崩溃写法示例

@implementation NSArray (CJLArray)
//如果下面代码不起作用，造成这个问题的原因大多都是其调用了super load方法。在下面的load方法中，不应该调用父类的load方法。这样会导致方法交换无效
+ (void)load{
    Method fromMethod = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
    Method toMethod = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(cjl_objectAtIndex:));
    method_exchangeImplementations(fromMethod, toMethod);
}

//如果下面代码不起作用，造成这个问题的原因大多都是其调用了super load方法。在下面的load方法中，不应该调用父类的load方法。这样会导致方法交换无效
- (id)cjl_objectAtIndex:(NSUInteger)index{
    //判断下标是否越界，如果越界就进入异常拦截
    if (self.count-1 < index) {
        // 这里做一下异常处理，不然都不知道出错了。
#ifdef DEBUG  // 调试阶段
        return [self cjl_objectAtIndex:index];
#else // 发布阶段
        @try {
            return [self cjl_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息，方便我们调试。
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {
            
        }
#endif
    }else{ // 如果没有问题，则正常进行方法调用
        return [self cjl_objectAtIndex:index];
    }
}

@end
