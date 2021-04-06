//
//  ResponseChainViewController.h
//  PointsDemo
//
//  Created by Chiang on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView(Responder)

@end

@interface FirstView : UIView

@end

@class FourthView;
@interface SecondView : UIView
@property (nonatomic, strong) FourthView *view4;
@end

@interface ThirdView : UIView

@end

@interface FourthView : UIView

@end

@interface ResponseChainViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
