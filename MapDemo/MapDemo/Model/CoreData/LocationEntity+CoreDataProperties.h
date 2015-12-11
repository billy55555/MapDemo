//
//  LocationEntity+CoreDataProperties.h
//  MapDemo
//
//  Created by Junan on 15/12/4.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LocationEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSNumber *speed;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longtitude;

@end

NS_ASSUME_NONNULL_END
