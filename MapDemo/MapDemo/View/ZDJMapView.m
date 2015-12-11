//
//  ZDJMapView.m
//  MapDemo
//
//  Created by Junan on 15/12/4.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import "ZDJMapView.h"
#import "CommonDef.h"
#import "CoreDataAccessModel.h"
#import "LocationModel.h"
#import "LocationEntity.h"

@interface ZDJMapView() <MKMapViewDelegate,CLLocationManagerDelegate> {
    BOOL _isFirstPoint;
}

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) UIButton *stopButton;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableArray *locationArray;    //轨迹绘画用(经度，纬度)
@property (nonatomic) NSMutableArray *locationDeatailArray;//轨迹详情表示用(经度，纬度，时刻，速度...)
@end

@implementation ZDJMapView

- (id)initWithFrame:(CGRect)frame
              index:(NSInteger)index
         isLastPage:(BOOL)isLastPage
           delegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _isFirstPoint = YES;
        
        [self addSubview:self.mapView];
        [self addSubview:self.stopButton];
        
        _locationArray = [[NSMutableArray alloc] init];
        _locationDeatailArray = [[NSMutableArray alloc] init];
        
        self.index = index;
        self.isLastPage = isLastPage;
        self.delegate = delegate;
        
        if (!isLastPage) {
            _stopButton.enabled = NO;
            
            // 取历史数据
            NSMutableArray *array = [[CoreDataAccessModel shareInstance] queryWithIndex:self.index];
            
            for (LocationEntity* entity in array) {
                // 描画用位置信息
                CLLocation *currLocation = [[CLLocation alloc] initWithLatitude:[entity.latitude doubleValue] longitude:[entity.longtitude doubleValue]];
                [_locationArray addObject:currLocation];
                
                // 各位置的详细信息
                LocationModel *model = [[LocationModel alloc] init];
                model.time = entity.time;
                model.speed = entity.speed;
                model.latitude = entity.latitude;
                model.longtitude = entity.longtitude;
                [_locationDeatailArray addObject:model];
            }
            
            NSLog(@"_locationArray.count:%zi", [_locationArray count]);
            
            // 更新运动轨迹描画
            [self updateOverlay];
            // 调整地图显示范围
            [self setHistoryMapZone];
            
//            // 详细信息更新
//            if ((self.delegate) && ([self.delegate respondsToSelector:@selector(reloadLocationDeatilInfo:)])) {
//                [self.delegate reloadLocationDeatilInfo:_locationDeatailArray];
//            }
        } else {
            // 初始化定位管理器
            if (!_locationManager) {
                _locationManager=[[CLLocationManager alloc] init];
                _locationManager.delegate = self;
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;//有时间做成用户可设置
                _locationManager.distanceFilter = 100;//有时间做成用户可设置
                if (iOSVersion >= 8) {
                    [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
                }
                [_locationManager startUpdatingLocation];//开启定位
            }
        }
    }
    return self;
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //    CLLocationCoordinate2D loc = [userLocation coordinate];
    
    //    NSLog(@"mapView:didUpdateUserLocation la---%f, lo---%f",loc.latitude, loc.longitude);
    
    //    userLocation.title = @"地名";
    //    userLocation.subtitle = @"地点的详细";
    
    //放大地图到自身的经纬度位置。
    //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    //    [self.mapView setRegion:region animated:YES];
    
    //这个方法可以设置地图精度以及显示用户所在位置的地图
    //    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    //    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    //    [mapView setRegion:region animated:YES];
    
    //设置用户位置居中
    //    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *overlayRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        overlayRenderer.strokeColor = [UIColor blueColor];
        overlayRenderer.fillColor = [UIColor blueColor];
        overlayRenderer.lineWidth = 3;
        
        return overlayRenderer;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    
    static NSString *defaultPinID = @"com.invasivecode.pin";
    pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if ( pinView == nil ) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    pinView.canShowCallout = YES;
    pinView.animatesDrop = YES;
    
    return pinView;
}

