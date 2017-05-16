//
//  FestivalsModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/27/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SightBase.h"
#import "Constants.h"

@interface FestivalsModel : SightBase
@property NSString *address;
@property NSString *contact;
@property NSString *typeFestival;
@property NSString *venueName;
@property NSDate *eventDate;
-(void)parsModel:(NSDictionary*)dic;
@end
