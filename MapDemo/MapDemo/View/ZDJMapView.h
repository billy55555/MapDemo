//
//  ZDJMapView.h
//  MapDemo
//
//  Created by Junan on 15/12/4.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol ZDJMapViewDelegate<NSObject>
@required
- (void)reloadLocationDeatilInfo:(NSMutableArray *)locationDeatailArray;//刷新详细信息
@end

@interface ZDJMapView : UIView
@property (nonatomic, weak) id <ZDJMapViewDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isLastPage;

- (id)initWithFrame:(CGRect) frame
              index:(NSInteger)index
         isLastPage:(BOOL)isLastPage
           delegate:(id)delegate;

//取得轨迹详情(经度，纬度，时刻，速度...)
- (NSMutableArray *)locationDeatailArray;

//添加某个点的大头针
- (void)addAnnotationAtPointIndex:(NSInteger )pointIndex;
@end
