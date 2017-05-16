//
//  ParseModels.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToursModel.h"
#import "PagesModel.h"
#import "ShopsModel.h"
#import "RestaurantsModel.h"
#import "FestivalsModel.h"
#import "FilterModel.h"
#import "NationalitiesModel.h"
#import "CityModel.h"

@interface ParseModels : NSObject
-(NSArray<ToursModel*>*)parsToursModel:(NSArray*)tours;
-(ToursModel*)parsToursModelDetail:(NSDictionary *)tours;
-(NSArray<SightModel*>*)parsSightsModel:(NSArray*)sights;
-(NSArray<PagesModel*>*)parsPagesModel:(NSArray*)pages;
-(NSArray<ShopsModel *> *)parsShops:(NSArray*)shops;
-(NSArray<RestaurantsModel *> *) parsRestourant:(NSArray*)restourant;
-(NSArray<FestivalsModel *> *) parsFestivals:(NSArray*)restourant;
-(NSArray<FilterModel *> *) parsFilter:(NSArray*)filter;
-(NSArray<NationalitiesModel *> *) parsNationalities:(NSArray*)filter;
-(NSArray<CityModel *> *) parsCities:(NSArray*)filter;

@end
