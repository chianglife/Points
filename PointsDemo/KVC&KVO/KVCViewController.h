//
//  KVCViewController.h
//  PointsDemo
//
//  Created by Chiang on 2022/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVCViewController : UIViewController

@end

@interface TestModel : NSObject
@property (nonatomic, copy)NSString *name;

- (void)test_setValue:(nullable id)value forKey:(NSString *)key;

@end
NS_ASSUME_NONNULL_END
