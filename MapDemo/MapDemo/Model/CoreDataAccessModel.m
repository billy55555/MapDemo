//
//  CoreDataAccessModel.m
//  MapDemo
//
//  Created by Junan on 15/12/4.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import "CoreDataAccessModel.h"
#import "AppDelegate.h"
#import "LocationModel.h"
#import "LocationEntity.h"
#import "IndexEntity.h"

static CoreDataAccessModel* _instance = nil;

@interface CoreDataAccessModel()
@property(nonatomic,retain)AppDelegate* myAppDelegate;
@end

@implementation CoreDataAccessModel

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    });
    
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

#pragma mark - CoreData Access
//插入数据(detail)
- (void)addData:(LocationModel *)locationModel isNewLine:(BOOL)isNewLine {
    NSInteger maxIndex = [self queryMaxIndex];
    
    if (isNewLine) {
        maxIndex += 1;
        [self addIndex:maxIndex];
    }
    
    LocationEntity* entity = (LocationEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationEntity"
                                                                             inManagedObjectContext:_myAppDelegate.managedObjectContext];
    entity.index = [NSNumber numberWithInteger:maxIndex];
    entity.time = locationModel.time;
    entity.speed = locationModel.speed;
    entity.latitude = locationModel.latitude;
    entity.longtitude = locationModel.longtitude;
    
    NSError* error;
    BOOL isSaveSuccess=[_myAppDelegate.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"addData:Error:%@",error);
    }else{
        NSLog(@"addData:Save successful!");
    }
}

//插入数据(index)
- (void)addIndex:(NSInteger)index {
    IndexEntity* entity = (IndexEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"IndexEntity"
                                                                       inManagedObjectContext:_myAppDelegate.managedObjectContext];
    entity.index = [NSNumber numberWithInteger:index];
    
    NSError* error;
    BOOL isSaveSuccess=[_myAppDelegate.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"addIndex:Error:%@",error);
    }else{
        NSLog(@"addIndex:Save successful!");
    }
}

// 查询最大index
-(NSInteger)queryMaxIndex {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* user =[NSEntityDescription entityForName:@"IndexEntity"
                                           inManagedObjectContext:_myAppDelegate.managedObjectContext];
    [request setEntity:user];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResult=[[_myAppDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"query:Error:%@",error);
    }
    NSLog(@"The count of IndexEntity: %zi", [mutableFetchResult count]);
    
    NSInteger maxIndex = -1;
    for (IndexEntity* entity in mutableFetchResult) {
        //        NSLog(@"query:index:%zi", [entity.index integerValue]);
        NSInteger index = [entity.index integerValue];
        if (index > maxIndex) {
            maxIndex = index;
        }
    }
    
    return maxIndex;
}

- (NSInteger)queryIndexCount {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* user =[NSEntityDescription entityForName:@"IndexEntity"
                                           inManagedObjectContext:_myAppDelegate.managedObjectContext];
    [request setEntity:user];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResult=[[_myAppDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"query:Error:%@",error);
    }
    NSLog(@"The count of IndexEntity: %zi", [mutableFetchResult count]);
    return [mutableFetchResult count];
}

//查询
- (NSMutableArray *)queryAllData {
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"LocationEntity"
                                          inManagedObjectContext:_myAppDelegate.managedObjectContext];
    [request setEntity:user];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResult=[[_myAppDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"query:Error:%@",error);
    }
    NSLog(@"The count of LocationEntity: %zi", [mutableFetchResult count]);
    for (LocationEntity* entity in mutableFetchResult) {
        NSLog(@"query:index:%zi----time:%@------latitude:%f------longtitude:%f",
              [entity.index integerValue], entity.time, [entity.latitude doubleValue], [entity.longtitude doubleValue]);
    }
    
    return mutableFetchResult;
}

- (NSMutableArray *)queryWithIndex:(NSInteger)index {
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"LocationEntity"
                                          inManagedObjectContext:_myAppDelegate.managedObjectContext];
    [request setEntity:user];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"index==%i", index];
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResult=[[_myAppDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"query:Error:%@",error);
    }
    NSLog(@"The count of LocationEntity: %zi", [mutableFetchResult count]);
    for (LocationEntity* entity in mutableFetchResult) {
        NSLog(@"query:index:%zi----time:%@------latitude:%f------longtitude:%f",
              [entity.index integerValue], entity.time, [entity.latitude doubleValue], [entity.longtitude doubleValue]);
    }
    
    return mutableFetchResult;
}

////更新
//- (void)update {
//    NSFetchRequest* request = [[NSFetchRequest alloc] init];
//    NSEntityDescription* entity = [NSEntityDescription entityForName:@"LocationEntity"
//                                          inManagedObjectContext:_myAppDelegate.managedObjectContext];
//    [request setEntity:entity];
//    //查询条件
//    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"name==%@",@"chen"];
//    [request setPredicate:predicate];
//    NSError* error=nil;
//    NSMutableArray* mutableFetchResult=[[_myAppDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
//    if (mutableFetchResult==nil) {
//        NSLog(@"Error:%@",error);
//    }
//    NSLog(@"The count of entry: %zi",[mutableFetchResult count]);
//    //更新age后要进行保存，否则没更新
//    for (LocationEntity* entity in mutableFetchResult) {
//        entity.time = @"12";
//    }
//    [_myAppDelegate.managedObjectContext save:&error];
//}

//删除（暂未使用）
- (void)delAtIndex:(NSInteger)index {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"LocationEntity"
                                              inManagedObjectContext:_myAppDelegate.managedObjectContext];
    [request setEntity:entity];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"name==%zi",@"index"];
    [request setPredicate:predicate];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[_myAppDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error:%@",error);
    }
    NSLog(@"The count of entry: %zi",[mutableFetchResult count]);
    for (LocationEntity* entity in mutableFetchResult) {
        [_myAppDelegate.managedObjectContext deleteObject:entity];
    }
    
    if ([_myAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
}
@end
