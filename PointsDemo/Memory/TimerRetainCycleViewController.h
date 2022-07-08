//
//  TimerRetainCycleViewController.h
//  PointsDemo
//
//  Created by Chiang on 2022/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimerRetainCycleViewController : UIViewController

@end

@interface TestTimer : NSObject
- (instancetype)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
- (void)test_invalidate;
@end


@interface TimerProxy : NSProxy
+ (instancetype)proxyWithObject:(id)object;
@end

NS_ASSUME_NONNULL_END
