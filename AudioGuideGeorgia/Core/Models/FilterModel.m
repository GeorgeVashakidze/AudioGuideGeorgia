//
//  FilterModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/4/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "FilterModel.h"

@implementation FilterModel
-(void)parsMode:(NSDictionary *)dic{
    self.filterID = dic[@"id"];
    self.title = dic[@"name"];
}
@end
