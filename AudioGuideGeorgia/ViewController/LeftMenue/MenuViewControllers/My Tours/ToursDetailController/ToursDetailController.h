//
//  ToursDetailController.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class ShopsModel;
@class RestaurantsModel;
@class FestivalsModel;
@class ToursModel;
@interface ToursDetailController : UIViewController
@property (weak,nonatomic) NSString *titleStr;
@property ShopsModel *shopModel;
@property RestaurantsModel *restModel;
@property FestivalsModel *festivalModel;
@property ToursModel *tourModel;
@property BOOL isFormInfo;
@property BOOL isFromMapTapped;
@property NSNumber *tourID;
@property Inforamtion infoType;
@end
