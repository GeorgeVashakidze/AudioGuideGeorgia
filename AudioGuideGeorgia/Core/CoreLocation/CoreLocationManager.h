//
//  CoreLocationManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/30/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

-(void)getCurrentCity:(NSString*)city;
-(void)getCurrentLocation:(CLLocation*)location;
@end


@interface CoreLocationManager : NSObject
@property (weak,nonatomic) id<LocationManagerDelegate> locationDelegate;
@property BOOL forMapView;
-(void)startLocation;
-(void)stopLocation;
@end
