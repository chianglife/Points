//
//  BaseTestModel.h
//  PointsDemo
//
//  Created by Chiang on 2022/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTestModel : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, assign)NSInteger count;
@property (nonatomic, copy)NSString *value1;
@property (nonatomic, copy)NSString *value2;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
