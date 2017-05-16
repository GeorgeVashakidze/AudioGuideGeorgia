//
//  ServiceUpdateManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/6/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceUpdateManager : NSObject
@property BOOL needSightUpdate;
@property BOOL needTourUpdate;
@property BOOL needPageUpdate;
@property BOOL needRestaurantUpdate;
@property BOOL needShopUpdate;
@property BOOL needFestivalUpdate;

@property BOOL needSightUpdateForLng;
@property BOOL needTourUpdateForLng;
@property BOOL needPageUpdateForLng;
@property BOOL needRestaurantUpdateForLng;
@property BOOL needShopUpdateForLng;
@property BOOL needFestivalUpdateForLng;
+ (id) sharedManager;
@end
