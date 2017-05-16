//
//  ServiceUpdateManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/6/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ServiceUpdateManager.h"

@implementation ServiceUpdateManager
+(id) sharedManager{
    static ServiceUpdateManager *sharedmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedmanager = [[self alloc] init];
    });
    return sharedmanager;
}

-(id) init{
    if(self = [super init]){
        self.needSightUpdate = YES;
        self.needTourUpdate = YES;
        self.needPageUpdate = YES;
        self.needRestaurantUpdate = YES;
        self.needShopUpdate = YES;
        self.needFestivalUpdate = YES;
        
        self.needSightUpdateForLng = NO;
        self.needTourUpdateForLng = NO;
        self.needPageUpdateForLng = NO;
        self.needRestaurantUpdateForLng = NO;
        self.needShopUpdateForLng = NO;
        self.needFestivalUpdateForLng = NO;
    }
    return self;
}
@end
