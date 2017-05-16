//
//  SightModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SightBase.h"
@class ToursModel;
@class FilterModel;
@interface SightModel : SightBase
@property NSMutableArray<NSString*> *audiosFirst;
@property NSMutableArray<NSString*> *audiosFirstName;
@property NSUInteger sightPrice;
@property NSMutableArray<ToursModel*> *tours;
@property NSMutableArray<FilterModel*> *category;
@property NSString *audioName_Local;
@property int must_see;
@property NSNumber *auidoFileMemory;
@property BOOL isSelected;
@property NSString *baseReceptStr;
@property int sightIsPass;
@property NSNumber *cityID;
@property int needUpdate;
@property NSNumber *currentDistance;
-(void)parsModel:(NSDictionary*)dic;
@end
