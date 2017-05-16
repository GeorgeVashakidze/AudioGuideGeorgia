//
//  CityModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Coding.h"
#import "Constants.h"

@interface CityModel : NSObject <NSCoding>
@property NSNumber *cityID;
@property NSString *cityTitle;
@property NSString *keywords;
@property NSDate *date;
@property int priority;
@property double north;
@property double south;
@property double west;
@property double east;
@property NSString *imagesFirst;
@property NSMutableArray<NSString*>* images;
-(void)parsModel:(NSDictionary*)dic;
@end
