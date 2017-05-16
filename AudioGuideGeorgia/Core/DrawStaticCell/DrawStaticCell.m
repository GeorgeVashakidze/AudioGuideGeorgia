//
//  DrawStaticCell.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/26/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "DrawStaticCell.h"
#import "ToursDetailCustomCell.h"
#import "ToursModel.h"
#import "RestaurantsModel.h"
#import "ShopsModel.h"
#import "FestivalsModel.h"

@implementation DrawStaticCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dintProBold = [UIFont fontWithName:@"DINPro-Bold" size:14];
        self.dintProRegular = [UIFont fontWithName:@"DINPro-Regular" size:14];
       self.selectedColor = [UIColor colorWithRed:61.0/255.0 green:56.0/255.0 blue:122.0/255.0 alpha:1];

    }
    return self;
}

-(NSString*)getMiniDescription:(NSUInteger)sightCount withDuration:(NSNumber*)duration withDistance:(NSNumber*)distance{
    NSString *tourhours = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"tourhours"];
    NSString *tourdistanse = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"tourdistanse"];
    NSString *toursightsnumberstop =  [[LanguageManager sharedManager] getLocalizedStringFromKey:@"toursightsnumberstop"];
       NSString *value = [NSString stringWithFormat:@"%lu %@, %@ %@, %@ %@",(unsigned long)sightCount,toursightsnumberstop,duration ,tourhours,distance,tourdistanse];
    return value;
}
-(void)drawTourDetail:(ToursDetailCustomCell *)cell withModel:(ToursModel *)model andIndex:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            //Title
            cell.tourTitleLbl.text = model.tourTitle;
            cell.tourShorDescripton.text = [self getMiniDescription:model.sightTour.count withDuration:model.distance withDistance:model.duration];
            break;
        case 1:
            //Start End
            cell.tourStartLbl.text = model.start;
            cell.tourEndLbl.text = model.finish;
            break;
        case 2:
            //Note
        {
            if (model.notes && ![model.notes isEqualToString:@""]) {
                cell.noteLbl.text = [@"Note: " stringByAppendingString:model.notes];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.noteLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 5)];
                cell.noteLbl.attributedText = attrStr;
            }else{
                cell.noteLbl.text = @"";
            }
            
        }
            break;
        case 3:
            //Break tip
        {
            if (model.break_tip && ![model.break_tip isEqualToString:@""]) {
                cell.breakTipLbl.text = [@"Braek tip: "  stringByAppendingString:model.break_tip];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.breakTipLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 10)];
                cell.breakTipLbl.attributedText = attrStr;
                
            }else{
                cell.breakTipLbl.text = @"";
            }
        }
            break;
        case 4:
        {
            if (model.tourDescription && ![model.tourDescription isEqualToString:@""]) {
                cell.longDescription.text = [@"Description: " stringByAppendingString:model.tourDescription];
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[cell.longDescription.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 11)];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProRegular range:NSMakeRange(0, attrStr.length)];
                [attrStr addAttribute:NSForegroundColorAttributeName value:_selectedColor range:NSMakeRange(0, attrStr.length)];
                cell.longDescription.attributedText = attrStr;
            }else{
                cell.longDescription.text = @"";
            }
            cell.sightsArray = model.sightTour;
            [cell reloadDataCollectionView];
            if (self.isFromInfo || model.sightTour.count == 0) {
                cell.heightCollectio.constant = 0;
                cell.heightstopsLbl.constant = 0;
            }else{
                cell.heightCollectio.constant = 148;
                cell.heightstopsLbl.constant = 18;
                cell.stopCountLbl.text = [NSString stringWithFormat:@"%lu stops",(unsigned long)model.sightTour.count];
            }
        }
            break;
        case 5:{
            cell.deleteLbl.layer.masksToBounds = YES;
            cell.deleteLbl.layer.cornerRadius = 8;
        }
        default:
            break;
    }

}
-(void)drawRestaurantDetail:(ToursDetailCustomCell *)cell withModel:(RestaurantsModel *)model andIndex:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            //Title
            cell.tourTitleLbl.text = model.sightTitle;
            cell.tourShorDescripton.text = model.restType;
            break;
        case 1:{
            //Start End
            cell.startLbl.text = @"";
            cell.endLbl.text = @"";
            cell.tourStartLbl.text = @"Openning Hours: 12:00 - 02:00";
            cell.tourEndLbl.text = @"";
            cell.leftOpeningConstraint.constant = 0;
            NSMutableAttributedString *attrStr =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: cell.tourStartLbl.attributedText];
            [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 15)];
            cell.tourStartLbl.attributedText = attrStr;
        }
            break;
        case 2:
            //Note
        {
            if (model.contact && ![model.contact isEqualToString:@""]) {
                cell.noteLbl.text = [@"Contact to book: " stringByAppendingString:model.contact];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.noteLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 16)];
                cell.noteLbl.attributedText = attrStr;
            }else{
                cell.noteLbl.text = @"";
            }
            
        }
            break;
        case 3:
            //Break tip
        {
            if (model.address && ![model.address isEqualToString:@""]) {
                cell.breakTipLbl.text = [@"Address: "  stringByAppendingString:model.address];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.breakTipLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 9)];
                cell.breakTipLbl.attributedText = attrStr;
                
            }else{
                cell.breakTipLbl.text = @"";
            }
        }
            break;
        case 4:
        {
            if (model.sightDescription && ![model.sightDescription isEqualToString:@""]) {
                cell.longDescription.text = [@"Description: " stringByAppendingString:model.sightDescription];
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[cell.longDescription.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 11)];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProRegular range:NSMakeRange(0, attrStr.length)];
                [attrStr addAttribute:NSForegroundColorAttributeName value:_selectedColor range:NSMakeRange(0, attrStr.length)];
                cell.longDescription.attributedText = attrStr;
            }else{
                cell.longDescription.text = @"";
            }
            cell.heightCollectio.constant = 0;
            cell.heightstopsLbl.constant = 0;

        }
        default:
            break;
    }
}
-(void)drawShopDetail:(ToursDetailCustomCell *)cell withModel:(ShopsModel *)model andIndex:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            //Title
            cell.tourTitleLbl.text = model.sightTitle;
            cell.tourShorDescripton.text = model.typeShop;
            break;
        case 1:{
            //Start End
            cell.startLbl.text = @"";
            cell.endLbl.text = @"";
            cell.leftOpeningConstraint.constant = 0;
            cell.tourStartLbl.text = @"Working Hours: 12:00 - 02:00";
            cell.tourEndLbl.text = @"";
            NSMutableAttributedString *attrStr =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: cell.tourStartLbl.attributedText];
            [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 15)];
            cell.tourStartLbl.attributedText = attrStr;
        }
            break;
        case 2:
            //Note
        {
            if (model.webURL && ![model.webURL isEqualToString:@""]) {
                cell.noteLbl.text = [@"Website: " stringByAppendingString:model.webURL];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.noteLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0,9)];
                cell.noteLbl.attributedText = attrStr;
            }else{
                cell.noteLbl.text = @"";
            }
            
        }
            break;
        case 3:
            //Break tip
        {
            if (model.address && ![model.address isEqualToString:@""]) {
                cell.breakTipLbl.text = [@"Address: "  stringByAppendingString:model.address];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.breakTipLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 9)];
                cell.breakTipLbl.attributedText = attrStr;
                
            }else{
                cell.breakTipLbl.text = @"";
            }
        }
            break;
        case 4:
        {
            if (model.sightDescription && ![model.sightDescription isEqualToString:@""]) {
                cell.longDescription.text = [@"Description: " stringByAppendingString:model.sightDescription];
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[cell.longDescription.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 11)];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProRegular range:NSMakeRange(0, attrStr.length)];
                [attrStr addAttribute:NSForegroundColorAttributeName value:_selectedColor range:NSMakeRange(0, attrStr.length)];
                cell.longDescription.attributedText = attrStr;
            }else{
                cell.longDescription.text = @"";
            }
            cell.heightCollectio.constant = 0;
            cell.heightstopsLbl.constant = 0;
            
        }
        default:
            break;
    }
}
-(void)drawFestivalDetail:(ToursDetailCustomCell *)cell withModel:(FestivalsModel *)model andIndex:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            //Title
            cell.tourTitleLbl.text = model.sightTitle;
            cell.tourShorDescripton.text = model.typeFestival;
            break;
        case 1:{
            //Start End
            cell.startLbl.text = @"";
            cell.endLbl.text = @"";
            cell.leftOpeningConstraint.constant = 0;
            cell.tourStartLbl.text = [self getDateStr:model.eventDate];
            cell.tourEndLbl.text = @"";
            NSMutableAttributedString *attrStr =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: cell.tourStartLbl.attributedText];
            [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 14)];
            cell.tourStartLbl.attributedText = attrStr;
        }
            break;
        case 2:
            //Note
        {
            if (model.venueName && ![model.venueName isEqualToString:@""]) {
                cell.noteLbl.text = [@"Venue: " stringByAppendingString:model.venueName];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.noteLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 6)];
                cell.noteLbl.attributedText = attrStr;
            }else{
                cell.noteLbl.text = @"";
            }
            
        }
            break;
        case 3:
            //Break tip
        {
            if (model.address && ![model.address isEqualToString:@""]) {
                cell.breakTipLbl.text = [@"Address: "  stringByAppendingString:model.address];
                NSMutableAttributedString *attrStr =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: cell.breakTipLbl.attributedText];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 9)];
                cell.breakTipLbl.attributedText = attrStr;
                
            }else{
                cell.breakTipLbl.text = @"";
            }
        }
            break;
        case 4:
        {
            if (model.sightDescription && ![model.sightDescription isEqualToString:@""]) {
                cell.longDescription.text = [@"Description: " stringByAppendingString:model.sightDescription];
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[cell.longDescription.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                
                [attrStr addAttribute:NSFontAttributeName value:self.dintProBold range:NSMakeRange(0, 11)];
                [attrStr addAttribute:NSFontAttributeName value:self.dintProRegular range:NSMakeRange(0, attrStr.length)];
                [attrStr addAttribute:NSForegroundColorAttributeName value:_selectedColor range:NSMakeRange(0, attrStr.length)];
                cell.longDescription.attributedText = attrStr;
            }else{
                cell.longDescription.text = @"";
            }
            cell.heightCollectio.constant = 0;
            cell.heightstopsLbl.constant = 0;
            
        }
        default:
            break;
    }
}
-(NSString*)getDateStr:(NSDate*)festivalDate{
    NSString *dateStr = @"Date and time: ";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setDateFormat:@"dd.MM"];
    NSString *stringDate = [dateFormatter stringFromDate:festivalDate];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *stringHours = [dateFormatter stringFromDate:festivalDate];
    return [[[dateStr stringByAppendingString:stringDate] stringByAppendingString:@" / "] stringByAppendingString:stringHours];
}
@end
