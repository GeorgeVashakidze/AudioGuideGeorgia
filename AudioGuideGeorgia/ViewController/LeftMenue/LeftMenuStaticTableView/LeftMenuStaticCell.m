//
//  LeftMenuStaticCell.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/10/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LeftMenuStaticCell.h"

@implementation LeftMenuStaticCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.promotionLbl changeLocalizable:@"promotionmenu"];
    [self.langaugeLbl changeLocalizable:@"languagemenu"];
    [self.myTourLbl changeLocalizable:@"mytoursmenu"];
    [self.preferencesLbl changeLocalizable:@"preferencesmenu"];
    [self.reviewLbl changeLocalizable:@"addreviewmenu"];
    [self.feedBackLbl changeLocalizable:@"feedbackmenu"];
    [self.invLbl changeLocalizable:@"inffrinedmenu"];
    [self.shareLbl changeLocalizable:@"sharefacebookmenu"];
    [self.aboutLbl changeLocalizable:@"aboutusmenu"];
}

@end
