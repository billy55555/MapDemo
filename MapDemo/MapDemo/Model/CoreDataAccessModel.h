//
//  CoreDataAccessModel.h
//  MapDemo
//
//  Created by Junan on 15/12/4.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationModel;

@interface CoreDataAccessModel : NSObject

+(instancetype) shareInstance ;

// ----插入新的轨迹数据----
- (void)addData:(LocationModel *)addEntity isNewLine:(BOOL)isNewLine;

// ----查询----
// 已记录的轨迹条数
- (NSInteger)queryIndexCount;

// 已记录的所有轨迹数据
- (NSMutableArray *)queryAllData;

// 已记录的某条轨迹数据
- (NSMutableArray *)queryWithIndex:(NSInteger)index;

// ----删除（暂未使用）----
- (void)delAtIndex:(NSInteger)index;
@end
