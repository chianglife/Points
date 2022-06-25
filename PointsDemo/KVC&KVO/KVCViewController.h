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
//自定义设值
- (void)test_setValue:(nullable id)value forKey:(NSString *)key;
//自定义取值
- (nullable id)test_valueForKey:(NSString *)key;
@end
NS_ASSUME_NONNULL_END
