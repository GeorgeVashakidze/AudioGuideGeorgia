//
//  ServiceManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ParseModels.h"
#import "LanguageManager.h"

@protocol ServicesManagerDelegate <NSObject>

@optional

- (void)getTours:(NSArray<ToursModel*>*)tours;
- (void)errorGetTours:(NSError*)error;
- (void)getTourDetail:(ToursModel*)tours;

- (void)getSights:(NSArray<SightModel*>*)sights;
- (void)errorGetSights:(NSError*)error;

- (void)getPages:(NSArray<PagesModel*>*)pages;
- (void)errorGetPages:(NSError*)error;

- (void)getShops:(NSArray<ShopsModel*>*)shops;
- (void)errorgetShop:(NSError*)error;

- (void)getRestaurant:(NSArray<RestaurantsModel*>*)restaurants;
- (void)errorgetRestaurants:(NSError*)error;

- (void)getUserProfile:(NSDictionary*)user;
- (void)errorGetUserProfile:(NSError*)error;

- (void)loginUser:(NSDictionary*)token;
- (void)errorLoginUser:(NSError*)error;

- (void)registerUser:(NSDictionary*)user;
- (void)errorRegisterUser:(NSError*)error;

- (void)getFestivals:(NSArray<FestivalsModel*>*)festivals;
- (void)errorgetFestivals:(NSError*)error;

- (void)getTourFilters:(NSArray<FilterModel*>*)tourFilter;
- (void)errorgetTourFilter:(NSError*)error;

- (void)getNationalities:(NSArray<NationalitiesModel*>*)tourFilter;
- (void)errorgetNationalities:(NSError*)error;

- (void)getCityModel:(NSArray<CityModel*>*)tourFilter;
- (void)errorgetCityModel:(NSError*)error;

- (void)completedDownloadTour:(NSString*)filePath withFileName:(NSString*)fileName withID:(NSString*)sightsID;
- (void)progressDownload:(float)progress;

- (void)updateUser:(NSDictionary*)user;
- (void)errorUpdateUser:(NSError*)error;

- (void)uploadImage:(NSDictionary*)user;
- (void)errorUploadImage:(NSError*)error;

- (void)setRecept:(NSDictionary*)recept withBase64:(NSString*)base64REcept withTourID:(int)tourID;
- (void)errorSetRecept:(NSError*)error;

- (void)activatePromoCode:(NSDictionary*)response;
- (void)errorActivatePromoCode:(NSError*)error;

- (void)submitTourRaview:(NSDictionary*)response;
- (void)errorSubmitTourRaview:(NSError*)error;

- (void)restorePassword:(NSDictionary*)response;
- (void)errorRestorePasswor:(NSError*)error;

@end

@interface ServiceManager : NSObject
@property (nonatomic, weak) id <ServicesManagerDelegate> delegate;
@property (strong,nonatomic) NSString *hostUrl;
@property (strong, nonatomic) AFURLSessionManager *managerAFUrl;
@property (strong,nonatomic) ParseModels *parser;

- (void)getTours;
- (void)updateTourTolive:(ToursModel*)tours withLive:(int)liveTour;
- (void)updateTourToDelete:(ToursModel*)tours;
- (void)updateAllLiveTourToDelete;
- (void)updateTourToRestore:(int)tourID withTourRecept:(NSString*)tourRecept;
- (void)getSights;
- (void)updateSightAudio:(int)sightID withAudio:(NSString *)audioStr withRecept:(NSString*)recept;
- (void)getTourDetail:(NSNumber*)tourID;
- (void)getPages;
- (void)getShops;
- (void)registerUser:(NSDictionary*)user;
- (void)logiUser:(NSDictionary*)user;
- (void)loginWithFacebook:(NSDictionary*)fbToken;
- (void)getRestaurants;
- (void)getUserProfile:(NSString*)token;
- (void)getFestivals;
- (void)updateTourToNoLive;
- (void)getTourFilters;
- (void)getSightFilters;
- (void)getNationalities;
- (void)getCities;
- (void)downloadTour:(NSString *)fileURL withFileName:(NSString*)filename;
- (void)updateUserProfile:(NSDictionary *)profile withToken:(NSString*)token;
- (void)updateUserImage:(UIImage *)image withToken:(NSString*)token;
- (void)activatePromoCode:(NSString*)promoCode withToken:(NSString*)token;
- (void)setReceptToServer:(NSData *)recept withToken:(NSString *)token withTourID:(int)tourID;
- (void)updateSigtToPass:(int)sightID;
- (void)updateAllTourToDelete;
- (void)submitRaiting:(NSInteger)raiting withTourID:(int)tourID;
- (void)restorePassword:(NSString*)email;
@end
