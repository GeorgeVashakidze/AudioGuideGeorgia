//
//  ServiceManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ServiceManager.h"
#import "LanguageManager.h"
#import "DBManager.h"
#import "ServiceUpdateManager.h"

@implementation ServiceManager{
    NSString *accessToken;
    DBManager *dbManager;
    ServiceUpdateManager *updateManger;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->updateManger = [ServiceUpdateManager sharedManager];
        self->dbManager = [[DBManager alloc] init];
        self->accessToken = @"Bearer ";
        self.hostUrl = [[NSBundle mainBundle] infoDictionary][@"HostUrl"];
        self.parser = [[ParseModels alloc] init];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.managerAFUrl = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

- (void)getTours {

    __block typeof(self) blockSelf = self;
    __block long timeInterval = -1;


    [self->dbManager selectTours:^(NSArray<ToursModel *> *tours) {
        if(tours.count > 0){
            tours = [tours sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = ((ToursModel*)a).toursID;
                NSNumber *second = ((ToursModel*)b).toursID;
                return [second compare:first];
            }];
            if (self->updateManger.needTourUpdate) {
                timeInterval = [self sortArray:tours];
            }
        }else{
            blockSelf->updateManger.needTourUpdate = YES;
        }


        if (self->updateManger.needTourUpdate) {
            NSString *urlStr = @"";
            if (timeInterval == -1 || self->updateManger.needTourUpdateForLng) {
                urlStr = [[self.hostUrl stringByAppendingString:@"/tours/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
            }else{
                urlStr = [NSString stringWithFormat:@"%@/tours/%ld?lang=%@",self.hostUrl,timeInterval,[[LanguageManager sharedManager] getSelectedLanguage]];
            }
            NSURL *URL = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];

            self.managerAFUrl.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

            NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    [blockSelf.delegate errorGetTours:error];
                } else {
                    NSArray *items = responseObject[@"items"];
                    NSArray *deleteItems = responseObject[@"deleted"];
                    if (deleteItems.count > 0) {
                        for (int j = 0; j<deleteItems.count; j++) {
                            NSDictionary *dic = deleteItems[j];
                            [blockSelf->dbManager deleteTours:[dic[@"id"] intValue]];
                        }
                    }
                    if (items.count > 0) {
                        blockSelf->updateManger.needTourUpdate = NO;
                        self->updateManger.needTourUpdateForLng = NO;
                        NSArray<ToursModel*> *toursArray = [self.parser parsToursModel:items];
                        if (timeInterval == -1) {
                            toursArray = [toursArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                NSNumber *first = ((ToursModel*)a).toursID;
                                NSNumber *second = ((ToursModel*)b).toursID;
                                return [second compare:first];
                            }];
                            [blockSelf->dbManager setTours:toursArray needDelete:YES];
                            [blockSelf.delegate getTours:toursArray];
                        }else{

                            if (tours.count > 0) {
                                NSArray<ToursModel *> *_tours = [tours sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                    NSNumber *first = ((ToursModel*)a).toursID;
                                    NSNumber *second = ((ToursModel*)b).toursID;
                                    return [second compare:first];
                                }];
                                for (int j=0; j<toursArray.count; j++) {
                                    int needInsert = 0;
                                    ToursModel *modelUpdate = toursArray[j];
                                    for (int k=0; k<_tours.count; k++) {
                                        ToursModel *modelSelect = _tours[k];
                                        if ([modelUpdate.toursID intValue] == [modelSelect.toursID intValue]) {
                                            [blockSelf->dbManager updateTours:@[modelUpdate]];
                                            break;
                                        }else{
                                            needInsert += 1;
                                        }
                                    }
                                    if (needInsert == _tours.count) {
                                        [blockSelf->dbManager setTours:@[modelUpdate] needDelete:NO];
                                    }
                                }
                                [blockSelf->dbManager selectTours:^(NSArray<ToursModel *> *tours) {
                                    tours = [tours sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                        NSNumber *first = ((ToursModel*)a).toursID;
                                        NSNumber *second = ((ToursModel*)b).toursID;
                                        return [second compare:first];
                                    }];
                                    [blockSelf.delegate getTours:tours];
                                }];
                            }else{
                                [blockSelf.delegate errorGetTours:nil];
                            }
                        }
                    }
                }
            }];
            [dataTask resume];
        } else {
            [blockSelf.delegate getTours:tours];
        }


    }];

}
-(void)submitRaiting:(NSInteger)raiting withTourID:(int)tourID{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [self.hostUrl stringByAppendingString:@"/tour/vote"];
    NSDictionary *dic = @{@"tour":[NSNumber numberWithInt:tourID],@"vote":[NSNumber numberWithInteger:raiting]};
    [manager POST:urlStr parameters:dic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate submitTourRaview:responseObject];
        [dbManager submitRaiting:raiting withTourID:tourID];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorSubmitTourRaview:error];
    }];
}
-(void)getTourDetail:(NSNumber*)tourID{
    __block typeof(self) blockSelf = self;
    [self->dbManager selectTours:[tourID intValue] withHandle:^(ToursModel *tourModel) {
        if (tourModel) {
            [blockSelf.delegate getTourDetail:tourModel];
        }else{
            [blockSelf.delegate errorGetTours:nil];
        }
    }];
    NSString *urlStr = [[[self.hostUrl stringByAppendingString:@"/tour/"] stringByAppendingString:[tourID stringValue]] stringByAppendingString:[@"/?lang=" stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]]];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [blockSelf.delegate errorGetTours:error];
        } else {
            ToursModel *tourArray = [self.parser parsToursModelDetail:responseObject];
            [blockSelf.delegate getTourDetail:tourArray];
        }
    }];
    [dataTask resume];
}
-(void)updateSigtToPass:(int)sightID{
    [dbManager updateSigtToPass:sightID];
}
-(void)getSights{
    __block typeof(self) blockSelf = self;
    __block long timeInterval = -1;

    [self->dbManager selectSights:^(NSArray<SightModel *> *sight) {

        if (sight.count > 0) {
            if (self->updateManger.needSightUpdate) {
                timeInterval = [self sortArray:sight];
            }
        }else{
            blockSelf->updateManger.needSightUpdate = YES;
        }


        if (self->updateManger.needSightUpdate) {
            NSString *urlStr = @"";
            if (timeInterval == -1) {
                urlStr = [[self.hostUrl stringByAppendingString:@"/sights/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
            }else{
                urlStr = [NSString stringWithFormat:@"%@/sights/%ld?lang=%@",self.hostUrl,timeInterval,[[LanguageManager sharedManager] getSelectedLanguage]];
            }
            NSURL *URL = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];

            self.managerAFUrl.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

            NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    [blockSelf.delegate errorGetSights:error];
                } else {
                    NSArray *items = responseObject[@"items"];
                    NSArray *deleteItems = responseObject[@"deleted"];
                    if (deleteItems.count > 0) {
                        for (int j = 0; j<deleteItems.count; j++) {
                            NSDictionary *dic = deleteItems[j];
                            [blockSelf->dbManager deleteSights:[dic[@"id"] intValue]];
                        }
                    }
                    if (items.count > 0) {
                        blockSelf->updateManger.needSightUpdate = NO;
                        NSArray<SightModel*> *sights = [self.parser parsSightsModel:items];
                        if (timeInterval == -1) {
                            [blockSelf->dbManager setSights:sights needDelete:YES];
                            [blockSelf.delegate getSights:sights];
                        }else{

                            if (sight.count > 0) {
                                for (int j = 0; j<sights.count; j++){
                                    int needInsert = 0;
                                    SightModel *modelUpdate = sights[j];
                                    for (int k = 0; k<sight.count; k++) {
                                        SightModel *modelSelected = sight[k];
                                        if ([modelUpdate.sightID intValue] == [modelSelected.sightID intValue]) {
                                            if (modelSelected.sightPrice == 1) {
                                                modelUpdate.sightPrice = 1;
                                            }
                                            if (modelUpdate.audiosFirstName.count > 0) {
                                                NSString *updateAudio = modelUpdate.audiosFirstName[0];
                                                NSString *selectAudio = modelSelected.audiosFirstName[0];
                                                if (![updateAudio isEqualToString:selectAudio]) {
                                                    modelUpdate.needUpdate = 1;
                                                }
                                            }
                                            [blockSelf->dbManager updateHoleSigt:@[modelUpdate]];
                                            break;
                                        }else{
                                            needInsert += 1;
                                        }
                                    }
                                    if (needInsert == sight.count) {
                                        [blockSelf->dbManager setSights:@[modelUpdate] needDelete:NO];
                                    }
                                }
                                [blockSelf->dbManager selectSights:^(NSArray<SightModel *> *sight) {
                                    [blockSelf.delegate getSights:sight];
                                }];
                            }else{
                                [blockSelf.delegate errorGetSights:nil];
                            }
                        }
                        
                    }
                }
            }];
            [dataTask resume];
        } else {

            [blockSelf.delegate getSights:sight];

        }


    }];

}

