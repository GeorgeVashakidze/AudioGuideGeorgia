//
//  SharedPreferenceManager.m
//  TKT.GE#0	0x000000010011d478 in +[SharedPreferenceManager loginResponse] at /Users/tornikedavitashvili/Documents/Lemondo Bussnes/OnlineTickets/TKTMobile/ios/TKT.GE/Core/Managers/SharedPreferenceManager.m:28

//
//  Created by Tornike Davitashvili on 11/15/16.
//  Copyright © 2016 Lemondo. All rights reserved.
//

#import "SharedPreferenceManager.h"
#import "CityModel.h"

@implementation SharedPreferenceManager

+(void)saveUserInfo:(NSDictionary*)userInfo{
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"loginUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary*)getUserInfo{
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginUser"];
    if (!userData) {
        return nil;
    }
    NSDictionary* user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    return user;
}

+ (void)saveLanguage:(NSString *)language{
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"appLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (NSString *)getLanguage{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
    if (!language) {
        return nil;
    }
    return language;
}
+ (UIImage*)getProfileImage:(NSString*)userID{
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:userID];
    if (!imageData) {
        return nil;
    }
    
    UIImage *profileImage = [UIImage imageWithData:imageData];
    return profileImage;
}
+ (void)setProfileImage:(UIImage*)profileImage withID:(NSString*)userID{
    NSData *profileImageData = UIImageJPEGRepresentation(profileImage, 1.0f);
    if (!profileImage) {
        profileImageData = UIImagePNGRepresentation(profileImage);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:profileImageData forKey:userID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getUserToken{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"usertoken"];
    if (!token) {
        return nil;
    }
    return token;
}
+(void)setUserToken:(NSString *)token{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"usertoken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+(void)saveCurrentLocation:(CityModel *)currentLocation{
    NSData *location = [NSKeyedArchiver archivedDataWithRootObject:currentLocation];
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:@"currentLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(CityModel*)getCurrentLocation{
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentLocation"];
    if (!userData) {
        return nil;
    }
    CityModel* user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    return user;
}
+(void)savePreferences:(NSDictionary *)dic{
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"preferences"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDictionary *)getPreferences{
    NSData *prefData = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferences"];
    if (!prefData) {
        return nil;
    }
    NSDictionary* preferences = [NSKeyedUnarchiver unarchiveObjectWithData:prefData];
    return preferences;
}
+(void)saveFacebookURl:(NSURL*)facebookURl withID:(NSString*)userID{
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:facebookURl];

    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:userID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSURL*)getFacebookURl:(NSString*)userID{
    NSData *prefData = [[NSUserDefaults standardUserDefaults] objectForKey:userID];
    if (!prefData) {
        return nil;
    }
    NSURL* preferences = [NSKeyedUnarchiver unarchiveObjectWithData:prefData];
    return preferences;
}
+ (void)saveSubscriber:(NSString *)subscriberBase{
    [[NSUserDefaults standardUserDefaults] setObject:subscriberBase forKey:@"subscriber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (NSString *)getSubscriber{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriber"];
    if (!language) {
        return nil;
    }
    return language;
}
+(void)saveRestore:(NSNumber *)restoreCompleted{
    [[NSUserDefaults standardUserDefaults] setObject:restoreCompleted forKey:@"saverestore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSNumber *)getSaveRestore{
    NSNumber *restore = [[NSUserDefaults standardUserDefaults] objectForKey:@"saverestore"];
    if (!restore) {
        return nil;
    }
    return restore;
}
+(void)saveDownloadPack:(NSNumber *)downloadPack{
    [[NSUserDefaults standardUserDefaults] setObject:downloadPack forKey:@"downloadpack"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSNumber *)getDownloadPack{
    NSNumber *downloadpack = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloadpack"];
    if (!downloadpack) {
        return nil;
    }
    return downloadpack;
}
+(void)removeDownloadToursID:(NSDictionary *)buyTour{
    NSMutableArray *downloadTours = [[NSMutableArray alloc] initWithArray:[SharedPreferenceManager getSaveToursIDs]];
    [downloadTours removeObject:buyTour];
    [[NSUserDefaults standardUserDefaults] setObject:downloadTours forKey:@"downloadTours"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)saveDownloadToursID:(NSDictionary *)buyTour{
    NSMutableArray *downloadTours = [[NSMutableArray alloc] initWithArray:[SharedPreferenceManager getSaveToursIDs]];
    [downloadTours addObject:buyTour];
    [[NSUserDefaults standardUserDefaults] setObject:downloadTours forKey:@"downloadTours"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)getSaveToursIDs{
    NSArray *downloadTours = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloadTours"];
    if (!downloadTours) {
        return nil;
    }
    return downloadTours;
}
@end
