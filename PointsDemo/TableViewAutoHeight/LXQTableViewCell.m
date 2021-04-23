//
//  LXQTableViewCell.m
//  PointsDemo
//
//  Created by Chiang on 2021/4/15.
//

#import "LXQTableViewCell.h"
#import "Masonry.h"

@implementation LXQTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self.contentView addSubview:self.contentLabel];
//    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView.mas_left).offset(15);
//        make.top.equalTo(self.contentView.mas_top).offset(15);
//        make.right.equalTo(self.contentView.mas_right).offset(-15);
//        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
//    }];
    
    //这一句很重要，如果不加无法正常显示视图
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layoutAttributeLeft = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeLeft constant:15];
    NSLayoutConstraint *layoutAttributeRight = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeRight constant:-15];
    NSLayoutConstraint *layoutAttributeTop = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeTop constant:15];
    NSLayoutConstraint *layoutAttributeBottom = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeBottom constant:-15];

    [self.contentView addConstraint:layoutAttributeLeft];
    [self.contentView addConstraint:layoutAttributeRight];
    [self.contentView addConstraint:layoutAttributeTop];
    [self.contentView addConstraint:layoutAttributeBottom];
}


- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.contentView
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:constant];
}

- (void)setListModel:(LXQLIstModel *)listModel {
    self.contentLabel.text = listModel.content;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 0;
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

@end
