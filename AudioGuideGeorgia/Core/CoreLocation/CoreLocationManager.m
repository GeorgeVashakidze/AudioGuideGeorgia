//
//  CoreLocationManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/30/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "CoreLocationManager.h"

@interface CoreLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLGeocoder *geocoder;
@property int loctionFetchCounter;
@end

@implementation CoreLocationManager

- (id)init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.geocoder = [[CLGeocoder alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    }
    return self;
}
-(void)startLocation{
    self.loctionFetchCounter = 0;
    [self.locationManager startUpdatingLocation];
}
-(void)stopLocation{
    [self.locationManager stopUpdatingHeading];
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // this delegate method is constantly invoked every some miliseconds.
    // we only need to receive the first response, so we skip the others.
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation.horizontalAccuracy < 500 && currentLocation.verticalAccuracy < 500) {
        [self.locationDelegate getCurrentLocation:currentLocation];
        
        if (self.loctionFetchCounter > 0) return;
        self.loctionFetchCounter++;

        // after we have current coordinates, we use this method to fetch the information data of fetched coordinate
        [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks lastObject];
            
            NSString *city = placemark.locality;
            if (city == nil) {
                city = @"";
            }
            NSString *country = placemark.country;
            if (country == nil) {
                country = @"";
            }
            NSString *locationStr = [[city stringByAppendingString:@", "] stringByAppendingString:country];
            if (![country isEqualToString:@""] && ![city isEqualToString:@""]) {
                [self.locationDelegate getCurrentCity:locationStr];
            }
            // stopping locationManager from fetching again
            if (!_forMapView) {
                [self.locationManager stopUpdatingLocation];
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}
@end
