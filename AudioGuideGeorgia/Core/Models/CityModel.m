//
//  CityModel.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/20/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.cityID = [coder decodeObjectForKey:@"bookID"];
        self.cityTitle = [coder decodeObjectForKey:@"bookAuthorsArray"];
        self.keywords = [coder decodeObjectForKey:@"bookBuyTime"];
        self.date = [coder decodeObjectForKey:@"bookCanDownload"];
        self.priority = [coder decodeIntForKey:@"bookCategoryArray"];
        self.north = [coder decodeDoubleForKey:@"bookName"];
        self.south = [coder decodeDoubleForKey:@"bookRating"];
        self.west = [coder decodeDoubleForKey:@"bookThumbImageURlString"];
        self.east = [coder decodeDoubleForKey:@"bookPath"];
        self.imagesFirst = [coder decodeObjectForKey:@"isAudio"];
        self.images = [coder decodeObjectForKey:@"bookIsdownloaded"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_cityID forKey:@"bookID"];
    
    [coder encodeObject:_cityTitle forKey:@"bookAuthorsArray"];
    [coder encodeObject:_keywords forKey:@"bookBuyTime"];
    [coder encodeObject:_date forKey:@"bookCanDownload"];
    [coder encodeInt:_priority forKey:@"bookCategoryArray"];
    [coder encodeDouble:_north forKey:@"bookName"];
    [coder encodeDouble:_south forKey:@"bookRating"];
    [coder encodeDouble:_west forKey:@"bookThumbImageURlString"];
    [coder encodeDouble:_east forKey:@"bookPath"];
    [coder encodeObject:_imagesFirst forKey:@"isAudio"];
    [coder encodeObject:_images forKey:@"bookIsdownloaded"];
}
-(void)parsModel:(NSDictionary *)dic{
    self.cityID = dic[@"id"];
    self.keywords = dic[@"keywords"];
    self.cityTitle = dic[@"name"];
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
    NSArray *images = dic[@"Images"];
    self.images = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (int j = 0; j<images.count; j++) {
        NSDictionary *image = images[j];
        NSString *urlImg = [@ImageUrlHost stringByAppendingString:image[@"file"]];
        [self.images addObject:urlImg];
    }
    self.priority = [dic[@"p"] intValue];
    self.north = [dic[@"north"] doubleValue];
    self.south = [dic[@"south"] doubleValue];
    self.west = [dic[@"west"] doubleValue];
    self.east = [dic[@"east"] doubleValue];
}
-(NSDate*)getEventDate:(NSString*)dateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"Asia/Tbilisi"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}
@end
