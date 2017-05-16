//
//  MapViewController.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@import Mapbox;
@class SightsViewController;
@class ToursModel;
@class SightModel;
@class SightsClickHelperView;
#define heightShowHelperView 298

@protocol MapViewDelegateForBack <NSObject>

@optional
-(void)buyDemoTour;
-(void)raitTour;

@end

@interface MapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MGLMapView *mapView;
@property (weak,nonatomic) id<MapViewDelegateForBack> delegateForBack;
@property CLLocationCoordinate2D sightChoosenCoordiantes;
@property (weak, nonatomic) SightsClickHelperView *pinHelperView;
@property BOOL needGPSCoordinates;
@property SightModel *modelSights;
@property (strong,nonatomic) ToursModel *tourModel;
@property NSDecimalNumber *currentTourPrice;
-(void)remoteNextTrack;
-(void)prevTrack;
@end
