//
//  LocalizableLabel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/10/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LocalizableLabel.h"

@implementation LocalizableLabel

-(void)awakeFromNib{
    [super awakeFromNib];
}
-(void)changeLocalizable:(NSString*)key{
    NSString *languageStr = [[LanguageManager sharedManager] getSelectedLanguage];
    UIFont *fontEn = self.font;
    CGFloat fontSize = fontEn.pointSize;
    if ([languageStr isEqualToString:@"en"]) {
        self.font = [UIFont fontWithName:@"DINPro-Regular" size:fontSize];
    }else if([languageStr isEqualToString:@"ru"]){
        self.font = [UIFont fontWithName:@"DINPro-Regular" size:fontSize];
    }else if ([languageStr isEqualToString:@"ka"]){
        self.font = [UIFont fontWithName:@"NotoSansGeorgian" size:fontSize];
    }
    self.text = [[LanguageManager sharedManager] getLocalizedStringFromKey:key];
}
@end
