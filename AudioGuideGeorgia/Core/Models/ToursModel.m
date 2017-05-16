//
//  ToursModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ToursModel.h"
#import "FilterModel.h"
#import "SharedPreferenceManager.h"

@implementation ToursModel

-(void)parseModel:(NSDictionary *)dic{
    self.toursID = dic[@"id"];
    self.receptStr = @"";
    self.tourlive = 0;
    self.isDeleteTour = 0;
    if ([dic[@"vote"] isKindOfClass:[NSString class]]) {
        NSString *vote = dic[@"vote"];
        self.tourRaiting = [vote integerValue] / 20;
    }
    self.tourIsRait = 0;
    NSString *freeTour = dic[@"free"];
    self.tourIsFree = [freeTour intValue];
    if (![dic[@"polyline"] isEqual:[NSNull null]] && ![dic[@"polyline"] isEqualToString:@""]) {
        if (dic[@"polyline"]) {
            self.polylineStr = dic[@"polyline"];
            [self convertStringToArray:dic[@"polyline"]];
        }
    }
    self.tourTotalPrice = [NSNumber numberWithFloat:[dic[@"price"] floatValue]];
    if (![dic[@"city_id"] isEqual:[NSNull null]]) {
        self.cityID = dic[@"city_id"];
    }
    self.distance = dic[@"distance"];
    self.duration = dic[@"duration"];
    self.tourTitle = dic[@"title"];
    self.tourDescription = dic[@"description"];
    self.isPopupar = [dic[@"popular"] intValue];
    self.break_tip = dic[@"break_tip"];
    self.notes = dic[@"avoid"];
    self.finish = dic[@"finish"];
    self.start = dic[@"start"];
    if (![dic[@"date"] isEqual:[NSNull null]]) {
        if (dic[@"date"]) {
            self.date = [self getEventDate:dic[@"date"]];
        }
    }
    NSArray *toursImg = dic[@"Images"];
    self.toursImages = [[NSMutableArray alloc] initWithCapacity:toursImg.count];
    for (int i = 0; i < toursImg.count; i++) {
        NSDictionary *item = toursImg[i];
        NSString *urlStr = [@ImageUrlHost stringByAppendingString:item[@"file"]];
        [self.toursImages addObject:urlStr];
    }
    
    self.tourCity = [[CityModel alloc] init];
    if (![dic[@"city"] isEqual:[NSNull null]]) {
        NSDictionary *city = dic[@"city"];
        self.tourCity.cityID = city[@"id"];
        self.tourCity.cityTitle = city[@"name"];
    }
    NSArray *sights = dic[@"sight"];
    self.sightTour = [[NSMutableArray alloc] initWithCapacity:sights.count];
    for (int i=0; i<sights.count; i++) {
        NSDictionary *sight = sights[i];
        SightModel *sightModel = [[SightModel alloc] init];
        [sightModel parsModel:sight];
        [self.sightTour addObject:sightModel];
    }

    if (![dic[@"category"] isEqual:[NSNull null]] && [dic[@"category"] count] > 0) {
        NSArray *category = dic[@"category"];
        self.category = [[NSMutableArray alloc] initWithCapacity:category.count];
        for (int j = 0; j<category.count; j++) {
            NSDictionary *cat = category[j];
            FilterModel *model = [[FilterModel alloc] init];
            [model parsMode:cat];
            [self.category addObject:model];
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
-(void)convertStringToArray:(NSString*)arrayStr{
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[arrayStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    self.polyline = [[NSMutableArray alloc] initWithCapacity:jsonObject.count];
    for (int i = 0; i<jsonObject.count; i++) {
        NSArray *item = jsonObject[i];
        if ([self.toursID intValue] == 1) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[item[1] doubleValue] longitude:[item[0] doubleValue]];
            [self.polyline addObject:location];
        }else{
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[item[0] doubleValue] longitude:[item[1] doubleValue]];
            [self.polyline addObject:location];
        }

    }
}
@end
