//
//  LoginManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/16/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LoginManager.h"
#import "SharedPreferenceManager.h"

@implementation LoginManager
-(instancetype)init{
    if (self = [super init]) {
        self.login = [[FBSDKLoginManager alloc] init];
    }
    return self;
}
- (void)loginWithFBWithViewController:(UIViewController*)controller{
//        __block typeof(self) blockSelf = self;
        [self.login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:controller handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"Error on facebook login %@", error);
            } else if (result.isCancelled){
                
            }else{
                FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
                NSDictionary *dic = @{@"token":token.tokenString};
                [self fetchUserInfo];
                [self.delegateLogin loginWithFacebookWithInfo:dic];

            }
        }];
}

-(void)fetchUserInfo
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, email,first_name,gender,last_name"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",result[@"id"]]];

                     [SharedPreferenceManager saveFacebookURl:imageUrl withID:result[@"email"]];
                 
                 [self.delegateLogin getUserFacebookImage:imageUrl];
             }
         }];
    }
}
-(FBSDKAccessToken *)getAccessToken{
    return [FBSDKAccessToken currentAccessToken];
}
-(void)logOutUser{
    [self.login logOut];
}
@end
