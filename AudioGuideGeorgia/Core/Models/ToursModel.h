//
//  ToursModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SightModel.h"
#import "CityModel.h"

@class FilterModel;

@interface ToursModel : NSObject
@property NSNumber *toursID;
@property NSMutableArray<CLLocation*> *polyline;
@property NSString *polylineStr;
@property NSNumber *tourTotalPrice;
@property int tourIsFree;
@property NSNumber *cityID;
@property NSNumber *distance;
@property NSNumber *duration;
@property NSString *tourTitle;
@property NSString *tourDescription;
@property NSString *break_tip;
@property NSString *notes;
@property NSString *finish;
@property NSString *start;
@property int isPopupar;
@property NSMutableArray<NSString*> *toursImages;
@property CityModel *tourCity;
@property NSDate *date;
@property NSMutableArray<SightModel*> *sightTour;
@property int tourlive;
@property NSMutableArray<FilterModel*> *category;
@property NSString *receptStr;
@property NSInteger tourRaiting;
@property int isDeleteTour;
@property int tourIsRait;
@property NSArray<NSString*> *userTokens;
-(void)parseModel:(NSDictionary*)dic;
@end