-(void)updateSightAudio:(int)sightID withAudio:(NSString *)audioStr withRecept:(NSString*)recept{
    [self->dbManager updateSightAudio:sightID withAudio:audioStr withRecept:recept];
}
-(void)updateTourToDelete:(ToursModel*)tours{
    [dbManager updateTourToDelete:tours];
}
-(void)updateAllLiveTourToDelete{
    [dbManager updateAllLiveTourToDelete];
}
-(void)updateAllTourToDelete{
    [dbManager updateAllTourToDelete];
}
-(void)updateTourToRestore:(int)tourID withTourRecept:(NSString*)tourRecept{
    [dbManager updateTourToRestore:tourID withTourRecept:tourRecept];
}
-(void)getPages{
    __block typeof(self) blockSelf = self;
    __block long timeInterval = -1;
    [self->dbManager getPages:^(NSArray<PagesModel *> *pages) {
        if (pages.count > 0) {
            if (self->updateManger.needPageUpdate) {
                timeInterval = [self sortArray:pages];
            }
            [blockSelf.delegate getPages:pages];
        }else{
            blockSelf->updateManger.needPageUpdate = YES;
            [blockSelf.delegate errorGetPages:nil];
        }
    }];
    if (self->updateManger.needPageUpdate) {
        NSString *urlStr = @"";
        if (timeInterval == -1) {
            urlStr = [[self.hostUrl stringByAppendingString:@"/pages/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
        }else{
            urlStr = [NSString stringWithFormat:@"%@/pages/%ld?lang=%@",self.hostUrl,timeInterval,[[LanguageManager sharedManager] getSelectedLanguage]];
        }
        NSURL *URL = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                [blockSelf.delegate errorGetPages:error];
            } else {
                NSArray *items = responseObject[@"items"];
                NSArray *deleteItems = responseObject[@"deleted"];
                if (deleteItems.count > 0) {
                    for (int j = 0; j<deleteItems.count; j++) {
                        NSDictionary *dic = deleteItems[j];
                        [blockSelf->dbManager deletePages:[dic[@"id"] intValue]];
                    }
                }
                if (items.count > 0) {
                    blockSelf->updateManger.needPageUpdate = NO;
                    NSArray<PagesModel*> *pages = [self.parser parsPagesModel:items];
                    if (timeInterval == -1) {
                        [blockSelf->dbManager setInfoPage:pages needDelete:YES];
                        [blockSelf.delegate getPages:pages];
                    }else{
                        [blockSelf->dbManager setInfoPage:pages needDelete:NO];
                        [blockSelf->dbManager getPages:^(NSArray<PagesModel *> *pages) {
                            if (pages.count > 0) {
                                [blockSelf.delegate getPages:pages];
                            }else{
                                [blockSelf.delegate errorGetPages:nil];
                            }
                        }];
                    }

                }
            }
        }];
        [dataTask resume];
    }
}
-(void)getShops{
    __block typeof(self) blockSelf = self;
    __block long timeInterval = -1;
    [self->dbManager selectShops:^(NSArray<ShopsModel *> *shops) {

        if (shops.count > 0) {
            if (self->updateManger.needShopUpdate) {
                timeInterval = [self sortArray:shops];
            }
        }

        if (self->updateManger.needShopUpdate) {
            NSString *urlStr = @"";
            if (timeInterval == -1) {
                urlStr = [[self.hostUrl stringByAppendingString:@"/shops/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
            }else{
                urlStr = [NSString stringWithFormat:@"%@/shops/%ld?lang=%@",self.hostUrl,timeInterval,[[LanguageManager sharedManager] getSelectedLanguage]];
            }
            NSURL *URL = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            self.managerAFUrl.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                    [blockSelf.delegate errorgetShop:error];
                } else {
                    NSArray *items = responseObject[@"items"];
                    NSArray *deleteItems = responseObject[@"deleted"];
                    if (deleteItems.count > 0) {
                        for (int j = 0; j<deleteItems.count; j++) {
                            NSDictionary *dic = deleteItems[j];
                            [blockSelf->dbManager deleteShops:[dic[@"id"] intValue]];
                        }
                    }
                    if (items.count > 0) {
                        blockSelf->updateManger.needShopUpdate = NO;
                        NSArray<ShopsModel*> *shops = [self.parser parsShops:items];
                        if (timeInterval == - 1) {
                            [blockSelf->dbManager setShops:shops needDelete:YES];
                            [blockSelf.delegate getShops:shops];
                        }else{
                            [blockSelf->dbManager setShops:shops needDelete:NO];
                            [blockSelf->dbManager selectShops:^(NSArray<ShopsModel *> *shops) {
                                if (shops.count > 0) {
                                    [blockSelf.delegate getShops:shops];
                                }else{
                                    [blockSelf.delegate errorgetShop:nil];
                                }
                            }];
                        }
                    }
                }
            }];
            [dataTask resume];
        } else {
            [blockSelf.delegate getShops:shops];
        }

    }];

}

