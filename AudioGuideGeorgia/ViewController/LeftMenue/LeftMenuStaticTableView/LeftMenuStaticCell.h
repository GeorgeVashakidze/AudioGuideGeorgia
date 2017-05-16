//
//  LeftMenuStaticCell.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/10/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalizableLabel.h"

@interface LeftMenuStaticCell : UITableViewCell
@property (weak,nonatomic) IBOutlet LocalizableLabel *promotionLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *langaugeLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *myTourLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *preferencesLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *reviewLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *feedBackLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *invLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *shareLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *aboutLbl;
@end
