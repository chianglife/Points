//
//  MethodSwizzlingViewController.h
//  PointsDemo
//
//  Created by Chiang on 2022/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MethodSwizzlingViewController : UIViewController

@end


@interface PersonClass : NSObject

- (void)eat;

@end


@interface StudentClass : PersonClass

@end


@interface RuntimeTool : NSObject
+ (void)methodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL;

@end
NS_ASSUME_NONNULL_END
