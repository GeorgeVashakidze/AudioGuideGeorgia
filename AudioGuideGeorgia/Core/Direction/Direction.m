//
//  Direction.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "Direction.h"

@implementation Direction

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)getDirection:(CLLocationCoordinate2D)aPoint and:(CLLocationCoordinate2D)bPoint{
    MBDirections *directions = [MBDirections sharedDirections];
    
    NSArray<MBWaypoint *> *waypoints = @[
                                         [[MBWaypoint alloc] initWithCoordinate:aPoint coordinateAccuracy:-1 name:@"Mapbox"],
                                         [[MBWaypoint alloc] initWithCoordinate:bPoint coordinateAccuracy:-1 name:@"White House"],
                                         ];
    MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:waypoints
                                                      profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    options.includesSteps = YES;
    
    NSURLSessionDataTask *task = [directions calculateDirectionsWithOptions:options
                                                          completionHandler:^(NSArray<MBWaypoint *> * _Nullable waypoints,
                                                                              NSArray<MBRoute *> * _Nullable routes,
                                                                              NSError * _Nullable error) {
                                                              if (error) {
                                                                  NSLog(@"Error calculating directions: %@", error);
                                                                  return;
                                                                }
                                                              
                                                              MBRoute *route = routes.firstObject;
                                                              [_delegateDirection getDirection:route];
                                                          }];
}
@end
