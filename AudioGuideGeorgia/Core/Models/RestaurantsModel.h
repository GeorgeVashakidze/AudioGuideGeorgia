//
//  RestaurantsModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/22/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SightBase.h"
#import "Constants.h"

@interface RestaurantsModel : SightBase
@property NSString *address;
@property NSString *restType;
@property NSString *webURL;
@property NSString *contact;
@property NSString *restKind;
-(void)parseModel:(NSDictionary*)dic;

@end
