//
//  PagesModel.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/22/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface PagesModel : NSObject
@property NSNumber *pageID;
@property NSString *pageTitle;
@property NSString *imagesFirst;
@property NSString *pageDescription;
@property NSDate *date;
-(void)parseModel:(NSDictionary*)dic;
@end
