//
//  FilterViewController.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CityModel;

@protocol FilterTourDelegate <NSObject>

-(void)filterTour:(NSArray*)categoryID withCity:(BOOL)needCity withNearMee:(BOOL)nearMee withPirceRange:(CGFloat)price;

@end

@interface FilterViewController : UIViewController
@property (weak,nonatomic) id<FilterTourDelegate> filterDelegate;
@property NSArray *filterIDS;
@property CityModel *currentCity;
@property CGFloat tourTotalPrice;
@property BOOL isSelectedFirst;
@property BOOL isSelectedSecond;
@property CGFloat currentPrice;
@end
