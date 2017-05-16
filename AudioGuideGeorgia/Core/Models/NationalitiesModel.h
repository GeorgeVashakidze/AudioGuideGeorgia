//
//  NationalitiesModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/8/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NationalitiesModel : NSObject
@property NSNumber *modelID;
@property NSString *name;
@property NSDate *date;
-(void)parsModel:(NSDictionary*)dic;
@end
