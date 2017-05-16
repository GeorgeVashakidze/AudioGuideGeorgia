//
//  LanguageManager.h
//  MyPhone
//
//  Created by Tornike Davitashvili on 16.10.15.
//  Copyright © 2015 Lemondo Business. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface LanguageManager : NSObject
@property Language currentLanguage;
- (NSString*)getLocalizedStringFromKey:(NSString*)key;
- (NSString*)getSelectedLanguage;
+(id) sharedManager;
@end
