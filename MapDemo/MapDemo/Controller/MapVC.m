//
//  MapVC.m
//  MapDemo
//
//  Created by Junan on 15/12/3.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import "MapVC.h"
#import "ZDJMapView.h"
#import "CommonDef.h"
#import "LocationModel.h"

@interface MapVC () <UITableViewDataSource, UITableViewDelegate, ZDJMapViewDelegate>
@property (nonatomic) ZDJMapView *mapView;
@property (nonatomic) UITableView *tableView;

@end

@implementation MapVC

- (id)initWithIndex:(NSInteger)index
         isLastPage:(BOOL)isLastPage
{
    if (self = [super init]) {
        self.index = index;
        self.isLastPage = isLastPage;
//        self.locationDeatailArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZDJMapViewDelegate
- (void)reloadLocationDeatilInfo:(NSMutableArray *)locationDeatailArray {
    [self.tableView reloadData];
    
    // 自动滚动到底部
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mapView.locationDeatailArray.count - 1
                                                          inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom
                              animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mapView.locationDeatailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapDemoCell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    LocationModel *detailModel = [self.mapView.locationDeatailArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%zi.时刻:%@ \n    位置:%f %f \n    速度:%f",
                           indexPath.row+1,
                           detailModel.time,
                           [detailModel.latitude doubleValue],
                           [detailModel.longtitude doubleValue],
                           [detailModel.speed doubleValue]];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 选中某cell,在地图上表示大头针
    [self.mapView addAnnotationAtPointIndex:indexPath.row];
}

#pragma mark - 暂无

#pragma mark - setter and getter
- (ZDJMapView *)mapView {
    if (!_mapView) {
        _mapView = [[ZDJMapView alloc] initWithFrame:CGRectMake(0, 0, SelfViewWidth, SelfViewHeight/2)
                                               index:self.index
                                          isLastPage:self.isLastPage
                                            delegate:self];
        _mapView.delegate = self;
    }
    
    return _mapView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat topY = CGRectGetMaxY(self.mapView.frame)+5;
        CGFloat height = SelfViewHeight-20-44-44-topY;//减去状态栏，导航栏，ViewerPage栏，地图高度
        
        NSLog(@"SelfViewHeight:%f", SelfViewHeight);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topY, SelfViewWidth, height)
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    
    return _tableView;
}
@end
