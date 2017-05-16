//
//  SightBase.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/28/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SightBase : NSObject
@property NSMutableArray<NSString*> *imagesArray;
@property NSString *imagesFirst;
@property NSString *sightDescription;
@property NSNumber *sightID;
@property NSNumber *sightLat;
@property NSNumber *sightLng;
@property NSString *sightTitle;
@property NSDate *date;
@end
