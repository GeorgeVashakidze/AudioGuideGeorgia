//
//  MyToursVC.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class CityModel;
@class ToursModel;
@interface MyToursVC : UIViewController
@property BOOL isFromMenu;
@property BOOL isEmpty;
@property CityModel *currentCity;
@property NSArray<ToursModel*> *filterToursArray;
@end
