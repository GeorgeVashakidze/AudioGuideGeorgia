//
//  InfoStaticCell.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "InfoStaticCell.h"

@implementation InfoStaticCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.pracLbl changeLocalizable:@"pracinfolbl"];
    [self.restLbl changeLocalizable:@"restinfolbl"];
    [self.shopLbl changeLocalizable:@"shopslbl"];
    [self.eventcLbl changeLocalizable:@"festlbl"];
    // Configure the view for the selected state
}

@end
