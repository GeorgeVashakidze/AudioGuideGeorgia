//
//  Direction.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapboxDirections;

@protocol DirectionDelegate <NSObject>

-(void)getDirection:(MBRoute*)route;

@end

@interface Direction : NSObject
@property (weak,nonatomic) id<DirectionDelegate> delegateDirection;
-(void)getDirection:(CLLocationCoordinate2D)aPoint and:(CLLocationCoordinate2D)bPoint;
@end
