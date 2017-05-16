//
//  FestivalsModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/27/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "FestivalsModel.h"

@implementation FestivalsModel
-(void)parsModel:(NSDictionary *)dic{
    NSString *imgURL = @"";
    if (![dic[@"ImagesFirst"] isEqual:[NSNull null]]) {
        imgURL = dic[@"ImagesFirst"][@"file"];
    }else{
        if (![dic[@"Images"] isEqual:[NSNull null]]) {
            NSArray *imagesArray = dic[@"Images"];
            if (imagesArray.count > 0) {
                imgURL = imagesArray[0][@"file"];
            }
        }
    }
    self.imagesFirst = [@ImageUrlHost stringByAppendingString:imgURL];
    if (![dic[@"Images"] isEqual:[NSNull null]]) {
        if (dic[@"Images"]) {
            NSArray *images = dic[@"Images"];
            self.imagesArray = [[NSMutableArray alloc] initWithCapacity:images.count];
            for (int i = 0; i<images.count; i++) {
                NSDictionary *item = images[i];
                NSString *urlStr = [@ImageUrlHost stringByAppendingString:item[@"file"]];
                [self.imagesArray addObject:urlStr];
            }
        }
    }
    self.address = dic[@"address"];
    self.sightDescription = dic[@"description"];
    self.contact = dic[@"contact"];
    self.sightTitle = dic[@"title"];
    self.sightLat = [NSNumber numberWithFloat:[dic[@"lat"] doubleValue]];
    self.sightLng = [NSNumber numberWithFloat:[dic[@"lng"] doubleValue]];
    self.typeFestival = dic[@"type"];
    self.sightID = dic[@"id"];
    self.venueName = dic[@"venue"];
    self.eventDate = [self getEventDate:dic[@"time"]];
}
-(NSDate*)getEventDate:(NSString*)dateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}
@end
