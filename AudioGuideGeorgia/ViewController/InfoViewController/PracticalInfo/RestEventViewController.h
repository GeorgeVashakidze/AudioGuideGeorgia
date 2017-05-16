//
//  RestEventViewController.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LocalizableLabel.h"

@interface RestEventViewController : UIViewController
@property (weak, nonatomic) IBOutlet LocalizableLabel *controllerTiTle;
@property (weak, nonatomic) NSString *titleStr;
@property Inforamtion info;
@end
