//
//  IndexEntity+CoreDataProperties.h
//  MapDemo
//
//  Created by Junan on 15/12/4.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IndexEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface IndexEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *index;

@end

NS_ASSUME_NONNULL_END
