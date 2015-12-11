//
//  MainPageVC.m
//  MapDemo
//
//  Created by Junan on 15/12/3.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import "MainPageVC.h"
#import "MapVC.h"
#import "LocationEntity.h"
#import "CoreDataAccessModel.h"

@interface MainPageVC ()<ViewPagerDataSource, ViewPagerDelegate> {
    NSInteger _indexCount;
}
@end

@implementation MainPageVC

- (void)viewDidLoad {
    /* ViewPagerController的初始化必须在viewDidLoad之前 */
    self.dataSource = self;
    self.delegate = self;
    
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的运动轨迹";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    self.tabsViewBackgroundColor = [UIColor whiteColor];
    
    _indexCount = [[CoreDataAccessModel shareInstance] queryIndexCount];
    return _indexCount+1;//历史数据indexCount份，新数据记录用1份
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13.0];
    
    if (index == _indexCount) {
        label.text = [NSString stringWithFormat:@"当前轨迹"];
    } else {
        label.text = [NSString stringWithFormat:@"历史记录%zi", index+1];
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    BOOL isLastPage = (index == _indexCount);
    MapVC *mapVC = [[MapVC alloc] initWithIndex:index isLastPage:isLastPage];
    
    return mapVC;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
            break;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
            break;
        case ViewPagerOptionTabLocation:
            return 1.0;
            break;
        default:
            break;
    }
    
    return value;
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor orangeColor] colorWithAlphaComponent:0.64];
            break;
        default:
            break;
    }
    
    return color;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            break;
        case 1:
            break;
        default:
            break;
    }
}
@end
