//
//  MyToursCustomCell.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMaterialDesignSpinner.h"
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface MyToursCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tourTitle;
@property (weak, nonatomic) IBOutlet UILabel *tourMiniDescription;
@property (weak, nonatomic) IBOutlet UIImageView *tourPosterImg;
@property (weak, nonatomic) IBOutlet UIView *popularBadge;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderImage;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *tourStar;
@property (weak, nonatomic) IBOutlet UILabel *POPULARLBL;
@end
