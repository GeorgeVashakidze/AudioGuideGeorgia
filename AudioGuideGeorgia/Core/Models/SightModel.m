//
//  SightModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "SightModel.h"
#import "ToursModel.h"
#import "FilterModel.h"
#import "LanguageManager.h"

@implementation SightModel

-(void)parsModel:(NSDictionary *)dic{
    self.sightTitle = dic[@"title"];
    self.sightPrice = [dic[@"price"] integerValue];
    self.sightIsPass = 0;
    self.needUpdate = 0;
    self.baseReceptStr = @"";
    self.sightLng = [NSNumber numberWithFloat: [dic[@"lng"] doubleValue]];
    self.sightLat = [NSNumber numberWithFloat:[dic[@"lat"] doubleValue]];
    self.sightID = dic[@"id"];
    self.sightDescription = dic[@"description"];
    self.audioName_Local = @"";
    if (![dic[@"city_id"] isEqual:[NSNull null]]) {
        self.cityID =  [NSNumber numberWithInt:[dic[@"city_id"] intValue]];
    }
    if (![dic[@"date"] isEqual:[NSNull null]]) {
        if (dic[@"date"]) {
            self.date = [self getEventDate:dic[@"date"]];
        }
    }
    if (![dic[@"ImagesFirst"] isEqual:[NSNull null]]) {
        if (dic[@"ImagesFirst"]) {
            self.imagesFirst = [@ImageUrlHost stringByAppendingString:dic[@"ImagesFirst"][@"file"]];
        }
    }
    self.must_see = [dic[@"must_see"] intValue];
    NSArray *images = dic[@"Images"];
    self.imagesArray = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (int j = 0; j<images.count; j++) {
        NSDictionary *image = images[j];
        NSString *urlImg = [@ImageUrlHost stringByAppendingString:image[@"file"]];
        [self.imagesArray addObject:urlImg];
    }
    if (![dic[@"tour"] isEqual:[NSNull null]] && [dic[@"tour"] count] > 0) {
        self.tours = [[NSMutableArray alloc] initWithCapacity:[dic[@"tour"] count]];
        NSArray *data = dic[@"tour"];
        for (int i=0; i<data.count; i++) {
            NSDictionary *tourdic = data[i];
            ToursModel *model = [[ToursModel alloc] init];
            [model parseModel:tourdic];
            [self.tours addObject:model];
        }
    }
        self.audiosFirst = [[NSMutableArray alloc] initWithCapacity:1];
        self.audiosFirstName = [[NSMutableArray alloc] initWithCapacity:1];
        NSString *urlAudio = [@AudioUrlHost stringByAppendingString:[self.sightID stringValue]];
        [self.audiosFirst addObject:urlAudio];
    if (![dic[@"Audio"] isEqual:[NSNull null]]) {
        if (dic[@"Audio"][@"file"]) {
            NSString *fileName = dic[@"Audio"][@"file"];
            [self.audiosFirstName addObject:fileName];
            self.auidoFileMemory = [NSNumber numberWithLongLong:[dic[@"Audio"][@"size"] longLongValue]];
        }
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
@end
