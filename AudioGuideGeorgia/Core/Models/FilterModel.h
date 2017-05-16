//
//  FilterModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/4/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterModel : NSObject
@property NSString *title;
@property NSNumber *filterID;
@property NSDate *date;
- (void)parsMode:(NSDictionary*)dic;
@end