#pragma mark - CLLocationManagerDelegate
/**
 *定位成功，回调此方法
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation = [locations lastObject];
    //    NSLog(@"locationManager:didUpdateLocations la---%f, lo---%f",currLocation.coordinate.latitude, currLocation.coordinate.longitude);
    
    [_locationArray addObject:currLocation];
    NSLog(@"_locationArray.count:%zi", [_locationArray count]);
    [self updateOverlay];
    
    LocationModel *locationModel = [[LocationModel alloc] init];
    locationModel.time = [self stringFromDate:currLocation.timestamp];
    locationModel.speed = [NSNumber numberWithDouble:currLocation.speed];
    locationModel.latitude = [NSNumber numberWithDouble:currLocation.coordinate.latitude];
    locationModel.longtitude = [NSNumber numberWithDouble:currLocation.coordinate.longitude];
    [_locationDeatailArray addObject:locationModel];
    
    BOOL isNewLine;
    if (self.isLastPage && _isFirstPoint) {
        isNewLine = YES;
    }
    _isFirstPoint = NO;
    
    [[CoreDataAccessModel shareInstance] addData:locationModel isNewLine:isNewLine];
    
    // 详细信息更新
    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(reloadLocationDeatilInfo:)])) {
        [self.delegate reloadLocationDeatilInfo:_locationDeatailArray];
    }
}

/**
 *定位失败，回调此方法
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

#pragma mark - Private Method
- (void)updateOverlay {
    
    MKMapPoint *arrayPoint = malloc(sizeof(MKMapPoint) * _locationArray.count);
    for (int i = 0; i < _locationArray.count; i++) {
        CLLocation *location = [_locationArray objectAtIndex:i];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        arrayPoint[i] = point;
    }
    MKPolyline *line = [MKPolyline polylineWithPoints:arrayPoint count:_locationArray.count];
    [_mapView addOverlay:line];
    free(arrayPoint);
}

// 计算所有点组成区域的范围，以此决定显示的地图区域
- (void)setHistoryMapZone {
    CLLocationDegrees maxLatitude = 0;
    CLLocationDegrees minLatitude = 0;
    CLLocationDegrees maxLongitude = 0;
    CLLocationDegrees minLongitude = 0;
    BOOL firstLocation = YES;
    
    for (CLLocation *location in _locationArray) {
        if (firstLocation) {
            maxLatitude = location.coordinate.latitude;
            minLatitude = location.coordinate.latitude;
            maxLongitude = location.coordinate.longitude;
            minLongitude = location.coordinate.longitude;
            firstLocation = NO;
        } else {
            if (location.coordinate.latitude > maxLatitude) {
                maxLatitude = location.coordinate.latitude;
            }
            if (location.coordinate.latitude < minLatitude) {
                minLatitude = location.coordinate.latitude;
            }
            if (location.coordinate.longitude > maxLongitude) {
                maxLongitude = location.coordinate.longitude;
            }
            if (location.coordinate.longitude < minLongitude) {
                minLongitude = location.coordinate.longitude;
            }
        }
    }
    
    //这个方法可以设置地图精度以及显示用户所在位置的地图
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLatitude-minLatitude)*1.5,
                                                 (maxLongitude-minLongitude)*1.5);
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((maxLatitude+minLatitude)/2,
                                                                         (maxLongitude+minLongitude)/2);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    [self.mapView setRegion:region animated:YES];
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

// 停止定位按钮事件
- (void)stopButtonClick {
    
    [_locationManager stopUpdatingLocation];//停止定位
    _stopButton.enabled = NO;
    self.mapView.userTrackingMode = MKUserTrackingModeNone; // the user's location is not followed
    
    // 调整地图显示范围
    [self setHistoryMapZone];
}

#pragma mark - Public Method
- (void)addAnnotationAtPointIndex:(NSInteger )pointIndex {
    LocationModel *detailModel = [self.locationDeatailArray objectAtIndex:pointIndex];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([detailModel.latitude doubleValue],
                                                                   [detailModel.longtitude doubleValue]);
    
    // 删除之前的大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [annotation setTitle:[NSString stringWithFormat:@"第%zi个点", pointIndex+1]];
    [annotation setSubtitle:[NSString stringWithFormat:@"总共记录了%zi个点", self.locationDeatailArray.count]];
    
    //触发viewForAnnotation
    [self.mapView addAnnotation:annotation];
}

#pragma mark - setter and getter
- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;   // default is MKUserTrackingModeNone
        _mapView.mapType = MKMapTypeStandard;                   //default value
        _mapView.delegate = self;
    }
    
    return _mapView;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _stopButton.frame = CGRectMake(self.frame.size.width-60-5, 5, 60, 44);
        
        [_stopButton setTitle:@"结束记录" forState:UIControlStateNormal];
        [_stopButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_stopButton setTitle:@"已结束" forState:UIControlStateDisabled];
        [_stopButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        [_stopButton setBackgroundColor:[UIColor whiteColor]];
        _stopButton.layer.cornerRadius = 5;
        _stopButton.layer.masksToBounds = YES;
        
        [_stopButton addTarget:self action:@selector(stopButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _stopButton;
}
@end
