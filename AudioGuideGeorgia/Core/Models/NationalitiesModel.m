//
//  NationalitiesModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/8/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "NationalitiesModel.h"

@implementation NationalitiesModel
-(void)parsModel:(NSDictionary *)dic{
    self.modelID = dic[@"id"];
    self.name = dic[@"name"];
}
@end
