//
//  SightsCustomItem.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMaterialDesignSpinner.h"

@interface SightsCustomItem : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *sightPoster;
@property (weak, nonatomic) IBOutlet UILabel *sightTitle;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *imageLoader;

@end
