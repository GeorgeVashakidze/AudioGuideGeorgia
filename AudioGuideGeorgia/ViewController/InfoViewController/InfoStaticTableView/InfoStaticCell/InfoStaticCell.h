//
//  InfoStaticCell.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalizableLabel.h"

@interface InfoStaticCell : UITableViewCell
@property (weak,nonatomic) IBOutlet LocalizableLabel *pracLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *restLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *shopLbl;
@property (weak,nonatomic) IBOutlet LocalizableLabel *eventcLbl;
@end
