//
//  HomeViewController.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/28/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "Constants.h"

@interface HomeViewController : UIViewController<SlideNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *posterByCity;
@end
