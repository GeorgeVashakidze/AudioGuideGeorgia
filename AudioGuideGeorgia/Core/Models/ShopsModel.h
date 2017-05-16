//
//  ShopsModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/22/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SightBase.h"
#import "Constants.h"

@interface ShopsModel : SightBase
@property NSString *contact;
@property NSString *address;
@property NSString *webURL;
@property NSString *typeShop;
-(void)parsModel:(NSDictionary*)dic;
@end