-(void)registerUser:(NSDictionary *)user{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [self.hostUrl stringByAppendingString:@"/auth/register"];
    [manager POST:urlStr parameters:user progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate registerUser:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorRegisterUser:error];
    }];
}
-(void)logiUser:(NSDictionary *)user{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [self.hostUrl stringByAppendingString:@"/auth/login"];
    [manager POST:urlStr parameters:user progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate loginUser:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorLoginUser:error];
    }];
}
-(void)loginWithFacebook:(NSDictionary *)fbToken{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [self.hostUrl stringByAppendingString:@"/auth/facebook"];
    [manager POST:urlStr parameters:fbToken progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate loginUser:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorLoginUser:error];
    }];
}
-(void)getRestaurants{

    __block typeof(self) blockSelf = self;
    __block long timeInterval = -1;

    [self->dbManager selectRestaurant:^(NSArray<RestaurantsModel *> *restaurants) {
        if (restaurants.count > 0) {
            if (self->updateManger.needRestaurantUpdate) {
                timeInterval = [self sortArray:restaurants];
            }
        }else{
            self->updateManger.needRestaurantUpdate = YES;
        }

        if (self->updateManger.needRestaurantUpdate) {
            NSString *urlStr = @"";
            if (timeInterval == -1) {
                urlStr = [[self.hostUrl stringByAppendingString:@"/restaurants/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
            }else{
                urlStr = [NSString stringWithFormat:@"%@/restaurants/%ld?lang=%@",self.hostUrl,timeInterval,[[LanguageManager sharedManager] getSelectedLanguage]];
            }
            NSURL *URL = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            self.managerAFUrl.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    [blockSelf.delegate errorgetRestaurants:error];
                } else {
                    blockSelf->updateManger.needRestaurantUpdate = NO;
                    NSArray *items = responseObject[@"items"];
                    NSArray *deleteItems = responseObject[@"deleted"];
                    if (deleteItems.count > 0) {
                        for (int j = 0; j<deleteItems.count; j++) {
                            NSDictionary *dic = deleteItems[j];
                            [blockSelf->dbManager deleteRestaurants:[dic[@"id"] intValue]];
                        }
                    }
                    if (items.count > 0) {
                        NSArray<RestaurantsModel*> *restaurants = [self.parser parsRestourant:items];
                        if (timeInterval == -1) {
                            [blockSelf->dbManager setRestaurants:restaurants needDelete:YES];
                            [blockSelf.delegate getRestaurant:restaurants];
                        }else{
                            [blockSelf->dbManager setRestaurants:restaurants needDelete:NO];
                            [blockSelf->dbManager selectRestaurant:^(NSArray<RestaurantsModel *> *rest) {
                                if (rest.count > 0) {
                                    [blockSelf.delegate getRestaurant:rest];
                                }else{
                                    [blockSelf.delegate errorgetRestaurants:nil];
                                }
                            }];
                        }
                    }
                }
            }];
            [dataTask resume];
        } else {
            [blockSelf.delegate getRestaurant:restaurants];
        }

    }];
    

}
-(void)getUserProfile:(NSString *)token{
    __block typeof(self) blockSelf = self;
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/users/profile?token="] stringByAppendingString:token];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [blockSelf.delegate errorGetUserProfile:error];
        } else {
            [blockSelf.delegate getUserProfile:responseObject[@"data"]];
        }
    }];
    [dataTask resume];
}
-(void)getFestivals{
    __block typeof(self) blockSelf = self;
    [self->dbManager selectFestivals:^(NSArray<FestivalsModel *> *Festivals) {
        if (Festivals.count > 0) {
            //TODO: Tornike Time intervals
        }

        if (self->updateManger.needFestivalUpdate) {
            NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/events/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
            NSURL *URL = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            self.managerAFUrl.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    [blockSelf.delegate errorgetFestivals:error];
                } else {
                    blockSelf->updateManger.needFestivalUpdate = NO;
                    NSArray<FestivalsModel*> *festivals = [self.parser parsFestivals:responseObject];
                    [blockSelf->dbManager setFestivals:festivals];
                    [blockSelf.delegate getFestivals:festivals];
                }
            }];
            [dataTask resume];
        } else {
            [blockSelf.delegate getFestivals:Festivals];
        }


    }];

}
-(void)getTourFilters{
    __block typeof(self) blockSelf = self;
    [self->dbManager selectTourFilter:^(NSArray<FilterModel *> *filter) {
        if (filter.count == 0) {
            [blockSelf.delegate errorgetTourFilter:nil];
        } else {
            [blockSelf.delegate getTourFilters:filter];
        }
    }];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/tourFilters/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [blockSelf.delegate errorgetTourFilter:error];
        } else {
            NSArray<FilterModel*> *filter = [self.parser parsFilter:responseObject[@"items"]];
            [blockSelf->dbManager setTourFilter:filter needDelete:YES];
            [blockSelf.delegate getTourFilters:filter];
        }
    }];
    [dataTask resume];
}
-(void)getSightFilters{
    __block typeof(self) blockSelf = self;
    [self->dbManager selectSightFilter:^(NSArray<FilterModel *> *filter) {
        if (filter.count == 0) {
            [blockSelf.delegate errorgetTourFilter:nil];
        } else {
            [blockSelf.delegate getTourFilters:filter];
        }
    }];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/sightFilters/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [blockSelf.delegate errorgetTourFilter:error];
        } else {
            NSArray<FilterModel*> *filter = [self.parser parsFilter:responseObject[@"items"]];
            [blockSelf->dbManager setSightFilter:filter needDelete:YES];
            [blockSelf.delegate getTourFilters:filter];
        }
    }];
    [dataTask resume];
}
-(void)getNationalities{
    __block typeof(self) blockSelf = self;
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/nationalities/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [blockSelf.delegate errorgetNationalities:error];
        } else {
            NSArray<NationalitiesModel*> *filter = [self.parser parsNationalities:responseObject[@"items"]];
            [blockSelf.delegate getNationalities:filter];
        }
    }];
    [dataTask resume];
}
-(void)getCities{
    __block typeof(self) blockSelf = self;
    [self->dbManager selectCity:^(NSArray<CityModel *> *city) {
        if (city.count == 0) {
            [blockSelf.delegate errorgetCityModel:nil];
        }else{
            [blockSelf.delegate getCityModel:city];
        }
    }];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/cities/?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.managerAFUrl dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [blockSelf.delegate errorgetCityModel:error];
        } else {
            NSArray<CityModel*> *filter = [self.parser parsCities:responseObject[@"items"]];
            [blockSelf->dbManager setCity:filter needDelete:YES];
            [blockSelf.delegate getCityModel:filter];
        }
    }];
    [dataTask resume];
}

