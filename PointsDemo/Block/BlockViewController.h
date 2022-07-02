//
//  BlockViewController.h
//  PointsDemo
//
//  Created by Chiang on 2022/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlockViewController : UIViewController

@end

@interface TestProxy : NSProxy
- (id)transformObjc:(NSObject *)objc;
+ (instancetype)proxyWithObjc:(id)objc;
@end

@interface Cat : NSObject
@end
@interface Dog : NSObject
@end
NS_ASSUME_NONNULL_END
