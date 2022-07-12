//
//  LXQLIstModel.h
//  PointsDemo
//
//  Created by Chiang on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXQLIstModel : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) CGFloat cell_height;
@property (nonatomic, assign) CGFloat bottomSpace;
@property (nonatomic, assign) BOOL isHidden;

@end

NS_ASSUME_NONNULL_END
