//
//  DrawStaticCell.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/26/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToursDetailCustomCell;
@class TourDetailModel;
@class RestaurantsModel;
@class ShopsModel;
@class FestivalsModel;
@interface DrawStaticCell : NSObject
@property BOOL isFromInfo;
@property UIFont *dintProBold;
@property UIFont *dintProRegular;
@property UIColor *selectedColor;
-(void)drawTourDetail:(ToursDetailCustomCell*)cell withModel:(TourDetailModel*)model andIndex:(NSIndexPath*)indexPath;
-(void)drawRestaurantDetail:(ToursDetailCustomCell*)cell withModel:(RestaurantsModel*)model andIndex:(NSIndexPath*)indexPath;
-(void)drawShopDetail:(ToursDetailCustomCell *)cell withModel:(ShopsModel *)model andIndex:(NSIndexPath *)indexPath;
-(void)drawFestivalDetail:(ToursDetailCustomCell *)cell withModel:(FestivalsModel *)model andIndex:(NSIndexPath *)indexPath;
@end
