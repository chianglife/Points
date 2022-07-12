//
//  LXQTableViewCell.m
//  PointsDemo
//
//  Created by Chiang on 2021/4/15.
//

#import "LXQTableViewCell.h"
#import "Masonry.h"
@interface LXQTableViewCell()
@property (nonatomic, weak) MASConstraint *constraint;

@end

@implementation LXQTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self.contentView addSubview:self.changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.top.equalTo(self.contentView.mas_top).offset(15);
    }];
    
    [self.contentView addSubview:self.hidenLabel];
    [self.hidenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.top.equalTo(self.changeButton.mas_bottom).offset(15);
    }];
    
    [self.contentView addSubview:self.contentLabel];
    //self并没有对block有直接引用，所以不会导致循环引用
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        self.constraint = make.top.equalTo(self.hidenLabel.mas_bottom).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
    }];
    
    //这一句很重要，如果不加无法正常显示视图
//    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    NSLayoutConstraint *layoutAttributeLeft = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeLeft constant:15];
//    NSLayoutConstraint *layoutAttributeRight = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeRight constant:-15];
//    NSLayoutConstraint *layoutAttributeTop = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeTop constant:15];
//    NSLayoutConstraint *layoutAttributeBottom = [self equallyRelatedConstraintWithView:self.contentLabel attribute:NSLayoutAttributeBottom constant:-15];
//
//    [self.contentView addConstraint:layoutAttributeLeft];
//    [self.contentView addConstraint:layoutAttributeRight];
//    [self.contentView addConstraint:layoutAttributeTop];
//    [self.contentView addConstraint:layoutAttributeBottom];
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
    _listModel = listModel;
    self.contentLabel.text = listModel.content;
    self.hidenLabel.hidden = listModel.isHidden;
    
    //约束条件分散添加是有效的
//    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.contentView.mas_bottom).offset(-listModel.bottomSpace);
//    }];
    
    //mas_updateConstraints只能改变常数值constant，如果要改变依赖关系，则无法做到
//    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        if (listModel.isHidden) {
//            make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
//        } else {
//            make.bottom.equalTo(self.contentView.mas_bottom).offset(-45);
//        }
//    }];
    
    //重新创建约束（不是全部，重新创建的是想要更新的约束）
    // 让约束失效（内部调用uninstall，从约束组内移除，由于当前约束是弱引用，没有被其他指针强引用着则会被系统回收）
    [self.constraint uninstall];
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (listModel.isHidden) {
            self.constraint = make.top.equalTo(self.changeButton.mas_bottom).offset(15);
        } else {
            self.constraint = make.top.equalTo(self.hidenLabel.mas_bottom).offset(15);
        }
    }];
}

- (void)change:(UIButton *)sender {

}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.backgroundColor = [UIColor yellowColor];
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setTitle:@"Change" forState:UIControlStateNormal];
        [_changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _changeButton.backgroundColor = [UIColor blueColor];
        [_changeButton addTarget:self action:@selector(change:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}

- (UILabel *)hidenLabel {
    if (!_hidenLabel) {
        _hidenLabel = [[UILabel alloc] init];
        _hidenLabel.font = [UIFont systemFontOfSize:15];
        _hidenLabel.textColor = [UIColor blackColor];
        _hidenLabel.numberOfLines = 0;
        _hidenLabel.backgroundColor = [UIColor greenColor];
        _hidenLabel.text = @"可隐藏";
        [_hidenLabel sizeToFit];
    }
    return _hidenLabel;
}

@end
