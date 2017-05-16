//
//  PagesModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/22/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "PagesModel.h"

@implementation PagesModel
-(void)parseModel:(NSDictionary *)dic{
    self.pageTitle = dic[@"title"];
    self.pageID = dic[@"id"];
    self.pageDescription = dic[@"description"];
    NSDictionary *image = dic[@"ImagesFirst"];
    if (image && ![image isEqual:[NSNull null]]) {
        NSString *urlImg = [@ImageUrlHost stringByAppendingString:image[@"file"]];
        self.imagesFirst = urlImg;
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
