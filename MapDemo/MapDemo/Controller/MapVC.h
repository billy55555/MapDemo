//
//  MapVC.h
//  MapDemo
//
//  Created by Junan on 15/12/3.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapVC : UIViewController
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isLastPage;

- (id)initWithIndex:(NSInteger)index
         isLastPage:(BOOL)isLastPage;
@end
