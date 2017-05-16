//
//  Constants.h
//  TKT.GE
//
//  Created by Tornike Davitashvili on 10/10/16.
//  Copyright © 2016 Lemondo. All rights reserved.
//
#ifndef Constants_h
#define Constants_h


#endif /* Constants_h */
#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.width == 320 && [[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.width == 320 && [[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.width == 375 && [[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6P ([[UIScreen mainScreen] bounds].size.width == 414 && [[UIScreen mainScreen] bounds].size.height == 736)
#define IS_IPAD    ([[UIScreen mainScreen] bounds].size.width == 768 || [[UIScreen mainScreen] bounds].size.height == 768)
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define CURRENT_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0];
#define AudioUrlHost "https://audioguidegeorgia.com/api/sight/audio/"
#define ImageUrlHost "https://audioguidegeorgia.com/uploads/images/"
typedef enum {
    kErrorServer,
    kErrorTimer
} ErrorType;

typedef enum {
    ka,
    ru,
    en
} Language;

typedef enum : NSInteger {
    kCameraMoveDirectionNone,
    kCameraMoveDirectionUp,
    kCameraMoveDirectionDown,
    kCameraMoveDirectionRight,
    kCameraMoveDirectionLeft
} CameraMoveDirection;

typedef enum {
    restaurants,
    shops,
    festivals,
    unknown
} Inforamtion;
