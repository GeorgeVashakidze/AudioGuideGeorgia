//
//  SharedPreferenceManager.h
//  TKT.GE
//
//  Created by Tornike Davitashvili on 11/15/16.
//  Copyright © 2016 Lemondo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CityModel;
@interface SharedPreferenceManager : NSObject
+ (void)saveLanguage:(NSString*)language;
+ (NSString*)getLanguage;
+ (UIImage*)getProfileImage:(NSString*)userID;
+ (void)setProfileImage:(UIImage*)profileImage withID:(NSString*)userID;
+ (NSDictionary*)getUserInfo;
+ (void)saveUserInfo:(NSDictionary*)userInfo;
+ (NSString*)getUserToken;
+ (void)setUserToken:(NSString*)token;
+ (void)saveCurrentLocation:(CityModel*)currentLocation;
+ (CityModel*)getCurrentLocation;
+ (NSDictionary*)getPreferences;
+ (void)savePreferences:(NSDictionary*)dic;
+ (NSURL*)getFacebookURl:(NSString*)userID;
+ (void)saveFacebookURl:(NSURL*)facebookURl withID:(NSString*)userID;
+ (void)saveSubscriber:(NSString *)subscriberBase;
+ (NSString *)getSubscriber;
+ (void)saveRestore:(NSNumber*)restoreCompleted;
+ (NSNumber*)getSaveRestore;
+ (void)saveDownloadPack:(NSNumber*)downloadPack;
+ (NSNumber*)getDownloadPack;
+ (void)saveDownloadToursID:(NSDictionary *)buyTour;
+ (NSArray*)getSaveToursIDs;
+ (void)removeDownloadToursID:(NSDictionary *)buyTour;
@end
