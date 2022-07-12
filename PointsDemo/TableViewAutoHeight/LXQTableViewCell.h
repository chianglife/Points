//
//  LXQTableViewCell.h
//  PointsDemo
//
//  Created by Chiang on 2021/4/15.
//

#import <UIKit/UIKit.h>
#import "LXQLIstModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXQTableViewCell : UITableViewCell
@property (nonatomic, strong) LXQLIstModel *listModel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UILabel *hidenLabel;

@end

NS_ASSUME_NONNULL_END
