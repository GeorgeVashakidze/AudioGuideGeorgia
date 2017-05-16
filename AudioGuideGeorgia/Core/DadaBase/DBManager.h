//------------------------------------------------------------------------------
// PROJECT:  TKT.GE
// VERSION:  1.0.1
// COPYRIGHT © 2016 Lemondo Entertainment. All rights reserved.
//************************************************************************************
//* REPRODUCTION OF ANY KIND, IN WHOLE OR IN PART IN ANY FORM IS STRICTLY PROHIBITED *
//************************************************************************************
// DESCRIPTION:   Tkt.ge Database Manager Class
// FILE NAME:     DB_Manager.h
// AUTHOR:        Rezo Mesarkishvili ( rezo@lemondo.com )
// LAST REVISION: 24 October 2016 by RM
//------------------------------------------------------------------------------

#ifndef TKT_GE_DB_Manager_h
#define TKT_GE_DB_Manager_h

#define DEBUG_LOG 1

@import Foundation;

#import "Constants.h"
@class PagesModel;
@class RestaurantsModel;
@class ShopsModel;
@class FestivalsModel;
@class ToursModel;
@class SightModel;
@class FilterModel;
@class CityModel;
@interface DBManager : NSObject

+ (instancetype) sharedInstance;

- (void) closeDatabase;
- (BOOL) openDatabase;

-(void)setInfoPage:(NSArray<PagesModel*>*)pages needDelete:(BOOL)delete;
-(void)getPages:(void (^)(NSArray<PagesModel *> *))handler;
-(void)deletePages:(int)pageID;

-(void)selectRestaurant:(void (^)(NSArray<RestaurantsModel *> *))handler;
-(void)setRestaurants:(NSArray<RestaurantsModel*>*)restaurant needDelete:(BOOL)delete;
-(void)deleteRestaurants:(int)restID;

-(void)selectShops:(void (^)(NSArray<ShopsModel *> *))handler;
-(void)setShops:(NSArray<ShopsModel*>*)shops needDelete:(BOOL)delete;
-(void)deleteShops:(int)shopID;

-(void)setFestivals:(NSArray<FestivalsModel*>*)festivals;
-(void)selectFestivals:(void (^)(NSArray<FestivalsModel *> *))handler;

-(void)setTours:(NSArray<ToursModel*>*)tours needDelete:(BOOL)delete;
-(void)selectTours:(void (^)(NSArray<ToursModel *> *))handler;
-(void)selectTours:(int)tourID withHandle:(void (^)(ToursModel *))handler;
-(void)deleteTours:(int)tourID;
-(void)updateTourTolive:(ToursModel*)tours withLive:(int)liveTour;
-(void)updateTours:(NSArray<ToursModel *> *)tours;
-(void)updateTourToDelete:(ToursModel*)tours;
-(void)updateAllLiveTourToDelete;
-(void)updateTourToNoLive;
-(void)updateTourToRestore:(int)tourID withTourRecept:(NSString*)tourRecept;
-(void)submitRaiting:(NSInteger)raiting withTourID:(int)tourID;
-(void)updateAllTourToDelete;

-(void)setSights:(NSArray<SightModel *> *)tours needDelete:(BOOL)delete;
-(void)selectSights:(void (^)(NSArray<SightModel *> *))handler;
-(void)selectSights:(int)sightID  withHandle:(void (^)(SightModel *))handler;
-(void)deleteSights:(int)sightID;
-(void)updateHoleSigt:(NSArray<SightModel *> *)tours;
-(void)updateSightAudio:(int)sightID withAudio:(NSString *)audioStr withRecept:(NSString*)recept;
-(void)updateSigtToPass:(int)sightID;

-(void)setTourFilter:(NSArray<FilterModel *> *)tours needDelete:(BOOL)delete;
-(void)selectTourFilter:(int)sightID withHandle:(void (^)(FilterModel*))handler;
-(void)selectTourFilter:(void (^)(NSArray<FilterModel *> *))handler;
-(void)deleteTourFilter:(int)sightID;

-(void)setSightFilter:(NSArray<FilterModel *> *)tours needDelete:(BOOL)delete;
-(void)selectSightFilter:(int)sightID withHandle:(void (^)(FilterModel*))handler;
-(void)selectSightFilter:(void (^)(NSArray<FilterModel *> *))handler;
-(void)deleteSightFilter:(int)sightID;

-(void)selectCity:(void (^)(NSArray<CityModel *> *))handler;
-(void)setCity:(NSArray<CityModel*>*)city needDelete:(BOOL)delete;
-(void)deleteCity:(int)restID;


@end

#endif
