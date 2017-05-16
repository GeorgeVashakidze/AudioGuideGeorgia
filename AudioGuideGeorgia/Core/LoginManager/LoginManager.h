//
//  LoginManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/16/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@protocol LoginManagerDelegate <NSObject>
-(void)loginWithFacebookWithInfo:(NSDictionary*)userInfo;
@optional
-(void)getUserFacebookImage:(NSURL*)imageURl;
@end

@interface LoginManager : NSObject
@property (nonatomic,strong) FBSDKLoginManager *login;
@property (weak,nonatomic) id<LoginManagerDelegate> delegateLogin;
-(void)logOutUser;
- (void)loginWithFBWithViewController:(UIViewController*)controller;
-(void)fetchUserInfo;
-(FBSDKAccessToken*)getAccessToken;
@end
