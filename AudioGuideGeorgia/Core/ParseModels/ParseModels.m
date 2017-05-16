//
//  ParseModels.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ParseModels.h"
#import "SharedPreferenceManager.h"

@implementation ParseModels
-(NSArray<ToursModel*>*)parsToursModel:(NSArray *)tours{
    NSArray *data = tours;
    NSMutableArray <ToursModel*> *modelArray = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        ToursModel *model = [[ToursModel alloc] init];
        NSDictionary *dataObj = data[i];
        [model parseModel:dataObj];
        [modelArray addObject:model];
    }
    return modelArray;
}
-(ToursModel*)parsToursModelDetail:(NSDictionary *)tours{
    ToursModel *model = [[ToursModel alloc] init];
    [model parseModel:tours];
    return model;
}
-(NSArray<SightModel *> *)parsSightsModel:(NSArray *)sights{
    NSArray *data = sights;
    NSMutableArray <SightModel*> *modelArray = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        SightModel *model = [[SightModel alloc] init];
        NSDictionary *dataObj = data[i];
        [model parsModel:dataObj];
        [modelArray addObject:model];
    }
    return modelArray;
}
-(NSArray<PagesModel *> *)parsPagesModel:(NSArray *)pages{
    NSMutableArray <PagesModel*> *pageArray = [[NSMutableArray alloc] initWithCapacity:pages.count];
    for (int i = 0; i < pages.count; i++) {
        NSDictionary *dic = pages[i];
        PagesModel *model = [[PagesModel alloc] init];
        [model parseModel:dic];
        [pageArray addObject:model];
    }
    return pageArray;
}
-(NSArray<ShopsModel *> *)parsShops:(NSArray*)shops{
    NSMutableArray <ShopsModel*> *shopArray = [[NSMutableArray alloc] initWithCapacity:shops.count];
    for (int i= 0 ; i<shops.count; i++) {
        ShopsModel *model = [[ShopsModel alloc] init];
        NSDictionary *dic = shops[i];
        [model parsModel:dic];
        [shopArray addObject:model];
    }
    return shopArray;
}
-(NSArray<RestaurantsModel *> *)parsRestourant:(NSArray *)restourant{
    NSMutableArray<RestaurantsModel*> *restourants = [[NSMutableArray alloc] initWithCapacity:restourant.count];
    for (int i=0; i<restourant.count; i++) {
        RestaurantsModel *model = [[RestaurantsModel alloc] init];
        NSDictionary *dic = restourant[i];
        [model parseModel:dic];
        [restourants addObject:model];
    }
    return restourants;
}
-(NSArray<FestivalsModel *> *)parsFestivals:(NSArray *)festivals{
    NSMutableArray<FestivalsModel*> *festivalsArray = [[NSMutableArray alloc] initWithCapacity:festivals.count];
    for (int i=0; i<festivals.count; i++) {
        FestivalsModel *model = [[FestivalsModel alloc] init];
        NSDictionary *dic = festivals[i];
        [model parsModel:dic];
        [festivalsArray addObject:model];
    }
    return festivalsArray;
}
-(NSArray<FilterModel *> *)parsFilter:(NSArray *)filter{
    NSMutableArray<FilterModel*> *filterModel = [[NSMutableArray alloc] initWithCapacity:filter.count];
    for (int i=0; i<filter.count; i++) {
        FilterModel *model = [[FilterModel alloc] init];
        NSDictionary *dic = filter[i];
        [model parsMode:dic];
        [filterModel addObject:model];
    }
    return filterModel;
}
-(NSArray<NationalitiesModel *> *)parsNationalities:(NSArray *)filter{
    NSMutableArray<NationalitiesModel*> *nationalitiesModel = [[NSMutableArray alloc] initWithCapacity:filter.count];
    for (int i=0; i<filter.count; i++) {
        NationalitiesModel *model = [[NationalitiesModel alloc] init];
        NSDictionary *dic = filter[i];
        [model parsModel:dic];
        [nationalitiesModel addObject:model];
    }
    return nationalitiesModel;
}
-(NSArray<CityModel *> *)parsCities:(NSArray *)filter{
    NSMutableArray<CityModel*> *nationalitiesModel = [[NSMutableArray alloc] initWithCapacity:filter.count];
    for (int i=0; i<filter.count; i++) {
        CityModel *model = [[CityModel alloc] init];
        NSDictionary *dic = filter[i];
        [model parsModel:dic];
        [nationalitiesModel addObject:model];
    }
    return nationalitiesModel;
}
@end
