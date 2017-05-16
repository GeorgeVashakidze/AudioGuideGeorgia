//
//  PreferenceManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/15/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "PreferenceManager.h"

@implementation PreferenceManager
+(id) sharedManager{
    static PreferenceManager *sharedmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedmanager = [[self alloc] init];
    });
    return sharedmanager;
}
@end