#pragma mark - DownloadTour
- (NSString*)applicationDirectory
{
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager*fm = [NSFileManager defaultManager];
    NSString *dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    if ([appSupportDir count] > 0)
    {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0] stringByAppendingPathComponent:bundleID] ;
        
        
        
        // If the directory does not exist, this method creates it.
        NSError* theError = nil;
        if(![fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&theError]){
            //NSlog(@"error");
        }
    }
    
    return dirPath;
}
-(void)downloadTour:(NSString *)fileURL withFileName:(NSString*)filename{
    
    __block typeof(self) blockSelf = self;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:fileURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            [blockSelf.delegate progressDownload:downloadProgress.fractionCompleted];
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *suportFileUrl = [[[self applicationDirectory] stringByAppendingString:@"/"] stringByAppendingString:filename];
        NSURL *urlLocalFile = [[NSURL alloc] initFileURLWithPath:suportFileUrl];
        return urlLocalFile;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"Error file save %@", filePath);
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            [blockSelf.delegate completedDownloadTour:[filePath absoluteString] withFileName:filename withID:filename];
        });
    }];
    [downloadTask resume];
}
-(void)updateTourToNoLive{
    [self->dbManager updateTourToNoLive];
}
-(void)updateTourTolive:(ToursModel*)tours withLive:(int)liveTour{
    [self->dbManager updateTourTolive:tours withLive:liveTour];
}
-(void)updateUserImage:(UIImage *)image withToken:(NSString*)token{
    __block typeof(self) blockSelf = self;
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/users/upload?token="] stringByAppendingString:token];
    NSData *dataImage = UIImageJPEGRepresentation(image,1);
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:dataImage name:@"file[]" fileName:@"file.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          NSLog(@"PRogrees = %f",uploadProgress.fractionCompleted);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                          [blockSelf.delegate errorUploadImage:error];
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          [blockSelf.delegate uploadImage:responseObject];
                      }
                  }];
    
    [uploadTask resume];
    
}
-(void)updateUserProfile:(NSDictionary *)profile withToken:(NSString*)token{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/users/update?token="] stringByAppendingString:token];
    [manager POST:urlStr parameters:profile progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate updateUser:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorUpdateUser:error];
    }];
}
-(void)restorePassword:(NSString*)email{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = @"https://audioguidegeorgia.com/api/password/email";
    [manager POST:urlStr parameters:@{@"email":email} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate restorePassword:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorRestorePasswor:error];
    }];
}
-(void)activatePromoCode:(NSString *)promoCode withToken:(NSString*)token{
    __block typeof(self) blockSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/users/promotion?token="] stringByAppendingString:token];
    [manager POST:urlStr parameters:@{@"promo":promoCode} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate activatePromoCode:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorActivatePromoCode:error];
    }];
}
-(void)setReceptToServer:(NSData *)recept withToken:(NSString *)token withTourID:(int)tourID{

    
    __block typeof(self) blockSelf = self;
    __block NSString *receptBase64 = [recept base64EncodedStringWithOptions:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlStr = [[self.hostUrl stringByAppendingString:@"/store/receipt/iTunes?receipt="] stringByAppendingString: receptBase64];
    
    [manager POST:urlStr parameters:@{@"receipt":receptBase64} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [blockSelf.delegate setRecept:responseObject withBase64:receptBase64 withTourID:tourID];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [blockSelf.delegate errorSetRecept:error];
    }];
}
#pragma mark - Sort

-(NSTimeInterval)sortArray:(NSArray*)sortedArray{
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"date"
                                        ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedEventArray = [sortedArray
                                 sortedArrayUsingDescriptors:sortDescriptors];
    SightBase *model = sortedEventArray.lastObject;
    NSTimeInterval timeInterval = [model.date timeIntervalSince1970];
    return timeInterval;
}
@end
