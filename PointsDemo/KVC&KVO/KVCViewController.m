//
//  KVCViewController.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/25.
//

#import "KVCViewController.h"
#import <objc/runtime.h>

@interface KVCViewController ()

@end

@implementation KVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KVC";
    [self test];
}

/*
 当调用setValue:forKey:设置属性value时，其底层的执行流程为
     【第一步】首先查找是否有这三种setter方法，按照查找顺序为set<Key>：-> _set<Key> -> setIs<Key>
         如果有其中任意一个setter方法，则直接设置属性的value（主注意：key是指成员变量名，首字符大小写需要符合KVC的命名规范）
         如果都没有，则进入【第二步】
     【第二步】：如果没有第一步中的三个简单的setter方法，则查找accessInstanceVariablesDirectly是否返回YES，
         如果返回YES，则查找间接访问的实例变量进行赋值，查找顺序为：_<key> -> _is<Key> -> <key> -> is<Key>
             如果找到其中任意一个实例变量，则赋值
             如果都没有，则进入【第三步】
         如果返回NO，则进入【第三步】
     【第三步】如果setter方法 或者 实例变量都没有找到，系统会执行该对象的setValue：forUndefinedKey:方法，默认抛出NSUndefinedKeyException类型的异常
 */

- (void)test {
    TestModel *model = [[TestModel alloc] init];
    [model test_setValue:@"chiang" forKey:@"name"];
    NSLog(@"%@",[model test_valueForKey:@"name"]);
}

@end

@implementation TestModel

//设值
- (void)test_setValue:(nullable id)value forKey:(NSString *)key{
    if (key == nil || key.length == 0) return;
    
    //找setter方法，顺序是：setXXX、_setXXX、 setIsXXX
    NSString *Key = key.capitalizedString;
    NSString *setKey = [NSString stringWithFormat:@"set%@:", Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:", Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:", Key];
    
    if ([self test_performSelectorWithMethodName:setKey value:value]) {
        NSLog(@"*************%@*************", setKey);
        return;
    }else if([self test_performSelectorWithMethodName:_setKey value:value]){
        NSLog(@"*************%@*************", _setKey);
        return;
    }else if([self test_performSelectorWithMethodName:setIsKey value:value]){
        NSLog(@"*************%@*************", setIsKey);
        return;
    }
    
    //判断是否响应`accessInstanceVariablesDirectly`方法，即间接访问实例变量，返回YES，继续下一步设值，如果是NO，则崩溃
    if (![self.class accessInstanceVariablesDirectly]) {
        @throw [NSException exceptionWithName:@"UnKnownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }
    
    //间接访问变量赋值，顺序为：_key、_isKey、key、isKey
    NSMutableArray *ivarNameList = [self getIvarListName];
    NSString *_key = [NSString stringWithFormat:@"_%@", Key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@", Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@", Key];
    
    if ([ivarNameList containsObject:_key]) {
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        object_setIvar(self, ivar, value);
        return;

    } else if ([ivarNameList containsObject:_isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        object_setIvar(self, ivar, value);
        return;

    } else if ([ivarNameList containsObject:key]) {
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        object_setIvar(self, ivar, value);
        return;

    } else if ([ivarNameList containsObject:isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        object_setIvar(self, ivar, value);
        return;

    }
    
    @throw [NSException exceptionWithName:@"UnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ %@]: this class is not key value coding-compliant for the key name.****",self,NSStringFromSelector(_cmd)] userInfo:nil];

}

//取值
- (nullable id)test_valueForKey:(NSString *)key{
    if (key == nil || key.length == 0) {
        return nil;
    }
    NSString *Key = key.capitalizedString;
    NSString *getKey = [NSString stringWithFormat:@"get%@",Key];
    NSString *countOfKey = [NSString stringWithFormat:@"countOf%@",Key];
    NSString *objectInKeyAtIndex = [NSString stringWithFormat:@"objectIn%@AtIndex:",Key];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(getKey)]) {
        return [self performSelector:NSSelectorFromString(getKey)];
    } else if ([self respondsToSelector:NSSelectorFromString(key)]){
        return [self performSelector:NSSelectorFromString(key)];
    }
    //集合类型
    else if ([self respondsToSelector:NSSelectorFromString(countOfKey)]){
        if ([self respondsToSelector:NSSelectorFromString(objectInKeyAtIndex)]) {
            int num = (int)[self performSelector:NSSelectorFromString(countOfKey)];
            NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
            for (int i = 0; i<num-1; i++) {
                num = (int)[self performSelector:NSSelectorFromString(countOfKey)];
            }
            for (int j = 0; j<num; j++) {
                id objc = [self performSelector:NSSelectorFromString(objectInKeyAtIndex) withObject:@(num)];
                [mArray addObject:objc];
            }
            return mArray;
        }
    }
#pragma clang diagnostic pop
    if (![self.class accessInstanceVariablesDirectly]) {
          @throw [NSException exceptionWithName:@"CJLUnKnownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
      }
      
    //找相关实例变量进行赋值，顺序为：_key、_isKey、key、isKey
      NSMutableArray *mArray = [self getIvarListName];
      NSString *_key = [NSString stringWithFormat:@"_%@",key];
      NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
      NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
      if ([mArray containsObject:_key]) {
          Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
          return object_getIvar(self, ivar);;
      }else if ([mArray containsObject:_isKey]) {
          Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
          return object_getIvar(self, ivar);;
      }else if ([mArray containsObject:key]) {
          Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
          return object_getIvar(self, ivar);;
      }else if ([mArray containsObject:isKey]) {
          Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
          return object_getIvar(self, ivar);;
      }
      return @"";
}


+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

- (NSMutableArray *)getIvarListName {
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *ivarNameChar = ivar_getName(ivar);
        //将C字符转换成字符串,UTF8是属于Unicode的一种，编码世界上所有符号
        NSString *ivarname = [NSString stringWithUTF8String:ivarNameChar];
        [mArray addObject:ivarname];
    }
    free(ivars);
    return mArray;
}

- (BOOL)test_performSelectorWithMethodName:(NSString *)methodName value:(id)value {
    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
#pragma clang diagnostic push
        //如果你确定不会发生内存泄漏的情况下，可以使用如下的语句来忽略掉这条警告
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(methodName) withObject:value];
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

@end
