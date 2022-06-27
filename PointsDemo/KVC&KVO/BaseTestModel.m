//
//  BaseTestModel.m
//  PointsDemo
//
//  Created by Chiang on 2022/6/27.
//

#import "BaseTestModel.h"

@implementation BaseTestModel

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BaseTestModel *model = nil;
    dispatch_once(&onceToken, ^{
        model = [[BaseTestModel alloc] init];
    });
    return model;
}

//同时监听多个属性的变化
+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"count"]) {
        NSArray *affectingKeys = @[@"value1", @"value2"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}
@end
