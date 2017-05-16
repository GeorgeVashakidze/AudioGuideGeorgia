//
//  PreferenceManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/15/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceManager : NSObject
@property BOOL pushNotification;
+(id) sharedManager;
@end
