//
//  SightsCustomCellNib.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SightsCustomCellNib : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *sightNumber;
@property (weak, nonatomic) IBOutlet UILabel *signtname;
@property (weak, nonatomic) IBOutlet UIImageView *sightPoster;

@end
