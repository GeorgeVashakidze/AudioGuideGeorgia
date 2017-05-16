//
//  SightsViewController.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>

@class CityModel;

@protocol DelegateForMapView <NSObject>

-(void)selectObject:(CLLocationCoordinate2D)coordinates;

@end

@interface SightsViewController : UIViewController
@property BOOL isFromMap;
@property (weak,nonatomic) id<DelegateForMapView> forMapDelegate;
@property CityModel *currentCity;
@end
