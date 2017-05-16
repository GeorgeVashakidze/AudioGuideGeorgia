//
//  LocalizableLabel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/10/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageManager.h"

@interface LocalizableLabel : UILabel
-(void)changeLocalizable:(NSString*)key;
@end
