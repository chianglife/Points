//
//  ClassLoadOrder.m
//  PointsDemo
//
//  Created by Chiang on 2020/11/25.
//

#import "ClassLoadOrder.h"

//#define PointLog(...) NSLog(__VA_ARGS__)
//#define PointLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__) //##如果没有，只传一个参数会报错，##有吃掉逗号的作用
//#define PointLog(fmt, ...) NSLog((@"[FileName:%s] + " "[Method:%s] + " "[Line:%d] >>>>>>>>" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define PointLog(...)

@implementation ClassLoadOrder
@end

/*
  先调用类的load，如果有子类，则先看子类是否写了load，如果写了，则先调用父类的load，
  再调用子类的load，当类子类调用完了，再是分类，分类的load取决于编译顺序，先编译，则先调用
 */
@implementation Animal (myAnimal)
+ (void)load{
    PointLog(@"分类--Animal");
}
@end

@implementation Person (myPerson)
+ (void)load{
    PointLog(@"分类--Person");
}
@end


@implementation Student (myStudent)
+ (void)load{
    PointLog(@"分类--Student");
}
@end

@implementation Animal
+ (void)load{
    PointLog(@"Animal");
}
@end

@implementation ABook
+ (void)load{
    PointLog(@"ABook");
}
@end

@implementation Person
+ (void)load{
    PointLog(@"Person");
}
@end

@implementation Student
+ (void)load{
    PointLog(@"Student");
}
@end
