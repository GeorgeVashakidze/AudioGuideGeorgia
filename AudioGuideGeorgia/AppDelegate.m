
//
//  AppDelegate.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/27/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftMenuController.h"
#import "SlideNavigationController.h"
#import "FBSDKCoreKit.h"
#import "MapViewController.h"
#import <HysteriaPlayer/HysteriaPlayer.h>
#import <FBNotifications/FBNotifications.h>
#import "PreferenceManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    BOOL isFirsTime = NO;
    if (!isFirsTime) {
        [self initLeftMenu];
    }
    [self registerPushNotification];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}
-(void)registerPushNotification{
    UIApplication *application = [UIApplication sharedApplication];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
}
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    [FBSDKAppEvents logPushNotificationOpen:userInfo action:identifier];
}
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url options:options];
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    FBNotificationsManager *notificationsManager = [FBNotificationsManager sharedManager];
    [notificationsManager presentPushCardForRemoteNotificationPayload:userInfo
                                                   fromViewController:nil
                                                           completion:^(FBNCardViewController * _Nullable viewController, NSError * _Nullable error) {
                                                               if (error) {
                                                                   completionHandler(UIBackgroundFetchResultFailed);
                                                               } else {
                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                               }
                                                           }];
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [FBSDKAppEvents setPushNotificationsDeviceToken:deviceToken];
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    PreferenceManager *managerPreferences = [PreferenceManager sharedManager];
    if (notificationSettings.types == UIUserNotificationTypeNone) {
        managerPreferences.pushNotification = NO;
    }else{
        managerPreferences.pushNotification = YES;
    }
}
-(void) initLeftMenu{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    LeftMenuController *leftMenu = (LeftMenuController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        UINavigationController *nav=(UINavigationController *)self.window.rootViewController;
        MapViewController *controller = (MapViewController*)[nav.viewControllers lastObject];
        HysteriaPlayer *playerManager = [HysteriaPlayer sharedInstance];

        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [playerManager pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlPlay:{
                double currentTime = playerManager.getPlayingItemCurrentTime;
                if(currentTime > 0){
                    [playerManager play];
                }else{
                    [playerManager fetchAndPlayPlayerItem:0];
                }
            }
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [controller remoteNextTrack];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [controller prevTrack];
                break;
            default:
                break;
        }
    }
}
@end
