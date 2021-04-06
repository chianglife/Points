//
//  ClassLoadOrder.h
//  PointsDemo
//
//  Created by Chiang on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClassLoadOrder : NSObject

@end

@interface ABook : NSObject
@end

@interface Animal : NSObject
@end

@interface Person : Animal
@end

@interface Student : Person
@end

@interface Animal (myAnimal)
@end

@interface Person (myPerson)
@end

@interface Student (myStudent)
@end
NS_ASSUME_NONNULL_END
