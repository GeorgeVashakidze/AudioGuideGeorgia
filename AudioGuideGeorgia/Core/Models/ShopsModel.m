//
//  ShopsModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/22/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ShopsModel.h"

@implementation ShopsModel
-(void)parsModel:(NSDictionary *)dic{
    self.sightTitle = dic[@"title"];
    self.sightLat = [NSNumber numberWithFloat:[dic[@"lat"] doubleValue]];
    self.sightLng = [NSNumber numberWithFloat:[dic[@"lng"] doubleValue]];
    self.typeShop = dic[@"type"];
    self.sightID = dic[@"id"];
    self.contact = dic[@"contact"];
    self.address = dic[@"address"];
    self.sightDescription = dic[@"description"];
    self.webURL = dic[@"web"];
    if (![dic[@"ImagesFirst"] isEqual:[NSNull null]]) {
        if (dic[@"ImagesFirst"]) {
            self.imagesFirst = [@ImageUrlHost stringByAppendingString:dic[@"ImagesFirst"][@"file"]];
        }
    }
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
    if (![dic[@"date"] isEqual:[NSNull null]]) {
        if (dic[@"date"]) {
            self.date = [self getEventDate:dic[@"date"]];
        }
    }
}
-(NSDate*)getEventDate:(NSString*)dateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"Asia/Tbilisi"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}
@end
