//
//  LXQTableViewAutoViewController.m
//  PointsDemo
//
//  Created by Chiang on 2021/4/15.
//

#import "LXQTableViewAutoViewController.h"
#import "LXQTableViewCell.h"
#import "Masonry.h"
#import "LXQLIstModel.h"

#define kCellIdentifier @"kCellIdentifier"

@interface LXQTableViewAutoViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation LXQTableViewAutoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新数据" style:UIBarButtonItemStylePlain target:self action:@selector(reloadData)];
    
    _dataArray = [NSMutableArray array];
    [self generateTestData];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)generateTestData {
    NSString *str = @"测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯测试紫薯";
    for (int i = 0; i < 10; i++) {
        LXQLIstModel *model = [[LXQLIstModel alloc] init];
        NSInteger index = arc4random()%str.length > 0 ? arc4random()%str.length : 10;
        model.content = [str substringToIndex:index];
        [_dataArray addObject:model];
    }
}

- (void)reloadData {
    [_dataArray removeAllObjects];
    [self generateTestData];
    
    NSDate* tmpStartData = [NSDate date];
    [self.tableView reloadData];
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@"cost time = %f", deltaTime);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

//最好通过代理的方式来设置预估行高，通过属性设置有可能会存在失效的情况
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXQLIstModel * model = _dataArray[indexPath.row];
    return model.cell_height?:UITableViewAutomaticDimension;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXQLIstModel *model = _dataArray[indexPath.row];
    LXQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.listModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    LXQLIstModel *model = _dataArray[indexPath.row];
    if (model.cell_height == 0) {
        CGFloat height = cell.frame.size.height;
        model.cell_height = height;
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[LXQTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 50;
    }
    return _tableView;
}

@end
