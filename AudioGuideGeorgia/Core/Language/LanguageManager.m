//
//  LanguageManager.m
//  MyPhone
//
//  Created by Tornike Davitashvili on 16.10.15.
//  Copyright © 2015 Lemondo Business. All rights reserved.
//

#import "LanguageManager.h"
#import "SharedPreferenceManager.h"

@implementation LanguageManager
+(id) sharedManager{
    static LanguageManager *sharedmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedmanager = [[self alloc] init];
    });
    return sharedmanager;
}

-(id) init{
    if(self = [super init]){
        
    }
    return self;
}

- (NSString*)getSelectedLanguage{
    NSString *language = CURRENT_LANGUAGE;
    NSString *saveLanguage = [SharedPreferenceManager getLanguage];
    if (saveLanguage == nil) {
        if ([language hasPrefix:@"ka-GE"] || [language hasPrefix:@"ka"]) {
            self.currentLanguage = ka;
            saveLanguage = @"ka";
        }else if([language hasPrefix:@"ru-GE"] || [language hasPrefix:@"ru"]){
            self.currentLanguage = ru;
            saveLanguage = @"ru";
        }else{
            self.currentLanguage = en;
            saveLanguage = @"en";
        }
    }else{
        if ([saveLanguage hasPrefix:@"ka"]) {
            self.currentLanguage = ka;
        }else if([saveLanguage hasPrefix:@"ru"]){
            self.currentLanguage = ru;
        }else {
            self.currentLanguage = en;
        }
    }
   
   return saveLanguage;
}
- (NSString*)getLocalizedStringFromKey:(NSString*)key{
    NSString *language = [self getSelectedLanguage];
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
    return [languageBundle localizedStringForKey:key value:@"" table:@""];
}
@end
